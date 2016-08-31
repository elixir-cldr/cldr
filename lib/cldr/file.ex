defmodule Cldr.File do
  @moduledoc """
  Utility functions to read the CLDR repository json
  files.

  These should not be considered part of the public
  API.  They are typically used in other modules to
  support the generation of locale-specific functions
  at compile time.
  """

  alias Cldr.Config
  alias Cldr.Number

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
      {system, %Cldr.Number.System{
        name:       system,
        type:       String.to_atom(meta["_type"]),
        digits:     meta["_digits"],
        rules:      split_rules(meta["_rules"])
      }}
    end)
    systems_list |> Enum.into(%{})
  end

  @lint {~r/Refactor/, false}
  def read(:decimal_formats) do
    formats = Enum.map Cldr.Config.known_locales, fn (locale) ->
      number_systems = locale
        |> Number.System.number_systems_for
        |> Enum.map(fn {_k, v} -> v.name end) |> Enum.uniq

      number_formats = Enum.reduce number_systems, %{}, fn (number_system, formats) ->
        numbers = read(:numbers, locale)
        decimal_formats    = numbers["decimalFormats-numberSystem-#{number_system}"]
        currency_formats   = numbers["currencyFormats-numberSystem-#{number_system}"]
        scientific_formats = numbers["scientificFormats-numberSystem-#{number_system}"]
        percent_formats    = numbers["percentFormats-numberSystem-#{number_system}"]

        locale_formats = %Number.Format{
          standard:       decimal_formats["standard"],
          decimal_long:   decimal_formats["long"]["decimalFormat"],
          decimal_short:  decimal_formats["short"]["decimalFormat"],
          currency:       currency_formats["standard"],
          currency_short: currency_formats["short"]["standard"],
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

  def read(:number_systems, locale) do
    numbers = read(:numbers, locale)
    %{"default" => numbers["defaultNumberingSystem"]}
    |> Map.merge(numbers["otherNumberingSystems"])
    |> Enum.map(fn {type, system} -> {String.to_atom(type), read(:number_systems)[system]} end)
    |> Enum.into(%{})
  end

  def read(:numbers, locale) do
    path = Path.join([Config.data_dir(), "cldr-numbers-#{Config.full_or_modern()}",
      "main", locale, "numbers.json"])
    numbers = read_cldr_data(path)
    numbers["main"][locale]["numbers"]
  end

  @lint {~r/Refactor/, false}
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

  @locales_path Path.join(Cldr.data_dir(), "cldr-core/availableLocales.json")
  def read(:locales, full_or_modern) do
    locales = read_cldr_data(@locales_path)
    locales["availableLocales"][full_or_modern]
  end

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

  @count_types [:one, :two, :few, :many, :other]
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
end
