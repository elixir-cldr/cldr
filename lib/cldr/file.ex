defmodule Cldr.File do
  alias Cldr.Config
  
  @moduledoc """
  Utility functions to read the CLDR repository json
  files.
  
  These should not be considered part of the public
  API.  They are typically used in other modules to 
  support the generation of locale-specific functions
  at compile time.
  """
  
  @currencies_data_path Path.join(Cldr.data_dir(), "/cldr-core/supplemental/currencyData.json")
  def read(:currency_data) do
    currency_data = read_cldr_data(@currencies_data_path)
    currency_data["supplemental"]["currencyData"]["fractions"]
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
      rules = if meta["_rules"] do 
        String.split(meta["_rules"], "/") |> Enum.map(fn (elem) -> String.replace(elem, "_","-") end)
      else
        nil
      end

      {system, %{
        name:       system,
        type:       String.to_atom(meta["_type"]),
        digits:     meta["_digits"],
        rules:      rules
      }}
    end) |> Enum.into(%{})
  end
  
  def read(:numbers, locale) do
    numbers = read_cldr_data(Path.join([Config.data_dir(), "cldr-numbers-#{Config.full_or_modern}", "/main/", locale, "/numbers.json"]))
    numbers["main"][locale]["numbers"]
  end
  
  def read(:currency, locale) do
    currencies = read_cldr_data(Path.join(Cldr.numbers_locale_dir(), "/#{locale}/currencies.json"))
    currencies["main"][locale]["numbers"]["currencies"]
  end
  
  @locales_path Path.join(Cldr.data_dir(), "cldr-core/availableLocales.json")
  def read(:locales, full_or_modern) do
    locales = read_cldr_data(@locales_path)
    locales["availableLocales"][full_or_modern]
  end
  
  defp read_cldr_data(file) do
    {:ok, data} = File.read!(file) 
    |> Poison.decode
    data
  end
end