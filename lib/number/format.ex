defmodule Cldr.Number.Format do 
  @moduledoc """
  Functions for introspecting on the number formats and
  number systems in CLDR.
  
  These functions would normally be used at compile time
  to generate functions for formatting numbers.  Therefore
  they are not performance optimized.  In particular most 
  functions load data from external files and decode the
  json on each invocation.
  """
  
  @doc """
  The unique decimal formats in the specified
  list of locales.
  
  Default is the configured locales.
  """
  @spec decimal_formats([Cldr.locale]) :: [String.t]
  def decimal_formats(locales \\ Cldr.known_locales()) do
    all_formats = Enum.reduce locales, [], fn (locale, decimal_formats) ->
      locale_formats = Enum.reduce number_systems_for(locale), [], fn (system, formats) ->
        formats ++ decimal_formats_for(locale, system) 
      end
      decimal_formats ++ locale_formats
    end
    Enum.uniq(all_formats) |> Enum.sort
  end
  
  @doc """
  The decimal formats defined for a given locale and number system.
  """
  @spec decimal_formats_for(Cldr.locale, String.t) :: [String.t]
  def decimal_formats_for(locale, number_system) do
    numbers = numbers_for(locale)
    
    Enum.reject [
      numbers["main"][locale]["numbers"]["decimalFormats-numberSystem-#{number_system}"]["standard"],
      numbers["main"][locale]["numbers"]["currencyFormats-numberSystem-#{number_system}"]["currency"],
      numbers["main"][locale]["numbers"]["currencyFormats-numberSystem-#{number_system}"]["accounting"],
      numbers["main"][locale]["numbers"]["scientificFormats-numberSystem-#{number_system}"]["standard"],
      numbers["main"][locale]["numbers"]["percentFormats-numberSystem-#{number_system}"]["standard"]
    ], fn (f) -> is_nil(f) end
  end
  
  @doc """
  The unique number systems in the specified 
  list of locales.
  
  Default is the configured locales.  
  """
  @spec number_systems([Cldr.locale]) :: [String.t]
  def number_systems(locales \\ Cldr.known_locales()) do
    all_systems = Enum.reduce locales, [], fn (locale, number_systems) ->
      number_systems ++ number_systems_for(locale)
    end
    Enum.uniq(all_systems) |> Enum.sort
  end
  
  @doc """
  The number systems available for a locale.
  """
  @spec number_systems_for(Cldr.locale) :: [String.t]
  def number_systems_for(locale) do
    numbers = numbers_for(locale)
    
    [numbers["main"][locale]["numbers"]["defaultNumberingSystem"]] ++  
      Map.values(numbers["main"][locale]["numbers"]["otherNumberingSystems"])
    |> Enum.reject(fn (f) -> is_nil(f) end)
  end
  
  @doc """
  The type of number systems available for a locale.
  
  There is always a default type and one or more other types depending
  on the locale.  A number can be formatted according to locale using 
  the default formatting information, or more specifically according
  to locale and number system type.
  """
  @spec number_system_types_for(Cldr.locale) :: [String.t]
  def number_system_types_for(locale) do
    numbers = numbers_for(locale)
    
    ["default"] ++  Map.keys(numbers["main"][locale]["numbers"]["otherNumberingSystems"])
  end
  
  @spec numbers_for(Cldr.locale) :: %{}
  defp numbers_for(locale) do
    {:ok, numbers} = Path.join([Cldr.data_dir, "cldr-numbers-full/main/", locale, "/numbers.json"])
    |> File.read!
    |> Poison.decode
    
    numbers
  end
end 