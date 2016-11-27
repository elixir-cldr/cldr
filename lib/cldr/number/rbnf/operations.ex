defmodule Cldr.Rbnf.Operations do
  defmacro __using__(_opts) do
    quote do
      alias Cldr.Number

      def do_rule(number, locale, function, rule, parsed) do
        parsed
        |> Enum.map(fn {operation, argument} ->
            # IO.puts "Rule: #{inspect operation} with argument #{inspect argument}"
            apply(__MODULE__, operation, [number, locale, function, rule, argument])
          end)
        |> :erlang.iolist_to_binary
      end

      def literal(_number, _locale, _function, _rule, string) do
        string
      end

      def modulo(number, locale, function, _rule, nil) when number < 0 do
        apply(__MODULE__, function, [abs(number), locale])
      end

      def modulo(number, locale, function, _rule, nil) do
        apply(__MODULE__, function, [number, locale])
      end

      def modulo(number, locale, _function, rule, {:rule, rule_name}) do
        mod = number - (div(number, rule.divisor) * rule.divisor)
        apply(__MODULE__, rule_name, [mod, locale])
      end

      def quotient(number, locale, function, rule, nil) do
        divisor = div(number, rule.divisor)
        apply(__MODULE__, function, [divisor, locale])
      end

      def quotient(number, locale, _function, rule, {:rule, rule_name}) do
        divisor = div(number, rule.divisor)
        apply(__MODULE__, rule_name, [divisor, locale])
      end

      def call(number, locale, _function, _rule, {:format, format}) do
        Number.to_string(number, locale: locale, format: format)
      end

      def call(number, locale, _function, _rule, {:rule, rule_name}) do
        apply(__MODULE__, rule_name, [number, locale])
      end

      def ordinal(number, locale, _function, _rule, plurals) do
        plural = Cldr.Number.Ordinal.plural_rule(number, locale)
        Map.get(plurals, plural)
      end

      def cardinal(number, locale, _function, _rule, plurals) do
        plural = Cldr.Number.Cardinal.plural_rule(number, locale)
        Map.get(plurals, plural)
      end

      def conditional(number, locale, function, rule, argument) do
        mod = number - (div(number, rule.divisor) * rule.divisor)
        if mod > 0 do
          do_rule(mod, locale, function, rule, argument)
        else
          ""
        end
      end
    end
  end
end