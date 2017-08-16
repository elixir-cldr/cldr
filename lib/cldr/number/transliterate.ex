defmodule Cldr.Number.Transliterate do
  @moduledoc """
  Transliteration for digits and separators.

  Transliterating a string is an expensive business.  First the string has to
  be exploded into its component graphemes.  Then for each grapheme we have
  to map to the equivalent in the other `{locale, number_system}`.  Then we
  have to reassemble the string.

  Effort is made to short circuit where possible. Transliteration is not
  required for any `{locale, number_system}` that is the same as `{"en",
  "latn"}` since the implementation uses this combination for the placeholders during
  formatting already. When short circuiting is possible (typically the en-*
  locales with "latn" number_system - the total number of short circuited
  locales is 211 of the 516 in CLDR) the overall number formatting is twice as
  fast than when formal transliteration is required.

  ### Configuring precompilation of digit transliterations

  This module includes `Cldr.Number.Transliterate.transliterate_digits/3` which transliterates
  digits between number systems.  For example from :arabic to :latn.  Since generating a
  transliteration map is slow, pairs of transliterations can be configured so that the
  transliteration map is created at compile time and therefore speeding up transliteration at
  run time.

  To configure these transliteration pairs, add the following to your `config.exs`:

      config :ex_cldr,
        precompile_transliterations: [{:latn, :arab}, {:arab, :thai}]

  Where each tuple in the list configures one transliteration map.  In this example, two maps are
  configured: from :latn to :thai and from :arab to :thai.

  A list of configurable number systems is returned by `Cldr.Number.System.systems_with_digits/0`.

  If a transliteration is requested between two number pairs that have not been configured for
  precompilation, a warning is logged.
  """
  alias Cldr.Number.System
  alias Cldr.Number.Symbol
  alias Cldr.Number.Format.Compiler

  @doc """
  Transliterates from latin digits to another number system's digits.

  Transliterates the latin digits 0..9 to their equivalents in
  another number system. Also transliterates the decimal and grouping
  separators as well as the plus, minus and exponent symbols. Any other character
  in the string will be returned "as is".

  * `sequence` is the string to be transliterated.

  * `locale` is any known locale, defaulting to `Cldr.get_current_locale/0`.

  * `number_system` is any known number system. If expressed as a `string` it
    is the actual name of a known number system. If epressed as an `atom` it is
    used as a key to look up a number system for the locale (the usual keys are
    `:default` and `:native` but :traditional and :finance are also part of the
    standard). See `Cldr.Number.System.number_systems_for/1` for a locale to
    see what number system types are defined. The default is `:default`.

  For available number systems see `Cldr.Number.System.number_systems/0`
  and `Cldr.Number.System.number_systems_for/1`.  Also see
  `Cldr.Number.Symbol.number_symbols_for/1`.


  ## Examples

      iex> Cldr.Number.Transliterate.transliterate("123556")
      "123556"

      iex> Cldr.Number.Transliterate.transliterate("123,556.000", "fr", :default)
      "123 556,000"

      iex> Cldr.Number.Transliterate.transliterate("123556", "th", :default)
      "123556"

      iex> Cldr.Number.Transliterate.transliterate("123556", "th", "thai")
      "๑๒๓๕๕๖"

      iex> Cldr.Number.Transliterate.transliterate("123556", "th", :native)
      "๑๒๓๕๕๖"

      iex> Cldr.Number.Transliterate.transliterate("Some number is: 123556", "th", "thai")
      "Some number is: ๑๒๓๕๕๖"
  """

  @spec transliterate(String.t, Cldr.locale, String.t) :: String.t
  def transliterate(sequence, locale \\ Cldr.get_current_locale(),
      number_system \\ System.default_number_system_type)

  # No transliteration required when the digits and separators as the same
  # as the ones we use in formatting.
  with {:ok, systems} <- System.number_systems_like("en", :latn) do
    Enum.each systems, fn {locale, system} ->
      def transliterate(sequence, unquote(locale), unquote(system)) do
        sequence
      end
    end
  end

  # Translate the number system type to a system and invoke the real
  # transliterator
  for locale <- Cldr.known_locales() do
    for {system_type, number_system} <- Cldr.Number.System.number_systems_for!(locale) do
      def transliterate(sequence, unquote(locale), unquote(system_type)) do
        transliterate(sequence, unquote(locale), unquote(number_system))
      end
    end
  end

  # For when the number system is provided as a string. We generate functions using
  # atom format so we need to convert but only to existing atoms
  def transliterate(sequence, locale, number_system) when is_binary(number_system) do
    {:ok, system} = System.system_name_from(number_system, locale)
    transliterate(sequence, locale, system)
  end

  # We can only transliterate if the target {locale, number_system} has defined
  # digits.  Some systems don't have digits, just rules.
  for {name, %{digits: _digits}} <- System.systems_with_digits do
    def transliterate(sequence, locale, number_system = unquote(name)) do
      sequence
      |> String.graphemes
      |> Enum.map(&transliterate_char(&1, locale, number_system))
      |> List.to_string
    end
  end

  # Functions to transliterate the symbols
  for locale <- Cldr.known_locales(),
      name <- System.number_system_names_for!(locale)
  do
    # Mapping for the grouping separator
    with {:ok, symbols} <- Symbol.number_symbols_for(locale, name) do
      defp transliterate_char(unquote(Compiler.placeholder(:group)), unquote(locale), unquote(name)) do
        unquote(symbols.group)
      end

      # Mapping for the decimal separator
      defp transliterate_char(unquote(Compiler.placeholder(:decimal)), unquote(locale), unquote(name)) do
        unquote(symbols.decimal)
      end

      # Mapping for the exponent
      defp transliterate_char(unquote(Compiler.placeholder(:exponent)), unquote(locale), unquote(name)) do
        unquote(symbols.exponential)
      end

      # Mapping for the plus sign
      defp transliterate_char(unquote(Compiler.placeholder(:plus)), unquote(locale), unquote(name)) do
        unquote(symbols.plus_sign)
      end

      # Mapping for the minus sign
      defp transliterate_char(unquote(Compiler.placeholder(:minus)), unquote(locale), unquote(name)) do
        unquote(symbols.minus_sign)
      end
    end
  end

  # Functions to transliterate the digits
  for {name, %{digits: digits}} <- System.systems_with_digits() do
    graphemes = String.graphemes(digits)

    for latin_digit <- 0..9 do
      grapheme = :lists.nth(latin_digit + 1, graphemes)
      latin_char = Integer.to_string(latin_digit)

      defp transliterate_char(unquote(latin_char), _locale, unquote(name)) do
        unquote(grapheme)
      end
    end

    # Any unknown mapping gets returned as is
    defp transliterate_char(digit, _locale, unquote(name)) do
      digit
    end
  end

  def transliterate(_digit, locale, number_system) do
    raise Cldr.UnknownLocaleError, "Locale/number system #{inspect locale}/ " <>
    "#{inspect number_system} is not known or the number system does not have digits (it may be algorithmic)"
  end

  @doc """
  Transliterates digits from one number system to another number system

  * `digits` is binary representation of a number

  * `from_system` and `to_system` are number system names in atom form.  See
  `Cldr.Number.System.systems_with_digits/0` for available number systems.

  ## Example

      iex> Cldr.Number.Transliterate.transliterate_digits "٠١٢٣٤٥٦٧٨٩", :arab, :latn
      "0123456789"
  """
  @spec transliterate_digits(binary, atom, atom) :: binary
  for {from_system, to_system} <- Application.get_env(:ex_cldr, :precompile_transliterations, []) do
    with {:ok, from} = System.number_system_digits(from_system),
         {:ok, to} = System.number_system_digits(to_system),
         map = System.generate_transliteration_map(from, to)
    do
      def transliterate_digits(digits, unquote(from_system), unquote(to_system)) do
        do_transliterate_digits(digits, unquote(Macro.escape(map)))
      end
    end
  end

  require Logger
  def transliterate_digits(digits, from_system, to_system) when is_binary(digits) do
    with {:ok, from} <- System.number_system_digits(from_system),
         {:ok, to} <- System.number_system_digits(to_system)
    do
      Logger.warn "Transliteration from number system #{inspect from_system} to " <>
      "#{inspect to_system} requires dynamic generation of a transliteration map for " <>
      "each function call which is slow. Please consider configuring this transliteration pair. " <>
      "See module docs for `Cldr.Number.Transliteration` for futher information."

      map = System.generate_transliteration_map(from, to)
      do_transliterate_digits(digits, map)
    else
      {:error, message} -> {:error, message}
    end
  end

  defp do_transliterate_digits(digits, map) do
    digits
    |> String.graphemes
    |> Enum.map(&Map.get(map, &1, &1))
    |> Enum.join
  end
end
