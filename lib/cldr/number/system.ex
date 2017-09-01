defmodule Cldr.Number.System do
  @moduledoc """
  Functions to manage number systems which describe the numbering characteristics for a locale.

  A number system defines the digits (if they exist in this number system) or
  or rules (if the number system does not have decimal digits).

  The system name is also used as a key to define the separators that are used
  when formatting a number is this number_system. See
  `Cldr.Number.Symbol.number_symbols_for/2`.
  """

  require Cldr
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
  @spec number_systems :: Map.t
  @number_systems Cldr.Config.number_systems

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
      {:ok, %{default: :latn, native: :latn}}

      iex> Cldr.Number.System.number_systems_for "th"
      {:ok, %{default: :latn, native: :thai}}

      iex> Cldr.Number.System.number_systems_for "zz"
      {:error, {Cldr.UnknownLocaleError, "The locale \\"zz\\" is not known."}}
  """
  @spec number_systems_for(Locale.name | %Locale{}) :: Map.t
  def number_systems_for(locale \\ Cldr.get_current_locale())

  for locale <- Cldr.Config.known_locales() do
    systems =
      locale
      |> Cldr.Config.get_locale
      |> Map.get(:number_systems)

    def number_systems_for(unquote(locale)) do
      {:ok, unquote(Macro.escape(systems))}
    end
  end

  def number_systems_for(locale) do
    {:error, Locale.locale_error(locale)}
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
      {:ok, systems} ->
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
      {:ok, %{digits: "0123456789", type: :numeric}}

      iex> Cldr.Number.System.number_system_for "th", :native
      {:ok, %{digits: "๐๑๒๓๔๕๖๗๘๙", type: :numeric}}

      iex> Cldr.Number.System.number_system_for "th", :latn
      {:ok, %{digits: "0123456789", type: :numeric}}

      iex> Cldr.Number.System.number_system_for "en", :default
      {:ok, %{digits: "0123456789", type: :numeric}}

      iex> Cldr.Number.System.number_system_for "en", :finance
      {:error, {Cldr.UnknownNumberSystemError, "The number system :finance is not known"}}

      iex> Cldr.Number.System.number_system_for "en", :native
      {:ok, %{digits: "0123456789", type: :numeric}}
  """
  def number_system_for(locale, system_name) do
    case system_name_from(system_name, locale) do
      {:error, _} = error ->
        error
      {:ok, system_name} ->
        {:ok, number_systems()[system_name]}
    end
  end

  @doc """
  Returns the names of the number systems available for
  a locale or an `{:error, message}` tuple if the locale
  is not known.

  * `locale` is any valid locale returned by `Cldr.known_locales()`

  ## Examples

      iex> Cldr.Number.System.number_system_names_for "en"
      {:ok, [:latn]}

      iex> Cldr.Number.System.number_system_names_for "th"
      {:ok, [:latn, :thai]}

      iex> Cldr.Number.System.number_system_names_for "he"
      {:ok, [:latn, :hebr]}

      iex> Cldr.Number.System.number_system_names_for "zz"
      {:error, {Cldr.UnknownLocaleError, "The locale \\"zz\\" is not known."}}
  """
  @spec number_system_names_for(%Locale{} | Locale.name) :: [String.t]
  def number_system_names_for(locale) do
    with {:ok, _} <- Cldr.valid_locale?(locale),
         {:ok, systems} <- number_systems_for(locale)
    do
      {:ok, systems |> Map.values |> Enum.uniq}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Returns the names of the number systems available for
  a locale or an `{:error, message}` tuple if the locale
  is not known.

  * `locale` is any valid locale returned by `Cldr.known_locales()`

  ## Examples

      iex> Cldr.Number.System.number_system_names_for! "en"
      [:latn]

      iex> Cldr.Number.System.number_system_names_for! "th"
      [:latn, :thai]

      iex> Cldr.Number.System.number_system_names_for! "he"
      [:latn, :hebr]
  """
  def number_system_names_for!(locale) do
    case number_system_names_for(locale) do
      {:error, {exception, message}} ->
        raise exception, message
      {:ok, names} ->
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
      {:ok, :latn}

      iex> Cldr.Number.System.system_name_from("latn", "en")
      {:ok, :latn}

      iex> Cldr.Number.System.system_name_from(:native, "en")
      {:ok, :latn}

      iex> Cldr.Number.System.system_name_from(:nope, "en")
      {:error, {Cldr.UnknownNumberSystemError, "The number system :nope is not known"}}

  Note that return value is not guaranteed to be a valid
  number system for the given locale as demonstrated in the third example.
  """
  @spec system_name_from(binary | atom, Locale.name | %Locale{}) :: atom
  def system_name_from(system_name, locale \\ Cldr.get_current_locale())

  def system_name_from(system_name, locale) when is_binary(system_name) do
    try do
      system_name_from(String.to_existing_atom(system_name), locale)
    rescue ArgumentError ->
      {:error, number_system_error(system_name)}
    end
  end

  def system_name_from(system_name, locale) when is_atom(system_name) do
    with {:ok, _} <- Cldr.valid_locale?(locale),
         {:ok, number_systems} <- number_systems_for(locale)
    do
      cond do
        Map.has_key?(number_systems, system_name) ->
          {:ok, Map.get(number_systems, system_name)}
        system_name in Map.values(number_systems) ->
          {:ok, system_name}
        true ->
          {:error, number_system_error(system_name)}
      end
    else
      {:error, reason} -> {:error, reason}
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
      {:ok, name} ->
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
  @spec number_systems_like(Locale.name, binary | atom) :: {:ok, List.t} | {:error, tuple}
  def number_systems_like(locale, number_system) when is_binary(locale) do
    with {:ok, _} <- Cldr.valid_locale?(locale),
         {:ok, %{digits: digits}} <- number_system_for(locale, number_system),
         {:ok, symbols} <- Symbol.number_symbols_for(locale, number_system),
         {:ok, names} <- number_system_names_for(locale)
    do
      likes = do_number_systems_like(digits, symbols, names)
      {:ok, likes}
    else
      {:error, _} = error -> error
      {:no_symbols, _} = error -> error
    end
  end

  defp do_number_systems_like(digits, symbols, names) do
    Enum.map(Cldr.known_locales(), fn this_locale ->
      Enum.reduce names, [], fn this_system, acc ->
        case number_system_for(this_locale, this_system) do
          {:error, _} ->
            acc
          {:ok, %{digits: these_digits}} ->
            {:ok, these_symbols} = Symbol.number_symbols_for(this_locale, this_system)
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
      {:error, {Cldr.UnknownNumberSystemError, "The number system :nope is not known or does not have digits"}}
  """
  def number_system_digits(system_name) do
    if system = systems_with_digits()[system_name] do
      {:ok, Map.get(system, :digits)}
    else
      {:error, number_system_digits_error(system_name)}
    end
  end

  @doc """
  Returns `digits` for a number system, or raises an exception if the
  number system is not know.

  ## Examples

      iex> Cldr.Number.System.number_system_digits! :latn
      "0123456789"

      Cldr.Number.System.number_system_digits! :nope
      ** (Cldr.UnknownNumberSystemError) The number system :nope is not known or does not have digits
  """
  def number_system_digits!(system) do
    case number_system_digits(system) do
      {:ok, digits} ->
        digits
      {:error, {exception, message}} ->
        raise exception, message
    end
  end

  @number_system_names Enum.sort(Map.keys(@number_systems))
  @doc """
  Returns the names of the known number systems.

  This is the full list of number systems for which
  a definition is provided in CLDR.

  Note that number formatting is not available for
  all the number systems in this list.  Number formatting
  is defined for a specific list of number systems in
  each locale. To determine which number systems are
  supported for number formatting in a given locale see
  `number_system_names_for/1`.

  ## Example

      iex> Cldr.Number.System.known_number_systems
      [:adlm, :ahom, :arab, :arabext, :armn, :armnlow, :bali, :beng, :bhks, :brah,
       :cakm, :cham, :cyrl, :deva, :ethi, :fullwide, :geor, :grek, :greklow, :gujr,
       :guru, :hanidays, :hanidec, :hans, :hansfin, :hant, :hantfin, :hebr, :hmng,
       :java, :jpan, :jpanfin, :kali, :khmr, :knda, :lana, :lanatham, :laoo, :latn,
       :lepc, :limb, :mathbold, :mathdbl, :mathmono, :mathsanb, :mathsans, :mlym,
       :modi, :mong, :mroo, :mtei, :mymr, :mymrshan, :mymrtlng, :newa, :nkoo, :olck,
       :orya, :osma, :roman, :romanlow, :saur, :shrd, :sind, :sinh, :sora, :sund,
       :takr, :talu, :taml, :tamldec, :telu, :thai, :tibt, :tirh, :vaii, :wara]

  """
  @spec known_number_systems :: [atom, ...]
  def known_number_systems do
    @number_system_names
  end

  @doc """
  Returns `{:ok, system}` if the number system
  is known, or `{:error, reason}`

  ## Examples

      iex> Cldr.Number.System.valid_number_system? :hant
      {:ok, :hant}

      iex> Cldr.Number.System.valid_number_system? :nope
      {:error,
       {Cldr.UnknownNumberSystemError, "The number system :nope is not known"}}

  """
  def valid_number_system?(system) do
    if system in known_number_systems() do
      {:ok, system}
    else
      {:error, number_system_error(system)}
    end
  end

  @doc """
  Converts a number into the representation of
  a non-latin number system.

  This function converts numbers to a known
  number system only, it does not provide number
  formatting.

  There are two types of number systems in CLDR:

  * `:numeric` in which the number system defines
  a direct mapping between the latin digits `0..9`
  into a the number system equivalent.  In this case,
  `to_system/2` invokes `Cldr.Number.Transliterate.transliterate_digits/3`
  for the given number.

  * `:algorithmic` in which the number system
  does not have the same structure as the `:latn`
  number system and therefore the conversion is
  done algorithmically.  For CLDR the algorithm
  is implemented through `Cldr.Rbnf` rulesets.
  These rulesets are considered by CLDR to be
  less rigorous than the `:numeric` number systems
  and caution and testing for a specific use case
  is recommended.

  ## Examples

      iex> Cldr.Number.System.to_system 123456, :hebr
      {:ok, "ק׳׳ת׳"}

      iex> Cldr.Number.System.to_system 123, :hans
      {:ok, "一百二十三"}

      iex> Cldr.Number.System.to_system 123, :hant
      {:ok, "一百二十三"}

      iex> Cldr.Number.System.to_system 123, :hansfin
      {:ok, "壹佰贰拾叁"}

  """
  @spec to_system(number, atom) :: String.t
  def to_system(number, number_system)

  for {system, definition} <- @number_systems do
    if definition.type == :numeric do
      def to_system(number, unquote(system)) do
        string =
          number
          |> to_string
          |> Cldr.Number.Transliterate.transliterate_digits(:latn, unquote(system))
        {:ok, string}
      end
    else
      {module, function, locale} = Cldr.Config.rbnf_rule_function(definition.rules)
      def to_system(number, unquote(system)) do
        with {:ok, _locale} <- Cldr.valid_locale?(unquote(locale)) do
          {:ok, unquote(module).unquote(function)(number, unquote(locale))}
        else
          {:error, reason} -> {:error, reason}
        end
      end
    end
  end

  def to_system(_number, system) do
    {:error, number_system_error(system)}
  end

  @doc """
  Converts a number into the representation of
  a non-latin number system. Returns a converted
  string or raises on error.

  See `Cldr.Number.System.to_string/2` for further
  information.

  ## Examples

      iex> Cldr.Number.System.to_system! 123, :hans
      "一百二十三"

      iex> Cldr.Number.System.to_system! 123, :hant
      "一百二十三"

      iex> Cldr.Number.System.to_system! 123, :hansfin
      "壹佰贰拾叁"

  """
  def to_system!(number, system) do
    case to_system(number, system) do
      {:ok, string} -> string
      {:error, {exception, reason}} -> raise exception, reason
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

  def number_system_digits_error(system_name) do
    {Cldr.UnknownNumberSystemError,
      "The number system #{inspect system_name} is not known or does not have digits"}
  end
end

