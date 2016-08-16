defmodule Cldr.Number.System do
  alias Cldr.File

  defstruct [:name, :type, :digits, :rules]
    
  @default_number_system  :default
 
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
    @default_number_system
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
  another number system. Any non-digit in the string will be returned
  "as is".
  
  For available number systems see `Cldr.Number.System.number_systems/0`
  and `Cldr.Number.System.number_systems_for/1`
  
  ## Examples
  
      iex> Cldr.Number.System.transliterate "123556", "thai"
      "๑๒๓๕๕๖"
      
      iex> Cldr.Number.System.transliterate "Some number is: 123556", "thai"
      "Some number is: ๑๒๓๕๕๖"
  """
  @spec transliterate(String.t, String.t) :: String.t
  def transliterate(sequence, number_system) do
    Enum.map(String.graphemes(sequence), &transliterate_digit(&1, number_system))
    |> List.to_string
  end
  
  # Generate the transliteration functions that map one latin digit to
  # any other number system digit.  
  Enum.each @number_systems, fn {name, system} ->
    if digits = system.digits do
      graphemes = String.graphemes(digits)
      Enum.each 0..9, fn (latin_digit) ->
        defp transliterate_digit(unquote(Integer.to_string(latin_digit)), unquote(name)) do
          unquote(:lists.nth(latin_digit + 1, graphemes))
        end
      end
    end
    # Any unknown mapping gets returned as is
    defp transliterate_digit(digit, unquote(name)) do
      digit
    end
  end
end 