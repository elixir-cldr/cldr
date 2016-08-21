defmodule Cldr.Number.Transliterate do
  @moduledoc """
  ## Transliterations for digits and separators.
  
  Transliterating a string is an expensive business.  First the string has to
  be exploded into its component graphemes.  Then for each grapheme we have 
  to map to the equivalent in the other `{locale, number_system}`.  Then we 
  have to reassemble the string.
  
  Effort is made to short circuit where possible. Transliteration is not
  required for any `{locale, number_system}` that is the same as `{"en",
  "latn"}` since the implementation usese this for the placeholders during
  formatting already. When short circuiting is possible (typically the en-*
  locales with "latn" number_system - the total number of short circuited
  locales is 211 of the 511 in CLDR) the overall number formatting is twice as
  fast than when formal transliteration is required.
  """
  alias Cldr.Number.System
  alias Cldr.Number.Symbol
  alias Cldr.Number.Format.Compiler
  
  @doc """
  Transliterates from latin digits to another number system's digits.
  
  Transliterates the latin digits 0..9 to their equivalents in
  another number system. Also transliterates the decimal and grouping
  separators as well as the plus and minus sign. Any other character
  in the string will be returned "as is".
  
  * `sequence` is the string to be transliterated.
  
  * `locale` is any known locale, defaulting to `Cldr.default_locale()`.
  
  * `number_system` is any known number system.  If expressed as a
  `string` it is the actual name of a known number system.  If 
  epressed as an `atom` it is used as a key to look up a number system for
  the locale (the usual keys are `:default` and `:native` but definitions
  vary).  See `Cldr.Number.System.number_systems_for/1` for a locale
  to see what number system types are defined.  The default is `:default`.
  
  For available number systems see `Cldr.Number.System.number_systems/0`
  and `Cldr.Number.System.number_systems_for/1`.  Also see 
  `Cldr.Number.Symbol.number_symbols_for/1`.

  
  ## Examples
  
      iex> Cldr.Number.System.transliterate("123556")
      "123556"
      
      iex> Cldr.Number.System.transliterate("123,556.000", "fr", :default) 
      "123 556,000"
      
      iex> Cldr.Number.System.transliterate("123556", "th", :default)
      "123556"
  
      iex> Cldr.Number.System.transliterate("123556", "th", "thai")
      "๑๒๓๕๕๖"
      
      iex> Cldr.Number.System.transliterate("123556", "th", :native)
      "๑๒๓๕๕๖"
      
      iex> Cldr.Number.System.transliterate("Some number is: 123556", "th", "thai")
      "Some number is: ๑๒๓๕๕๖"
      
      iex(5)> Cldr.Number.System.transliterate(12345, "th", "thai")
      "๑๒๓๔๕"
      
      iex(6)> Cldr.Number.System.transliterate(12345.0, "th", "thai")
      "๑๒๓๔๕.๐"
      
      iex(7)> Cldr.Number.System.transliterate(Decimal.new(12345.0), "th", "thai")
      "๑๒๓๔๕.๐"
  """
  
  @spec transliterate(String.t | number, Cldr.locale, String.t) :: String.t
  def transliterate(sequence, locale \\ Cldr.default_locale(), number_system \\ System.default_number_system_type)
  
  # Maps the system type key to the actual type for transliteration
  def transliterate(sequence, locale, number_system) when is_atom(number_system) do
    transliterate(sequence, locale, System.number_system_for(locale, number_system).name)
  end
  
  # No transliteration required when the digits and separators as the same
  # as the ones we use in formatting.
  Enum.each System.number_systems_like("en", "latn"), fn {locale, system} ->
    def transliterate(sequence, unquote(locale), unquote(system)) do
      sequence
    end
  end
  
  # We can only transliterate if the target {locale, number_system} has defined
  # digits.  Some systems don't have digits, just rules.
  Enum.each System.systems_with_digits(), fn {name, %{digits: _digits}} ->
    def transliterate(sequence, locale, number_system = unquote(name)) do
      sequence
      |> String.graphemes
      |> Enum.map(&transliterate_char(&1, locale, number_system))
      |> List.to_string
    end
  end

  # Functions to transliterate the symbols
  Enum.each Cldr.known_locales(), fn locale ->
    Enum.each System.number_system_names_for(locale), fn name ->
      if Symbol.number_symbols_for(locale, name) do
        # Mapping for the grouping separator
        @group Symbol.number_symbols_for(locale, name).group
        defp transliterate_char(unquote(Compiler.placeholder(:group)), unquote(locale), unquote(name)) do
          @group
        end

        # Mapping for the decimal separator
        @decimal Symbol.number_symbols_for(locale, name).decimal
        defp transliterate_char(unquote(Compiler.placeholder(:decimal)), unquote(locale), unquote(name)) do
          @decimal
        end

        # Mapping for the exponent
        @exponent Symbol.number_symbols_for(locale, name).exponential
        defp transliterate_char(unquote(Compiler.placeholder(:exponent)), unquote(locale), unquote(name)) do
          @exponent
        end

        # Mapping for the plus sign
        @plus Symbol.number_symbols_for(locale, name).plus_sign
        defp transliterate_char(unquote(Compiler.placeholder(:plus)), unquote(locale), unquote(name)) do
          @plus
        end

        # Mapping for the minus sign
        @minus Symbol.number_symbols_for(locale, name).minus_sign
        defp transliterate_char(unquote(Compiler.placeholder(:minus)), unquote(locale), unquote(name)) do
          @minus
        end
      end
    end
  end
  
  # Functions to transliterate the digits
  Enum.each System.systems_with_digits(), fn {name, %{digits: digits}} ->
    graphemes = String.graphemes(digits)
    
    Enum.each 0..9, fn (latin_digit) ->
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
    raise ArgumentError, """
    Locale #{inspect locale} or number system #{inspect number_system} 
    (or the combination of the two) is not known.
    """
  end
end