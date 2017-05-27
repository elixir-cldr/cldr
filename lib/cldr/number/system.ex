defmodule Cldr.Number.System do
  @moduledoc """
  Functions to manage number systems which describe the numbering characteristics for a locale.

  A number system defines the digits (if they exist in this number system) or
  or rules (if the number system does not have decimal digits).

  The system name is also used as a key to define the separators that are used
  when formatting a number is this number_system. See
  `Cldr.Number.Symbol.number_symbols_for/2`.
  """

  alias Cldr.Locale
  alias Cldr.Number.Symbol

  @default_number_system_type  :default
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
  Returns a list of the known number system types.

  Note that not all locales support all number system types.
  `:default` is available for all locales, the other types
  configured only in certain locales.

  ## Example

      iex> Cldr.Number.System.number_system_types
      [:default, :native, :traditional, :finance]
  """
  def number_system_types do
    @number_system_types
  end

  @doc """
  Return a map of all CLDR number systems and definitions.

  ## Example

      iex> Cldr.Number.System.number_systems |> Enum.count
      77
  """
  @spec number_systems :: %{}
  @number_systems Path.join(Cldr.Config.cldr_data_dir(), "number_systems.json")
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
      [:adlm, :ahom, :arab, :arabext, :armn, :armnlow, :bali,
      :beng, :bhks, :brah, :cakm, :cham, :cyrl, :deva, :ethi,
      :fullwide, :geor, :grek, :greklow, :gujr, :guru, :hanidays,
      :hanidec, :hans, :hansfin, :hant, :hantfin, :hebr, :hmng,
      :java, :jpan, :jpanfin, :kali, :khmr, :knda, :lana, :lanatham,
      :laoo, :latn, :lepc, :limb, :mathbold, :mathdbl, :mathmono,
      :mathsanb, :mathsans, :mlym, :modi, :mong, :mroo, :mtei,
      :mymr, :mymrshan, :mymrtlng, :newa, :nkoo, :olck, :orya,
      :osma, :roman, :romanlow, :saur, :shrd, :sind, :sinh, :sora,
      :sund, :takr, :talu, :taml, :tamldec, :telu, :thai, :tibt,
      :tirh, :vaii, :wara]
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
  Returns the number systems available for a locale
  or `{:error, message}` if the locale is not known.

  * `locale` is any valid locale returned by `Cldr.known_locales()`

  ## Examples

      iex> Cldr.Number.System.number_systems_for "en"
      %{default: :latn, native: :latn}

      iex> Cldr.Number.System.number_systems_for "th"
      %{default: :latn, native: :thai}

      iex> Cldr.Number.System.number_systems_for "zz"
      {:error, {Cldr.UnknownLocaleError, "The locale \\"zz\\" is not known"}}
  """
  @spec number_systems_for(Locale.name | %Locale{}) :: Map.t
  def number_systems_for(locale) when is_binary(locale) do
    locale
    |> Cldr.get_locale
    |> number_systems_for
  end

  def number_systems_for(%Locale{} = locale) do
    Map.get(locale, :number_systems)
  end

  def number_systems_for({:error, _} = error) do
    error
  end

  @doc """
  Returns the number systems available for a locale
  or raises if the locale is not known.

  * `locale` is any valid locale returned by `Cldr.known_locales()`

  ## Examples

      iex> Cldr.Number.System.number_systems_for! "en"
      %{default: :latn, native: :latn}

      iex> Cldr.Number.System.number_systems_for! "th"
      %{default: :latn, native: :thai}
  """
  @spec number_systems_for!(%Locale{}) :: Map.t
  def number_systems_for!(locale) do
    case number_systems_for(locale) do
      {:error, {exception, message}} ->
        raise exception, message
      systems ->
        systems
    end
  end

  @doc """
  Returns the actual number system from a number system type.

  * `locale` is any valid locale returned by `Cldr.known_locales()`

  * `system_name` is any name of name type returned by
  `Cldr.Number.System.number_system_types/0`

  This function will decode a number system type into the actual
  number system.  If the number system provided can't be decoded
  it is returned as is.

  ## Examples

      iex> Cldr.Number.System.number_system_for "th", :default
      %{digits: "0123456789", type: :numeric}

      iex> Cldr.Number.System.number_system_for "th", :native
      %{digits: "๐๑๒๓๔๕๖๗๘๙", type: :numeric}

      iex> Cldr.Number.System.number_system_for "th", :latn
      %{digits: "0123456789", type: :numeric}

      iex> Cldr.Number.System.number_system_for "en", :default
      %{digits: "0123456789", type: :numeric}

      iex> Cldr.Number.System.number_system_for "en", :finance
      {:error, {Cldr.UnknownNumberSystemError, "The number system :finance is not known"}}

      iex> Cldr.Number.System.number_system_for "en", :native
      %{digits: "0123456789", type: :numeric}
  """
  def number_system_for(locale, system_name) do
    case system_name_from(system_name, locale) do
      {:error, _} = error ->
        error
      system_name ->
        number_systems()[system_name]
    end
  end

  @doc """
  Returns the names of the number systems available for
  a locale or an `{:error, message}` tuple if the locale
  is not known.

  * `locale` is any valid locale returned by `Cldr.known_locales()`

  ## Examples

      iex> Cldr.Number.System.number_system_names_for "en"
      [:latn]

      iex> Cldr.Number.System.number_system_names_for "th"
      [:latn, :thai]

      iex> Cldr.Number.System.number_system_names_for "he"
      [:latn, :hebr]

      iex> Cldr.Number.System.number_system_names_for "zz"
      {:error, {Cldr.UnknownLocaleError, "The locale \\"zz\\" is not known"}}
  """
  @spec number_system_names_for(%Locale{} | Locale.name) :: [String.t]
  def number_system_names_for(locale) do
    case number_systems_for(locale) do
      {:error, _} = error ->
        error
      systems ->
        systems
        |> Map.values
        |> Enum.uniq
    end
  end

  @doc """
  Returns the names of the number systems available for
  a locale or an `{:error, message}` tuple if the locale
  is not known.

  * `locale` is any valid locale returned by `Cldr.known_locales()`

  ## Examples

      iex> Cldr.Number.System.number_system_names_for "en"
      [:latn]

      iex> Cldr.Number.System.number_system_names_for "th"
      [:latn, :thai]

      iex> Cldr.Number.System.number_system_names_for "he"
      [:latn, :hebr]
  """
  def number_system_names_for!(locale) do
    case number_system_names_for(locale) do
      {:error, {exception, message}} ->
        raise exception, message
      names ->
        names
    end
  end

  @doc """
  Returns a number system name for a given locale and number system reference.

  * `system_name` is any name of name type

  * `locale` is any valid locale returned by `Cldr.known_locales()`

  Number systems can be references in one of two ways:

  * As a number system type such as :default, :native, :traditional and
    :finance. This allows references to a number system for a locale in a
    consistent fashion for a given use

  * WIth the number system name directly, such as :latn, :arab or any of the
    other 70 or so

  This function dereferences the supplied `system_name` and returns the
  actual system name.

  ## Examples

      ex> Cldr.Number.System.system_name_from(:default, "en")
      :latn

      iex> Cldr.Number.System.system_name_from("latn", "en")
      :latn

      iex> Cldr.Number.System.system_name_from(:native, "en")
      :latn

      iex> Cldr.Number.System.system_name_from(:nope, "en")
      {:error, {Cldr.UnknownNumberSystemError, "The number system :nope is not known"}}

  Note that return value is not guaranteed to be a valid
  number system for the given locale as demonstrated in the third example.
  """
  @spec system_name_from(binary | atom, Locale.name | %Locale{}) :: atom
  def system_name_from(system_name, locale \\ Cldr.get_current_locale())

  def system_name_from(system_name, locale) when is_binary(locale) do
    system_name_from(system_name, Cldr.get_locale(locale))
  end

  def system_name_from(_system_name, {:error, _} = error) do
    error
  end

  def system_name_from(system_name, %Locale{} = locale) when is_binary(system_name) do
    try do
      system_name_from(String.to_existing_atom(system_name), locale)
    rescue ArgumentError ->
      {:error, number_system_error(system_name)}
    end
  end

  def system_name_from(system_name, %Locale{} = locale) when is_atom(system_name) do
    number_systems = Map.get(locale, :number_systems)
    cond do
      Map.has_key?(number_systems, system_name) ->
        Map.get(number_systems, system_name)
      system_name in Map.values(number_systems) ->
        system_name
      true ->
        {:error, number_system_error(system_name)}
    end
  end

  @doc """
  Returns a number system name for a given locale and number system reference
  and raises if the number system is not available for the given locale.

  See `Cldr.Number.System.system_name_from/2` for further information.
  """
  def system_name_from!(system_name, locale \\ Cldr.get_current_locale()) do
    case system_name_from(system_name, locale) do
      {:error, {exception, message}} ->
        raise exception, message
      name ->
        name
    end
  end

  @doc """
  Returns locale and number systems that have the same digits and
  separators as the supplied one.

  Transliterating between locale & number systems is expensive.  To avoid
  unncessary transliteration we look for locale and number systems that have
  the same digits and separators.  Typically we are comparing to locale "en"
  and number system "latn" since this is what the number formatting routines use
  as placeholders.
  """
  @spec number_systems_like(%Locale{} | Locale.name, binary | atom) :: {:ok, List.t} | {:error, tuple}
  def number_systems_like(locale, number_system) when is_binary(locale) do
    locale
    |> Cldr.get_locale
    |> number_systems_like(number_system)
  end

  def number_systems_like(%Locale{} = locale, number_system) do
    with %{digits: digits} <- number_system_for(locale, number_system),
      %Cldr.Number.Symbol{} = symbols <- Symbol.number_symbols_for(locale, number_system),
      [_ | _] = names <- number_system_names_for(locale)
    do
      likes = do_number_systems_like(digits, symbols, names)
      {:ok, likes}
    else
      {:error, _} = error -> error
    end
  end

  def number_systems_like({:error, _} = error, _number_system) do
    error
  end

  defp do_number_systems_like(digits, symbols, names) do
    Enum.map(Cldr.known_locales(), fn this_locale ->
      Enum.reduce names, [], fn this_system, acc ->
        case number_system_for(this_locale, this_system) do
        {:error, _} ->
          acc
        %{digits: these_digits} ->
          these_symbols = Symbol.number_symbols_for(this_locale, this_system)
          if digits == these_digits && symbols == these_symbols do
            acc ++ {this_locale, this_system}
          end
        end
      end
    end) |> Enum.reject(&(is_nil(&1) || &1 == []))
  end

  @doc """
  Returns `{:ok, digits}` for a number system, or an `{:error, message}` if the
  number system is not know.

  ## Examples

      iex> Cldr.Number.System.number_system_digits(:latn)
      {:ok, "0123456789"}

      iex> Cldr.Number.System.number_system_digits(:nope)
      {:error, {Cldr.UnknownNumberSystemError, "The number system nil is not known"}}
  """
  def number_system_digits(system) do
    if system = systems_with_digits()[system] do
      {:ok, Map.get(system, :digits)}
    else
      {:error, number_system_error(system)}
    end
  end

  @doc """
  Returns `digits` for a number system, or raises an exception if the
  number system is not know.

  ## Examples

      iex> Cldr.Number.System.number_system_digits! :latn
      "0123456789"

      Cldr.Number.System.number_system_digits! :nope
      ** (Cldr.UnknownNumberSystemError) The number system :nope is not known
  """
  def number_system_digits!(system) do
    case number_system_digits(system) do
      {:ok, digits} ->
        digits
      _ ->
        {exception, message} = number_system_error(system)
        raise exception, message
    end
  end

  @doc """
  Generate a transliteration map between two character classes
  """
  def generate_transliteration_map(from, to) when is_binary(from) and is_binary(to) do
    do_generate_transliteration_map(from, to, String.length(from), String.length(to))
  end

  defp do_generate_transliteration_map(from, to, from_length, to_length)
  when from_length == to_length do
    from
    |> String.graphemes
    |> Enum.zip(String.graphemes(to))
    |> Enum.into(%{})
  end

  defp do_generate_transliteration_map(from, to, _from_length, _to_length) do
    {:error, {ArgumentError, "#{inspect from} and #{inspect to} aren't the same length"}}
  end

  @doc false
  def number_system_error(system_name) do
    {Cldr.UnknownNumberSystemError,
      "The number system #{inspect system_name} is not known"}
  end
end
