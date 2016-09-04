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

  @supplemental_path "/cldr-core/supplemental"
  @currencies        [@supplemental_path, "/currencyData.json"]
  @number_systems    [@supplemental_path, "/numberingSystems.json"]

  @currencies_file Path.join(Cldr.data_dir(), @currencies)
  @number_systems_file Path.join(Cldr.data_dir(), @number_systems)

  {:ok, data} = @currencies_file
  |> File.read!
  |> Poison.decode

  @currency_data data["supplemental"]["currencyData"]["fractions"]
  def read(:currency_data) do
    @currency_data
  end

  @currencies_path Path.join(Cldr.numbers_locale_dir(),
    [Cldr.get_locale(), "/currencies.json"])

  def read(:currency_codes) do
    currencies = read_cldr_data(@currencies_path)
    currencies["main"][Cldr.get_locale()]["numbers"]["currencies"]
    |> Enum.map(fn {code, _currency} -> code end)
  end

  def read(:number_systems) do
    systems = read_cldr_data(@number_systems_file)["supplemental"]["numberingSystems"]
    systems_list = Enum.map(systems, fn {system, meta} ->
      {system, %Number.System{
        name:       system,
        type:       String.to_atom(meta["_type"]),
        digits:     meta["_digits"],
        rules:      split_rules(meta["_rules"])
      }}
    end)
    systems_list |> Enum.into(%{})
  end

  @lint {~r/Refactor/, false}
  @spec read(:decimal_formats) :: Map.t
  def read(:decimal_formats) do
    import Config, only: [normalize_short_format: 1]

    formats = Enum.map Config.known_locales, fn (locale) ->
      number_systems = locale
        |> Number.System.number_systems_for
        |> Enum.map(fn {_k, v} -> v.name end) |> Enum.uniq

      number_formats = Enum.reduce number_systems, %{}, fn (number_system, formats) ->
        numbers = read(:numbers, locale)
        decimal_formats    = numbers["decimalFormats-numberSystem-#{number_system}"]
        currency_formats   = numbers["currencyFormats-numberSystem-#{number_system}"]
        scientific_formats = numbers["scientificFormats-numberSystem-#{number_system}"]
        percent_formats    = numbers["percentFormats-numberSystem-#{number_system}"]

        decimal_long_format   = decimal_formats["long"]["decimalFormat"]
        decimal_short_format  = decimal_formats["short"]["decimalFormat"]
        currency_short_format = currency_formats["short"]["standard"]

        locale_formats = %Number.Format{
          standard:       decimal_formats["standard"],
          decimal_long:   normalize_short_format(decimal_long_format),
          decimal_short:  normalize_short_format(decimal_short_format),
          currency:       currency_formats["standard"],
          currency_short: normalize_short_format(currency_short_format),
          accounting:     currency_formats["accounting"],
          scientific:     scientific_formats["standard"],
          percent:        percent_formats["standard"]
        }

        Map.merge formats, %{String.to_atom(number_system) => locale_formats}
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
  Returns a map of the known number systems for a `locale`.
  """
  @spec read(:number_systems, Locale.t) :: Map.t
  def read(:number_systems, locale) do
    numbers = read(:numbers, locale)
    %{"default" => numbers["defaultNumberingSystem"]}
    |> Map.merge(numbers["otherNumberingSystems"])
    |> Enum.map(fn {type, system} -> {String.to_atom(type), read(:number_systems)[system]} end)
    |> Enum.into(%{})
  end

  @doc """
  Returns the raw map of the `numbers` section of a given locale in the
  CLDR repository.
  """
  @spec read(:nummbers, Locale.t) :: %{}
  def read(:numbers, locale) do
    path = Path.join([Config.data_dir(), "cldr-numbers-#{Config.full_or_modern()}",
      "main", locale, "numbers.json"])
    numbers = read_cldr_data(path)
    numbers["main"][locale]["numbers"]
  end

  @doc """
  Returns a map of `Cldr.Currency` maps for a given locale.
  """
  @lint {~r/Refactor/, false}
  @spec read(:currency, Locale.t) :: Map.t
  def read(:currency, locale) do
    path = Path.join(Cldr.numbers_locale_dir(), [locale, "/currencies.json"])
    currencies = read_cldr_data(path)
    currencies["main"][locale]["numbers"]["currencies"]
    |> Enum.map(fn {code, currency} ->
      rounding = Map.merge(@currency_data["DEFAULT"], (@currency_data[code] || %{}))
      currency_map = %Cldr.Currency{
        code:          code,
        name:          currency["displayName"],
        symbol:        currency["symbol"],
        narrow_symbol: currency["symbol-alt-narrow"],
        tender:        String.to_atom(rounding["_tender"] || "true"),
        digits:        String.to_integer(rounding["_digits"]),
        rounding:      String.to_integer(rounding["_rounding"]),
        cash_digits:   String.to_integer(rounding["_cashDigits"] || rounding["_digits"]),
        cash_rounding: String.to_integer(rounding["_cashRounding"] || rounding["_rounding"]),
        count:         read(:currency_counts, currency)
      }
      {code, currency_map}
    end)
    |> Enum.into(%{})
  end

  @doc """
  Returns a list of the locales in the CLDR repository.
  """
  @locales_path Path.join(Cldr.data_dir(), "cldr-core/availableLocales.json")
  @spec read(:locales, binary) :: Map.t
  def read(:locales, full_or_modern) do
    locales = read_cldr_data(@locales_path)
    locales["availableLocales"][full_or_modern]
  end

  @spec read(:list_patterns, Locale.t) :: Map.t
  def read(:list_patterns, locale) do
    path = Path.join(Cldr.data_dir(), ["cldr-misc-#{Config.full_or_modern}/main/",
      locale, "/listPatterns.json"])
    pattern_list = read_cldr_data(path)["main"][locale]["listPatterns"]
    patterns = Enum.map(pattern_list, fn {"listPattern-type-" <> type, data} ->
      type_name = type
      |> String.replace("-", "_")
      |> String.to_atom

      {type_name, data}
    end)
    patterns |> Enum.into(%{})
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

  defp read_cldr_data(file) do
    {:ok, data} = file
    |> File.read!
    |> Poison.decode
    data
  end

  defp split_rules(rules) when is_nil(rules), do: nil
  defp split_rules(rules) do
    rules
    |> String.split("/")
    |> Enum.map(fn (elem) -> String.replace(elem, "_","-") end)
  end

  # A short format is a tuple with the first element being the
  # range and the second being a list of plural rule keyed format.
  # We want to return only the formats.
  defp extract_formats({_range, list}) do
    Keyword.values(list)
  end

  defp extract_formats(short_format) do
    short_format
  end
end
