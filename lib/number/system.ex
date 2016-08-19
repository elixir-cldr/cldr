defmodule Cldr.Number.System do
  alias Cldr.Number.Format.Compiler
  alias Cldr.File
  
  defstruct [:name, :type, :digits, :rules]
    
  @default_number_system_type  :default
  @default_number_system       "latn"
 
  @type name :: atom
  
  @moduledoc """
  Cldr Number Systems definitions and reflection methods.
  """
  
  @doc """
  Return the default number system type name.
  
  Currently this is "default".  Note that this is 
  not the number system itself but the type of the
  number system.  It can be used to find the 
  default number system for a given locale with
  `number_systems_for(locale)[default_number_system()]`.
  
  ## Example
  
      iex> Cldr.Number.System.default_number_system_type
      :default
  """
  def default_number_system_type do
    @default_number_system_type
  end
   
  @doc """
  Return a map of all CLDR number systems and definitions.
  
  ## Example
  
      iex> Cldr.Number.System.number_systems |> Enum.count
      74
  """
  @spec number_systems :: %{}
  @number_systems File.read(:number_systems)
  def number_systems do
    @number_systems
  end
  
  @doc """
  The unique Cldr number systems names,
  
  ## Example
  
      iex> Cldr.Number.System.number_system_names
      ["ahom", "arab", "arabext", "armn", "armnlow", 
      "bali", "beng", "brah", "cakm", "cham", "cyrl", 
      "deva", "ethi", "fullwide", "geor", "grek", 
      "greklow", "gujr", "guru", "hanidays", "hanidec", 
      "hans", "hansfin", "hant", "hantfin", "hebr", 
      "hmng", "java", "jpan", "jpanfin", "kali", "khmr", 
      "knda", "lana", "lanatham", "laoo", "latn", "lepc", 
      "limb", "mathbold", "mathdbl", "mathmono", 
      "mathsanb", "mathsans", "mlym", "modi", "mong", 
      "mroo", "mtei", "mymr", "mymrshan", "mymrtlng", 
      "nkoo", "olck", "orya", "osma", "roman", "romanlow", 
      "saur", "shrd", "sind", "sinh", "sora", "sund", 
      "takr", "talu", "taml", "tamldec", "telu", "thai", 
      "tibt", "tirh", "vaii", "wara"]  
  """
  @number_system_names Map.keys(@number_systems) |> Enum.sort
  @spec number_system_names :: [String.t]
  def number_system_names do
    @number_system_names
  end
  
  @doc """
  The number systems available for a locale.
  
  ## Examples
  
      iex> Cldr.Number.System.number_systems_for "en"
      %{default: %Cldr.Number.System{digits: "0123456789", name: "latn", rules: nil, type: :numeric},
      native: %Cldr.Number.System{digits: "0123456789", name: "latn", rules: nil, type: :numeric}}
      
      iex> Cldr.Number.System.number_systems_for "th"
      %{default: %Cldr.Number.System{digits: "0123456789", name: "latn", rules: nil, type: :numeric},
      native: %Cldr.Number.System{digits: "๐๑๒๓๔๕๖๗๘๙", name: "thai", rules: nil,
      type: :numeric}}
  """
  @spec number_systems_for(Cldr.locale) :: %{}
  @spec number_system_names_for(Cldr.locale) :: [String.t]  
  Enum.each Cldr.known_locales, fn (locale) ->
    number_systems = File.read(:number_systems, locale) 
    number_system_names = Enum.map(number_systems, fn {_type, system} -> system.name end) |> Enum.uniq
    
    def number_systems_for(unquote(locale)) do
      unquote(Macro.escape(number_systems))
    end
    
    def number_system_names_for(unquote(locale)) do
      unquote(number_system_names)
    end
  end
  
  def number_systems_for(locale) do
    raise ArgumentError, "Locale #{inspect locale} is not known."
  end
  
  def number_system_names_for(locale) do
    raise ArgumentError, "Locale #{inspect locale} is not known."
  end
  
  @doc """
  Transliterates from latin digits to another number system's digits.
  
  Transliterates the latin digits 0..9 to their equivalents in
  another number system. Also transliterates the decimal and grouping
  separators as well as the plus and minus sign. Any other character
  in the string will be returned "as is".
  
  * `locale` is any known locale, defaulting to `Cldr.default_locale()`.
  
  * `number_system` is any known number system.  If expressed as a
  `binary` it is the actual name of a known number system.  If 
  epressed as an atom it is used as a key to look up a number system for
  the locale (the usual keys are `:default` and `:native`) but definitions
  vary.  See `Cldr.Number.System.number_systems_for/1` for a locale
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
  def transliterate(sequence, locale \\ Cldr.default_locale(), number_system \\ @default_number_system_type)
  
  # Maps the system type key to the actual type for transliteration
  def transliterate(sequence, locale, number_system) when is_atom(number_system) do
    transliterate(sequence, locale, Map.get(Cldr.Number.System.number_systems_for(locale), number_system).name)
  end
  
  # Convert common types to string for convenience.
  def transliterate(sequence, locale, number_system) when is_integer(sequence) do
    transliterate(Integer.to_string(sequence), locale, number_system)
  end
  def transliterate(sequence, locale, number_system) when is_float(sequence) do
    transliterate(Float.to_string(sequence), locale, number_system)
  end
  def transliterate(sequence = %Decimal{}, locale, number_system) do
    transliterate(Decimal.to_string(sequence), locale, number_system)
  end

  # Generate the transliteration functions that map one latin digit to
  # any other number system digit. Only applicable to number systems that
  # have digits (some don't because they are rule based).
  systems_with_digits = Enum.reject @number_systems, fn {_name, system} -> 
    is_nil(system.digits)
  end
  
  Enum.each systems_with_digits, fn {name, %{digits: digits}} ->
    graphemes = String.graphemes(digits)
    
    def transliterate(sequence, locale, number_system = unquote(name)) do
      Enum.map(String.graphemes(sequence), &transliterate_char(&1, locale, number_system))
      |> List.to_string
    end

    # Mapping for each digit character
    Enum.each 0..9, fn (latin_digit) ->
      grapheme = :lists.nth(latin_digit + 1, graphemes)
      defp transliterate_char(unquote(Integer.to_string(latin_digit)), _locale, unquote(name)) do
        unquote(grapheme)
      end
    end
    
    # Mapping for the grouping separator
    defp transliterate_char(unquote(Compiler.placeholder(:group)), locale, unquote(name)) do
      Cldr.Number.Symbol.number_symbols_for(locale, unquote(name)).group
    end
    
    # Mapping for the decimal separator
    defp transliterate_char(unquote(Compiler.placeholder(:decimal)), locale, unquote(name)) do
      Cldr.Number.Symbol.number_symbols_for(locale, unquote(name)).decimal
    end

    # Mapping for the exponent
    defp transliterate_char(unquote(Compiler.placeholder(:exponent)), locale, unquote(name)) do
      Cldr.Number.Symbol.number_symbols_for(locale, unquote(name)).exponent
    end
    
    # Mapping for the plus sign
    defp transliterate_char(unquote(Compiler.placeholder(:plus)), locale, unquote(name)) do
      Cldr.Number.Symbol.number_symbols_for(locale, unquote(name)).plus_sign
    end
    
    # Mapping for the minus sign
    defp transliterate_char(unquote(Compiler.placeholder(:minus)), locale, unquote(name)) do
      Cldr.Number.Symbol.number_symbols_for(locale, unquote(name)).minus_sign
    end
    
    # Any unknown mapping gets returned as is
    defp transliterate_char(digit, _locale, unquote(name)) do
      digit
    end
  end
  
  def transliterate(_digit, _locale, number_system) do
    raise ArgumentError, "Number system #{inspect number_system} is not known."
  end
end 