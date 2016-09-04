defmodule Cldr.Number.System do
  @moduledoc """
  A number system defines the digits (if they exist in this number system) or
  or rules (if the number system does not have decimal digits).

  The system name is also used as a key to define the separators that are used
  when formatting a number is this number_system. See
  `Cldr.Number.Symbol.number_symbols_for/2`.
  """

  alias Cldr.File
  alias Cldr.Number
  alias Cldr.Number.Symbol

  defstruct [:name, :type, :digits, :rules]

  @default_number_system_type  :default
  @default_number_system       "latn"

  @type name :: atom
  @type types :: :default | :native | :traditional | :finance

  @doc """
  Return the default number system type name.

  Currently this is `:default`.  Note that this is
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
  @number_system_names @number_systems
  |> Map.keys
  |> Enum.sort

  @spec number_system_names :: [String.t]
  def number_system_names do
    @number_system_names
  end

  @systems_with_digits Enum.reject @number_systems, fn {_name, system} ->
    is_nil(system.digits)
  end

  @doc """
  Number systems that ahve their own digit characters defined.
  """
  def systems_with_digits do
    @systems_with_digits
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
    systems = File.read(:number_systems, locale)
    names = systems
    |> Enum.map(fn {_type, system} -> system.name end)
    |> Enum.uniq

    def number_systems_for(unquote(locale)) do
      unquote(Macro.escape(systems))
    end

    def number_system_names_for(unquote(locale)) do
      unquote(names)
    end
  end

  def number_systems_for(locale) do
    raise Cldr.UnknownLocaleError, "The locale #{inspect locale} is not known."
  end

  def number_system_names_for(locale) do
    raise Cldr.UnknownLocaleError, "The locale #{inspect locale} is not known."
  end

  def number_system_for(locale, system_type) when is_atom(system_type) do
    number_systems_for(locale)[system_type]
  end

  def number_system_for(locale, system_name) do
    locale
    |> Number.System.number_systems_for
    |> Map.values
    |> Enum.uniq
    |> Enum.filter(&(&1.name == system_name))
    |> List.first
  end

  def system_name_from(system_name, locale \\ Cldr.get_locale())
  def system_name_from(system_name, locale) when is_atom(system_name) do
    number_systems_for(locale)[system_name].name
  end

  def system_name_from(system_name, _locale) when is_binary(system_name) do
    system_name
  end

  @doc """
  Locale and number systems that have the same digits and separators as the
  supplied one.

  Transliterating between locale & number systems is expensive.  To avoid
  unncessary transliteration we look for locale and number systems that have
  the same digits and separators.  Typically we are comparing to locale "en"
  and number system "latn" since this is what the number formatting routines use
  as placeholders.
  """
  @lint {Credo.Check.Refactor.Nesting, false}
  def number_systems_like(locale, number_system) do
    digits = number_system_for(locale, number_system).digits
    symbols = Symbol.number_symbols_for(locale, number_system)

    likes = Enum.map(Cldr.known_locales(), fn this_locale ->
      Enum.reduce number_system_names_for(locale), [], fn this_system, acc ->
        case number_system_for(this_locale, this_system) do
        nil ->
          acc
        system ->
          these_digits = system.digits
          these_symbols = Symbol.number_symbols_for(this_locale, this_system)
          if digits == these_digits && symbols == these_symbols do
            acc ++ {this_locale, this_system}
          end
        end
      end
    end)
    likes |> Enum.reject(&(is_nil(&1) || &1 == []))
  end
end
