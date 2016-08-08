defmodule Cldr.File do
  alias Cldr.Config
  alias Cldr.Number
  
  @moduledoc """
  Utility functions to read the CLDR repository json
  files.
  
  These should not be considered part of the public
  API.  They are typically used in other modules to 
  support the generation of locale-specific functions
  at compile time.
  """
  
  @currencies_data_path Path.join(Cldr.data_dir(), "/cldr-core/supplemental/currencyData.json")
  {:ok, data} = File.read!(@currencies_data_path) |> Poison.decode
  @currency_data data["supplemental"]["currencyData"]["fractions"]
  def read(:currency_data) do
    @currency_data
  end
  
  @currencies_path Path.join(Cldr.numbers_locale_dir(), [Cldr.default_locale(), "/currencies.json"])
  def read(:currency_codes) do
    currencies = read_cldr_data(@currencies_path)
    currencies["main"][Cldr.default_locale()]["numbers"]["currencies"] 
    |> Enum.map(fn {code, _currency} -> code end)
  end
  
  @number_systems_path Path.join(Cldr.data_dir(), "/cldr-core/supplemental/numberingSystems.json")
  def read(:number_systems) do
    systems = read_cldr_data(@number_systems_path)
    Enum.map(systems["supplemental"]["numberingSystems"], fn {system, meta} ->
      {system, %Cldr.Number.System{
        name:       system,
        type:       String.to_atom(meta["_type"]),
        digits:     meta["_digits"],
        rules:      split_rules(meta["_rules"])
      }}
    end) |> Enum.into(%{})
  end
  
  def read(:decimal_formats) do
    formats = Enum.map Cldr.Config.known_locales, fn (locale) ->
      number_systems = Number.System.number_systems_for(locale) |> Enum.map(fn {_k, v} -> v.name end) |> Enum.uniq
      number_formats = Enum.reduce number_systems, %{}, fn (number_system, formats) ->
        numbers = read(:numbers, locale)
        locale_formats = %Number.Format{
          standard:    numbers["decimalFormats-numberSystem-#{number_system}"]["standard"],
          currency:    numbers["currencyFormats-numberSystem-#{number_system}"]["standard"],
          accounting:  numbers["currencyFormats-numberSystem-#{number_system}"]["accounting"],
          scientific:  numbers["scientificFormats-numberSystem-#{number_system}"]["standard"],
          percent:     numbers["percentFormats-numberSystem-#{number_system}"]["standard"]
        }
        Map.merge formats, %{String.to_atom(number_system) => locale_formats}
      end
      {locale, number_formats}
    end
    Enum.into(formats, %{})
  end
  
  def read(:number_systems, locale) do
    numbers = read(:numbers, locale)
    Map.merge(%{"default" => numbers["defaultNumberingSystem"]}, numbers["otherNumberingSystems"])
    |> Enum.map(fn {type, system} -> {String.to_atom(type), read(:number_systems)[system]} end)
    |> Enum.into(%{})
  end
  
  def read(:numbers, locale) do
    path = Path.join([Config.data_dir(), "cldr-numbers-#{Config.full_or_modern}", "main", locale, "numbers.json"])
    numbers = read_cldr_data(path)
    numbers["main"][locale]["numbers"]
  end
  
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
    {:ok, data} = File.read!(file) 
    |> Poison.decode
    data
  end
  
  defp split_rules(rules) when is_nil(rules), do: nil
  defp split_rules(rules) do
    String.split(rules, "/") |> Enum.map(fn (elem) -> String.replace(elem, "_","-") end)
  end
end