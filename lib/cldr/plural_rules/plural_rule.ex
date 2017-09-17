defmodule Cldr.Number.PluralRule do
  @moduledoc """
  Macro to define plural rule methods on a module.

  Used to generate functions for `Cldr.Number.Ordinal` and `
  Cldr.Number.Cardinal`
  """
  defmacro __using__(opts) do
    unless opts in [:cardinal, :ordinal] do
      raise ArgumentError,
        "Invalid option #{inspect opts}. :cardinal or :ordinal are the only valid options"
    end

    quote do
      alias  Cldr.Math
      import Cldr.Digits, only: [number_of_integer_digits: 1, remove_trailing_zeros: 1]
      import Cldr.Number.PluralRule.Compiler
      import Cldr.Number.PluralRule.Transformer

      @rules Cldr.Config.cldr_data_dir()
      |> Path.join("/plural_rules.json")
      |> File.read!
      |> Poison.decode!
      |> Map.get(Atom.to_string(unquote(opts)))

      @doc """
      The locales for which cardinal rules are defined
      """
      @rules_locales @rules
      |> Map.keys
      |> Enum.sort

      def known_locales do
        @rules_locales
      end

      @doc """
      The configured locales for which plural rules are defined

      This is the intersection of the Cldr.known_locales and the locales for
      which plural rules are defined.  There are many Cldr locales which
      don't have their own plural rules so this list is the intersection
      of Cldr's configured locales and those that have rules.
      """
      @configured_locales @rules_locales
      |> MapSet.new
      |> MapSet.intersection(MapSet.new(Cldr.known_locales()))
      |> MapSet.to_list
      |> Enum.sort

      def configured_locales do
        @configured_locales
      end

      @doc """
      The plural rules defined in CLDR.
      """
      @spec plural_rules :: Map.t
      def plural_rules do
        @rules
      end

      @doc """
      Pluralize a number using plural rules and a substition map.

      * `number` is an integer, float or Decimal

      * `locale` is any locale returned by `Cldr.known_locales()`

      * `substitutions` is a map that maps plural keys to a string.  Per the
      CLDR defintion of plural rules, the valid substitution keys are `:zero`,
      `:one`, `:two`, `:few`, `:many` and `:other`.

      See also `Cldr.Ordinal.plural_rule/3` and `Cldr.Cardinal.plural_rule/3`.

      ## Examples

          iex> Cldr.Number.Ordinal.pluralize 1, "en", %{one: "one"}
          "one"

          iex> Cldr.Number.Ordinal.pluralize 2, "en", %{one: "one"}
          nil

          iex> Cldr.Number.Ordinal.pluralize 2, "en", %{one: "one", two: "two"}
          "two"

          iex> Cldr.Number.Ordinal.pluralize 22, "en", %{one: "one", two: "two", other: "other"}
          "other"

          iex> Cldr.Number.Ordinal.pluralize Decimal.new(1), "en", %{one: "one"}
          "one"

          iex> Cldr.Number.Ordinal.pluralize Decimal.new(2), "en", %{one: "one"}
          nil

          iex> Cldr.Number.Ordinal.pluralize Decimal.new(2), "en", %{one: "one", two: "two"}
          "two"
      """
      @default_substitution :other
      @spec pluralize(Math.number_or_decimal, Locale.name, %{}) :: String.t | nil
      def pluralize(number, locale, %{} = substitutions) when is_number(number) do
        do_pluralize(number, locale, substitutions)
      end

      def pluralize(%Decimal{} = number, locale, %{} = substitutions) do
        do_pluralize(number, locale, substitutions)
      end

      defp do_pluralize(number, locale, %{} = substitutions) do
        plural = plural_rule(number, base_locale(locale))
        substitutions[plural] || substitutions[@default_substitution]
      end

      # Plural rules are only defined on the base locale
      defp base_locale(locale) do
        [base | rest] = String.split(locale, "-")
        base
      end

      @doc """
      Return the plural rules for a locale.

      The rules are returned in AST form after parsing.
      """
      @spec plural_rules_for(Cldr.locale) :: %{}
      def plural_rules_for(locale) do
        Enum.map plural_rules()[locale], fn({"pluralRule-count-" <> category, rule}) ->
          {:ok, definition} = parse(rule)
          {String.to_atom(category), definition}
        end
      end

      # Plural Operand Meanings as defined in CLDR plural rules and used
      # in the generated code
      #
      # Symbol  Value
      # n       absolute value of the source number (integer and decimals).
      # i       integer digits of n.
      # v       number of visible fraction digits in n, with trailing zeros.
      # w       number of visible fraction digits in n, without trailing zeros.
      # f       visible fractional digits in n, with trailing zeros.
      # t       visible fractional digits in n, without trailing zeros.

      @doc """
      Lookup the plural cardinal category for a given number in a given locale

      Identify which category (zero, one, two, few, many or other) a given number
      in a given locale fits into.  This category can then be used to format the
      number or currency
      """
      def plural_rule(number, locale \\ Cldr.get_current_locale(), rounding \\ Math.default_rounding())

      def plural_rule(string, locale, rounding) when is_binary(string) do
        plural_rule(Decimal.new(string), locale, rounding)
      end

      # Plural rule for an integer
      def plural_rule(number, locale, _rounding) when is_integer(number) do
        n = abs(number)
        i = n
        v = 0; w = 0; f = 0; t = 0
        do_plural_rule(locale, n, i, v, w, f, t)
      end

      # Plural rule for a float
      @lint {Credo.Check.Refactor.PipeChainStart, false}
      def plural_rule(number, locale, rounding)
      when is_float(number) and is_integer(rounding) and rounding > 0 do
        plural_rule(Decimal.new(number), locale, rounding)
        # n = Float.round(abs(number), rounding)
        # i = trunc(n)
        # v = rounding
        # t = fraction_as_integer(n - i)
        # w = number_of_integer_digits(t)
        # f = trunc(t * :math.pow(10, v - w))
        # do_plural_rule(locale, n, i, v, w, f, t)
      end

      # Plural rule for a %Decimal{}
      def plural_rule(%Decimal{} = number, locale, rounding)
      when is_integer(rounding) and rounding > 0 do
        # n absolute value of the source number (integer and decimals).
        n = Decimal.abs(number)

        # i integer digits of n.
        i = Decimal.round(n, 0, :floor)

        # v number of visible fraction digits in n, with trailing zeros.
        v = abs(n.exp)

        # f visible fractional digits in n, with trailing zeros.
        f = n
        |> Decimal.sub(i)
        |> Decimal.mult(Decimal.new(:math.pow(10, v)))
        |> Decimal.round(0, :floor)
        |> Decimal.to_integer

        #   t visible fractional digits in n, without trailing zeros.
        t = remove_trailing_zeros(f)

        # w number of visible fraction digits in n, without trailing zeros.
        w = number_of_integer_digits(t)

        i = Decimal.to_integer(i)
        n = Math.to_float(n)

        # IO.puts "n: #{inspect n}; i: #{inspect i}; v: #{inspect v}; w: #{inspect w}; f: #{inspect f}; t: #{inspect t}"
        do_plural_rule(locale, n, i, v, w, f, t)
      end
    end
  end
end
