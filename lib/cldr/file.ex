defmodule Cldr.File do
  @moduledoc """
  Functions to read the CLDR repository json
  files and transpose them into a format for easier consumption.

  These should not be considered part of the public
  API.  They are typically used in other modules to
  support the generation of locale-specific functions
  at compile time.

  There should be no access to the CLDR repository files outside of
  the functions in this module.
  """

  alias Cldr.{Config, Number, Locale, Currency}

  @supplemental_path  "/supplemental"
  @currencies         [@supplemental_path, "/currencyData.json"]
  @number_systems     [@supplemental_path, "/numberingSystems.json"]

  @currencies_file     Path.join(Cldr.data_dir(), @currencies)
  @number_systems_file Path.join(Cldr.data_dir(), @number_systems)

  @currency_data  Cldr.Config.read_cldr_data(@currencies_file)
  |> get_in([:supplemental, :currency_data, :fractions])

  def read(:currency_data) do
    @currency_data
  end

  def read(:currency_codes) do
    Cldr.get_locale()
    |> Cldr.Config.get_locale
    |> get_in([:main, String.to_atom(Cldr.get_locale()), :numbers, :currencies])
    |> Map.keys
  end

  def read(:number_systems) do
    Cldr.Config.read_cldr_data(@number_systems_file)
    |> get_in([:supplemental, :numbering_systems])
    |> Enum.map(fn {system, meta} ->
      {system, %Number.System{
        name:       system,
        type:       meta[:"_type"],
        digits:     meta[:"_digits"],
        rules:      split_rules(meta[:"_rules"])
      }}
    end)
    |> Enum.into(%{})
  end

  @lint {~r/Refactor/, false}
  @spec read(:decimal_formats) :: Map.t
  def read(:decimal_formats) do
    import Config, only: [normalize_short_format: 1, currency_long_format: 1]

    formats = Enum.map Config.known_locales, fn (locale) ->
      number_systems = locale
        |> Number.System.number_systems_for
        |> Enum.map(fn {_k, v} -> v.name end) |> Enum.uniq

      number_formats = Enum.reduce number_systems, %{}, fn (number_system, formats) ->
        numbers = read(:numbers, locale)
        decimal_formats    = numbers[String.to_atom("decimal_formats_number_system_#{number_system}")]
        currency_formats   = numbers[String.to_atom("currency_formats_number_system_#{number_system}")]
        scientific_formats = numbers[String.to_atom("scientific_formats_number_system_#{number_system}")]
        percent_formats    = numbers[String.to_atom("percent_formats_number_system_#{number_system}")]

        if number_system == :hebr do
          IO.puts inspect(Map.keys(numbers))
        end

        decimal_long_format   = decimal_formats.long.decimal_format
        decimal_short_format  = decimal_formats.short.decimal_format
        currency_short_format = currency_formats.short.standard

        locale_formats = %Number.Format{
          standard:       decimal_formats.standard,
          decimal_long:   normalize_short_format(decimal_long_format),
          decimal_short:  normalize_short_format(decimal_short_format),
          currency:       currency_formats.standard,
          currency_short: normalize_short_format(currency_short_format),
          currency_long:  currency_long_format(currency_formats),
          accounting:     currency_formats.accounting,
          scientific:     scientific_formats.standard,
          percent:        percent_formats.standard
        }
        Map.merge formats, %{number_system => locale_formats}
      end
      {locale, number_formats}
    end
    Enum.into(formats, %{})
  end

  @doc """
  Returns a list of the known decimal formats in this `Cldr` configuration.
  """
  def read(:decimal_format_list) do
    :decimal_formats
    |> read
    |> Enum.map(fn {_locale, formats} -> Map.values(formats) end)
    |> Enum.map(&(hd(&1)))
    |> Enum.flat_map(&(Map.values(&1)))
    |> List.flatten
    |> Enum.map(&extract_formats/1)
    |> List.flatten
    |> Enum.reject(&(&1 == Number.Format || is_nil(&1)))
    |> Enum.uniq
    |> Enum.sort
  end

  @doc """
  Returns a list of the locales in the CLDR repository.
  """
  @locales_path Path.join(Cldr.data_dir(), "cldr-core/availableLocales.json")
  @spec read(:locales, binary) :: Map.t
  def read(:locales) do
    locales = Cldr.Config.read_cldr_data(@locales_path)
    locales.available_locales.full
  end

  @doc """
  Returns a map of the known number systems for a `locale`.
  """
  @spec read(:number_systems, Locale.t) :: Map.t
  def read(:number_systems, locale) do
    numbers = read(:numbers, locale)
    %{default: numbers.default_numbering_system}
    |> Map.merge(numbers.other_numbering_systems)
    |> Enum.map(fn {type, system} ->
        {type, read(:number_systems)[String.to_atom(system)]} end)
    |> Enum.into(%{})
  end

  @doc """
  Returns the raw map of the `numbers` section of a given locale in the
  CLDR repository.
  """
  @spec read(:nummbers, Locale.t) :: %{}
  def read(:numbers, locale) do
    locale
    |> Cldr.Config.get_locale
    |> get_in([:main, String.to_atom(locale), :numbers])
  end

  @doc """
  Returns a map of `Cldr.Currency` maps for a given locale.
  """
  @lint {~r/Refactor/, false}
  @spec read(:currency, Locale.t) :: Map.t
  def read(:currency, locale) do
    locale
    |> Cldr.Config.get_locale
    |> get_in([:main, String.to_atom(locale), :numbers, :currencies])
    |> Enum.map(fn {code, currency} ->
      rounding = Map.merge(@currency_data[:default], (@currency_data[code] || %{}))
      currency_map = %Cldr.Currency{
        code:          code,
        name:          currency[:display_name],
        symbol:        currency[:symbol],
        narrow_symbol: currency[:symbol_alt_narrow],
        tender:        String.to_atom(rounding[:_tender] || "true"),
        digits:        String.to_integer(rounding[:"_digits"]),
        rounding:      String.to_integer(rounding[:"_rounding"]),
        cash_digits:   String.to_integer(rounding[:"_cashDigits"] || rounding[:"_digits"]),
        cash_rounding: String.to_integer(rounding[:"_cashRounding"] || rounding[:"_rounding"]),
        count:         read(:currency_counts, currency)
      }
      {code, currency_map}
    end)
    |> Enum.into(%{})
  end

  @spec read(:list_patterns, Locale.t) :: Map.t
  def read(:list_patterns, locale) do
    locale
    |> Cldr.Config.get_locale
    |> get_in([:main, String.to_atom(locale), :list_patterns])
    |> Cldr.Map.stringify_keys
    |> Enum.map(fn {"list_pattern_type_" <> type, data} ->
        type_name = type
        |> String.to_atom

        {type_name, data}
      end)
    |> Enum.into(%{})
  end

  @count_types [:zero, :one, :two, :few, :many, :other]
  @spec read(:currency_counts, Currency.t) :: Map.t
  def read(:currency_counts, currency) do
    Enum.reduce @count_types, %{}, fn (category, counts) ->
      if display_count = currency["displayName-count-#{category}"] do
        Map.put(counts, category, display_count)
      else
        counts
      end
    end
  end

  defp split_rules(rules) when is_nil(rules), do: nil
  defp split_rules(rules) do
    rules
    |> String.split("/")
    |> Enum.map(&String.replace(&1, "_","-"))
  end

  # A short format is a tuple with the first element being the
  # range and the second being a list of plural rule keyed format.
  # We want to return only the formats.
  defp extract_formats({_range, list}) when is_list(list) do
    Keyword.values(list)
  end

  # In this case its a currency_long format which is in Unit format
  # not decimal format so we ignore is when collecting decimal formats
  defp extract_formats({range, _list}) when is_atom(range) do
    nil
  end

  # And if its not a tuple (for a short list) or an atom (for a
  # currency_long) then just return it
  defp extract_formats(short_format) do
    short_format
  end
end
