defmodule Cldr.Number.PluralRule do
  @moduledoc """
  Macro to define plural rule methods on a module.

  Used to generate plural rule functions for
  `Cldr.Number.Ordinal` and `Cldr.Number.Cardinal`.
  """
  defmacro __using__(opts) do
    unless opts in [:cardinal, :ordinal] do
      raise ArgumentError,
            "Invalid option #{inspect(opts)}. :cardinal or :ordinal are the only valid options"
    end

    quote location: :keep do
      alias Cldr.Math
      alias Cldr.LanguageTag
      alias Cldr.Locale

      import Cldr.Digits,
        only: [number_of_integer_digits: 1, remove_trailing_zeros: 1, fraction_as_integer: 2]

      import Cldr.Number.PluralRule.Compiler
      import Cldr.Number.PluralRule.Transformer

      @module_name Atom.to_string(unquote(opts)) |> String.capitalize()

      @rules Cldr.Config.cldr_data_dir()
             |> Path.join("/plural_rules.json")
             |> File.read!()
             |> Cldr.Config.json_library().decode!
             |> Map.get(Atom.to_string(unquote(opts)))

      @rules_locales @rules
                     |> Map.keys()
                     |> Enum.sort()

      @doc """
      The locales for which plural rules are defined
      """
      def available_locale_names do
        @rules_locales
      end

      @known_locale_names @rules_locales
                          |> MapSet.new()
                          |> MapSet.intersection(MapSet.new(Cldr.known_locale_names()))
                          |> MapSet.to_list()
                          |> Enum.sort()

      @doc """
      The configured locales for which plural rules are defined.

      Returns the intersection of `Cldr.known_locale_names/0` and
      the locales for which #{@module_name} plural rules are defined.

      There are many `Cldr` locales which don't have their own plural
      rules so this list is the intersection of `Cldr`'s configured
      locales and those that have rules.
      """
      @spec known_locale_names :: [Locale.locale_name(), ...]
      def known_locale_names do
        @known_locale_names
      end

      @doc """
      Returns all the plural rules defined in CLDR.
      """
      @spec plural_rules :: Map.t()
      def plural_rules do
        @rules
      end

      @doc """
      Pluralize a number using plural rules and a substition map.

      * `number` is an integer, float or Decimal

      * `locale` is any locale returned by `Cldr.Locale.new!/1`

      * `substitutions` is a map that maps plural keys to a string.
        The valid substitution keys are `:zero`, `:one`, `:two`,
        `:few`, `:many` and `:other`.

      See also `Cldr.#{@module_name}.plural_rule/3`.

      ## Examples

          iex> Cldr.Number.#{@module_name}.pluralize 1,
          ...> Locale.new("en"), %{one: "one"}
          "one"

          iex> Cldr.Number.#{@module_name}.pluralize 2,
          ...> Locale.new("en"), %{one: "one"}
          nil

          iex> Cldr.Number.#{@module_name}.pluralize 2,
          ...> Locale.new("en"), %{one: "one", two: "two"}
          "two"

          iex> Cldr.Number.#{@module_name}.pluralize 22, Locale.new("en"),
          ...> %{one: "one", two: "two", other: "other"}
          "other"

          iex> Cldr.Number.#{@module_name}.pluralize Decimal.new(1),
          ...> Locale.new("en"), %{one: "one"}
          "one"

          iex> Cldr.Number.#{@module_name}.pluralize Decimal.new(2),
          ...> Locale.new("en"), %{one: "one"}
          nil

          iex> Cldr.Number.#{@module_name}.pluralize Decimal.new(2),
          ...> Locale.new("en"), %{one: "one", two: "two"}
          "two"

      """
      @default_substitution :other
      @spec pluralize(Math.number_or_decimal(), LanguageTag.t(), %{}) :: any()
      def pluralize(number, %LanguageTag{} = locale, %{} = substitutions)
          when is_number(number) do
        do_pluralize(number, locale, substitutions)
      end

      def pluralize(%Decimal{} = number, %LanguageTag{} = locale, %{} = substitutions) do
        do_pluralize(number, locale, substitutions)
      end

      defp do_pluralize(number, %LanguageTag{} = locale, %{} = substitutions) do
        plural = plural_rule(number, locale)
        substitutions[plural] || substitutions[@default_substitution]
      end

      @doc """
      Return the plural rules for a locale.

      The rules are returned in AST form after parsing. This function
      is primarilty to support `Cldr.Gettext`.
      """
      @spec plural_rules_for(Locale.locale_name()) :: [{atom(), list()}, ...]
      def plural_rules_for(locale_name) do
        Enum.map(plural_rules()[locale_name], fn {"pluralRule-count-" <> category, rule} ->
          {:ok, definition} = parse(rule)
          {String.to_atom(category), definition}
        end)
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
      Return the plural key for a given number in a given locale

      Returns which plural key (`:zero`, `:one`, `:two`, `:few`,
      `:many` or `:other`) a given number fits into within the
      context of a given locale.

      Note that these key names should not be interpreted
      literally.  For example, the key returned from
      `Cldr.Number.Ordinal.plural_rule(0, "en")` is actually
      `:other`, not `:zero`.

      This key can then be used to format a number, date, time, unit,
      list or other content in a plural-sensitive way.

      ## Examples

          iex> Cldr.Number.#{@module_name}.plural_rule 0, "fr"
          :other

          iex> Cldr.Number.#{@module_name}.plural_rule 1, "en"
          :one

      """
      @spec plural_rule(Math.number_or_decimal(), Locale.locale_name() | LanguageTag.t(), atom()) ::
              :zero | :one | :two | :few | :many | :other

      def plural_rule(
            number,
            locale \\ Cldr.get_current_locale(),
            rounding \\ Math.default_rounding()
          )

      def plural_rule(number, locale_name, rounding) when is_binary(locale_name) do
        with {:ok, locale} <- Cldr.Locale.new(locale_name) do
          plural_rule(number, locale, rounding)
        end
      end

      def plural_rule(number, locale, rounding) when is_binary(number) do
        plural_rule(Decimal.new(number), locale, rounding)
      end

      # Plural rule for an integer
      def plural_rule(number, locale, _rounding) when is_integer(number) do
        n = abs(number)
        i = n
        v = 0
        w = 0
        f = 0
        t = 0
        do_plural_rule(locale, n, i, v, w, f, t)
      end

      # Plural rule for a float
      def plural_rule(number, locale, rounding)
          when is_float(number) and is_integer(rounding) and rounding > 0 do
        # Testing shows that this is working but just in case we
        # can go back to casting the number to a decimal and
        # using that path
        # plural_rule(Decimal.new(number), locale, rounding)
        n = Float.round(abs(number), rounding)
        i = trunc(n)
        v = rounding
        t = fraction_as_integer(n - i, rounding)
        w = number_of_integer_digits(t)
        f = trunc(t * Math.power_of_10(v - w))
        do_plural_rule(locale, n, i, v, w, f, t)
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
        f =
          n
          |> Decimal.sub(i)
          |> Decimal.mult(Decimal.new(Math.power_of_10(v)))
          |> Decimal.round(0, :floor)
          |> Decimal.to_integer()

        #   t visible fractional digits in n, without trailing zeros.
        t = remove_trailing_zeros(f)

        # w number of visible fraction digits in n, without trailing zeros.
        w = number_of_integer_digits(t)

        i = Decimal.to_integer(i)
        n = Math.to_float(n)

        do_plural_rule(locale, n, i, v, w, f, t)
      end
    end
  end
end
