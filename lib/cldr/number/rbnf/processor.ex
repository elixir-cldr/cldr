defmodule Cldr.Rbnf.Processor do
  defmacro __using__(_opts) do
    quote location: :keep do
      alias  Cldr.Number
      import Cldr.Rbnf.Processor

      defp do_rule(number, locale, function, rule, parsed) do
        parsed
        |> Enum.map(fn {operation, argument} ->
            # IO.puts "Rule: #{inspect operation} on #{inspect number} with argument #{inspect argument}"
            do_operation(operation, number, locale, function, rule, argument)
            # |> IO.inspect
          end)
        |> :erlang.iolist_to_binary
      end

      defp do_operation(:literal, _number, _locale, _function, _rule, string) do
        string
      end

      defp do_operation(:modulo, number, locale, function, rule, nil)
      when is_number(number) and number < 0 do
        apply(__MODULE__, function, [abs(number), locale])
      end

      defp do_operation(:modulo, number, locale, function, rule, {:format, format})
      when is_number(number) and number < 0 do
        Cldr.Number.to_string(abs(number), locale: locale, format: format)
      end

      defp do_operation(:modulo, number, locale, function, rule, nil)
      when is_integer(number) do
        mod = number - (div(number, rule.divisor) * rule.divisor)
        apply(__MODULE__, function, [mod, locale])
      end

      # For Fractional rules we format the integral part
      defp do_operation(:modulo, number, locale, function, _rule, nil)
      when is_float(number) do
        format_fraction(number, locale)
      end

      defp do_operation(:modulo, number, locale, _function, rule, {:rule, rule_name}) do
        mod = number - (div(number, rule.divisor) * rule.divisor)
        apply(__MODULE__, rule_name, [mod, locale])
      end

      defp do_operation(:modulo, number, locale, function, rule, {:format, format}) do
        mod = number - (div(number, rule.divisor) * rule.divisor)
        Cldr.Number.to_string(mod, locale: locale, format: format)
      end

      # For Fractional rules we format the fraction as individual digits.
      defp do_operation(:quotient, number, locale, function, rule, nil)
      when is_float(number) do
        apply(__MODULE__, function, [trunc(number), locale])
      end

      defp do_operation(:quotient, number, locale, function, rule, nil) do
        divisor = div(number, rule.divisor)
        apply(__MODULE__, function, [divisor, locale])
      end

      defp do_operation(:quotient, number, locale, _function, rule, {:rule, rule_name}) do
        divisor = div(number, rule.divisor)
        apply(__MODULE__, rule_name, [divisor, locale])
      end

      defp do_operation(:call, number, locale, _function, _rule, {:format, format}) do
        Cldr.Number.to_string(number, locale: locale, format: format)
      end

      defp do_operation(:call, number, locale, _function, _rule, {:rule, rule_name}) do
        apply(__MODULE__, rule_name, [number, locale])
      end

      defp do_operation(:ordinal, number, locale, _function, _rule, plurals) do
        plural = Cldr.Number.Ordinal.plural_rule(number, locale)
        Map.get(plurals, plural) || Map.get(plurals, :other)
      end

      defp do_operation(:cardinal, number, locale, _function, _rule, plurals) do
        plural = Cldr.Number.Cardinal.plural_rule(number, locale)
        Map.get(plurals, plural) || Map.get(plurals, :other)
      end

      defp do_operation(:conditional, number, locale, function, rule, argument) do
        mod = number - (div(number, rule.divisor) * rule.divisor)
        if mod > 0 do
          do_rule(mod, locale, function, rule, argument)
        else
          ""
        end
      end

      defp format_fraction(number, locale) do
        fraction = number
        |> Cldr.Number.Math.fraction_as_integer
        |> Integer.to_string
        |> String.split("", trim: true)
        |> Enum.map(&String.to_integer/1)
        |> Enum.map(&Cldr.Rbnf.Spellout.spellout_cardinal(&1, locale))
        |> Enum.join(" ")
      end
    end
  end

  def define_rules(rule_group_name, env) do
    iterate_rules rule_group_name, fn (rule_group, locale, access, rule) ->
      {:ok, parsed} = Cldr.Rbnf.Rule.parse(rule.definition)

      define_rule(rule.base_value, rule.range, access, rule_group, locale, rule, parsed)
      |> Code.eval_quoted([], env)
    end
  end

  defp iterate_rules(rule_group_type, fun) do
    all_rules = Cldr.Rbnf.for_all_locales[rule_group_type]
    unless is_nil(all_rules) do
      for {locale, _rule_group} <-  all_rules do
        for {rule_group, %{access: access, rules: rules}} <- all_rules[locale] do
          for rule <- rules do
            fun.(rule_group, locale, access, rule)
          end
        end
      end
    end
  end

  def rule_sets(rule_group_type, locale) do
    if rule_group = Cldr.Rbnf.for_locale(locale)[rule_group_type] do
      Enum.filter(rule_group, fn {_name, set} -> set.access == "public" end)
      |> Enum.map(fn {name, _rules} -> name end)
    else
      []
    end
  end


  defp define_rule("-x", _range, _access, rule_group, locale, rule, parsed) do
    quote do
      def unquote(rule_group)(number, unquote(locale))
      when Kernel.and(is_number(number), number < 0) do
        do_rule(number,
          unquote(locale),
          unquote(rule_group),
          unquote(Macro.escape(rule)),
          unquote(Macro.escape(parsed)))
      end
    end
  end

  # Improper fraction rule
  defp define_rule("x.x", _range, _access, rule_group, locale, rule, parsed) do
    quote do
      def unquote(rule_group)(number, unquote(locale))
      when is_float(number) do
        do_rule(number,
          unquote(locale),
          unquote(rule_group),
          unquote(Macro.escape(rule)),
          unquote(Macro.escape(parsed)))
      end
    end
  end

  defp define_rule("x,x", _range, _access, _rule_group, _locale, _rule, _parsed) do
    {:error, "Improper Fraction rule sets are not implemented"}
  end

  defp define_rule("Inf", _range, _access, _rule_group, _locale, _rule, _parsed) do
    {:error, "Infinite rule sets are not implemented"}
  end

  defp define_rule("NaN", _range, _access, _rule_group, _locale, _rule, _parsed) do
    {:error, "NaN rule sets are not implemented"}
  end

  defp define_rule("0.x", _range, _access, _rule_group, _locale, _rule, _parsed) do
    {:error, "Proper Fraction rule sets are not implemented"}
  end

  defp define_rule("x.0", _range, _access, _rule_group, _locale, _rule, _parsed) do
    {:error, "Master rule sets are not implemented"}
  end

  defp define_rule(0, "undefined", _access, rule_group, locale, rule, parsed) do
    quote do
      def unquote(rule_group)(number, unquote(locale))
      when is_integer(number) do
        do_rule(number,
          unquote(locale),
          unquote(rule_group),
          unquote(Macro.escape(rule)),
          unquote(Macro.escape(parsed)))
      end
    end
  end

  defp define_rule(base_value, "undefined", _access, rule_group, locale, rule, parsed)
  when is_integer(base_value) do
    quote do
      def unquote(rule_group)(number, unquote(locale))
      when Kernel.and(is_integer(number), number >= unquote(base_value)) do
        do_rule(number,
          unquote(locale),
          unquote(rule_group),
          unquote(Macro.escape(rule)),
          unquote(Macro.escape(parsed)))
      end
    end
  end

  defp define_rule(base_value, range, _access, rule_group, locale, rule, parsed)
  when is_integer(range) and is_integer(base_value) do
    quote do
      def unquote(rule_group)(number, unquote(locale))
      when Kernel.and(is_integer(number),
        Kernel.and(number >= unquote(base_value), number < unquote(range))) do
        do_rule(number,
          unquote(locale),
          unquote(rule_group),
          unquote(Macro.escape(rule)),
          unquote(Macro.escape(parsed)))
      end
    end
  end

  defp define_rule(base_value, "undefined", _access, rule_group, locale, rule, parsed)
  when is_integer(base_value) do
    quote do
      def unquote(rule_group)(number, unquote(locale))
      when Kernel.and(is_integer(number), number >= unquote(base_value)) do
        do_rule(number,
          unquote(locale),
          unquote(rule_group),
          unquote(Macro.escape(rule)),
          unquote(Macro.escape(parsed)))
      end
    end
  end
end