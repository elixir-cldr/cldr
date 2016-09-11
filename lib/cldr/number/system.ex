defmodule Cldr.Number.System do
  @moduledoc """
  A number system defines the digits (if they exist in this number system) or
  or rules (if the number system does not have decimal digits).

  The system name is also used as a key to define the separators that are used
  when formatting a number is this number_system. See
  `Cldr.Number.Symbol.number_symbols_for/2`.
  """

  alias Cldr.Locale
  alias Cldr.Number.Symbol

  @default_number_system_type  :default
  @default_number_system       :latn
  @number_system_types         [:default, :native, :traditional, :finance]

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
  Returns a list of the known number system types
  """
  def number_system_types do
    @number_system_types
  end

  @doc """
  Return a map of all CLDR number systems and definitions.

  ## Example

      iex> Cldr.Number.System.number_systems |> Enum.count
      74
  """
  @spec number_systems :: %{}
  @number_systems Path.join(Cldr.Config.data_dir(), "number_systems.json")
  |> File.read!
  |> Poison.decode!
  |> Cldr.Map.atomize_keys
  |> Enum.map(fn {k, v} -> {k, %{v | type: String.to_atom(v.type)}} end)
  |> Enum.into(%{})

  def number_systems do
    @number_systems
  end

  @doc """
  The unique Cldr number systems names,

  ## Example

      iex> Cldr.Number.System.number_system_names
      [:ahom, :arab, :arabext, :armn, :armnlow, :bali, :beng, :brah, :cakm,
      :cham, :cyrl, :deva, :ethi, :fullwide, :geor, :grek, :greklow, :gujr,
      :guru, :hanidays, :hanidec, :hans, :hansfin, :hant, :hantfin, :hebr,
      :hmng, :java, :jpan, :jpanfin, :kali, :khmr, :knda, :lana, :lanatham,
      :laoo, :latn, :lepc, :limb, :mathbold, :mathdbl, :mathmono, :mathsanb,
      :mathsans, :mlym, :modi, :mong, :mroo, :mtei, :mymr, :mymrshan,
      :mymrtlng, :nkoo, :olck, :orya, :osma, :roman, :romanlow, :saur, :shrd,
      :sind, :sinh, :sora, :sund, :takr, :talu, :taml, :tamldec, :telu, :thai,
      :tibt, :tirh, :vaii, :wara]
  """
  @number_system_names @number_systems |> Map.keys |> Enum.sort
  @spec number_system_names :: [String.t]
  def number_system_names do
    @number_system_names
  end

  @systems_with_digits Enum.reject @number_systems, fn {_name, system} ->
    is_nil(system[:digits])
  end

  @doc """
  Number systems that have their own digit characters defined.
  """
  def systems_with_digits do
    @systems_with_digits
  end

  @doc """
  The number systems available for a locale.

  ## Examples

      iex> Cldr.Number.System.number_systems_for "en"
      %{default: :latn, native: :latn}

      iex> Cldr.Number.System.number_systems_for "th"
      %{default: :latn, native: :thai}
  """
  @spec number_systems_for(Cldr.locale) :: %{}
  def number_systems_for(locale) do
    Locale.get_locale(locale)[:number_systems]
  end

  @spec number_system_names_for(Cldr.locale) :: [String.t]
  def number_system_names_for(locale) do
    Locale.get_locale(locale)[:number_systems]
    |> Map.values
    |> Enum.uniq
  end

  def number_system_for(locale, system_name) do
    system_name = system_name_from(system_name, locale)
    number_systems()[system_name]
  end

  def system_name_from(system_name, locale \\ Cldr.get_locale())
  def system_name_from(system_name, locale) when is_binary(system_name) do
    try do
      system_name_from(String.to_existing_atom(system_name), locale)
    rescue
      ArgumentError ->
          raise Cldr.UnknownLocaleError,
            "The requested number system #{inspect system_name} is not known."
    end
  end

  def system_name_from(system_name, locale) when is_atom(system_name) do
    if system = number_systems_for(locale)[system_name] do
      system
    else
      system_name
    end
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
    digits = number_system_for(locale, number_system)[:digits]
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
