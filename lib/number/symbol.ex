defmodule Cldr.Number.Symbol do
  alias Cldr.File
  alias Cldr.Number
  
  Enum.each Cldr.known_locales, fn (locale) ->
    numbers = File.read(:numbers, locale)
    number_system_names = Number.System.number_system_names_for(locale)
    minimum_grouping_digits = numbers["minimumGroupingDigits"] |> String.to_integer
    
    def minimum_grouping_digits_for(unquote(locale)) do
      unquote(minimum_grouping_digits)
    end
    
    Enum.each number_system_names, fn (system_name) ->
      symbol_info = numbers["symbols-numberSystem-#{system_name}"] 
      |> File.underscore_keys 
      |> File.atomize_keys
      
      def number_symbols_for(unquote(locale), unquote(system_name)) do
        unquote(Macro.escape(symbol_info))
      end
    end
  end
  
  def minimum_grouping_digits_for(locale) do
    raise ArgumentError, "Unknown locale #{inspect locale}."
  end
end