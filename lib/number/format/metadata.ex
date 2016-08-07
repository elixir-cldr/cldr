defmodule Cldr.Number.Metadata do
  alias Cldr.Number
  
  # The following functions are used by Cldr.Number.Format at compile
  # time and are not expected to be used as part of the public API
  @doc false
  def decimal_formats do
    formats = Enum.map Cldr.known_locales, fn (locale) ->
      number_systems = Number.System.number_systems_for(locale) |> Enum.map(fn {_k, v} -> v.name end) |> Enum.uniq
      number_formats = Enum.reduce number_systems, %{}, fn (number_system, formats) ->
        numbers = Number.System.numbers_for(locale)
        locale_formats = %{
          standard:    numbers["decimalFormats-numberSystem-#{number_system}"]["standard"],
          currency:    numbers["currencyFormats-numberSystem-#{number_system}"]["standard"],
          accounting:  numbers["currencyFormats-numberSystem-#{number_system}"]["accounting"],
          scientific:  numbers["scientificFormats-numberSystem-#{number_system}"]["standard"],
          percent:     numbers["percentFormats-numberSystem-#{number_system}"]["standard"]
        } |> Enum.reject(fn {_k, v} -> is_nil(v) end) |> Enum.into(%{})
        Map.merge formats, %{String.to_atom(number_system) => locale_formats}
      end
      {locale, number_formats}
    end
    Enum.into(formats, %{})
  end
  
  @doc false
  def decimal_format_list do
    Enum.map(decimal_formats, fn {_locale, formats} -> Map.values(formats) end)
    |> Enum.map(&(hd(&1)))
    |> Enum.map(&(Map.values(&1)))
    |> List.flatten
    |> Enum.uniq
  end
end