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
    
    # If the system_name is an atom then it is a key into the number
    # systems for the locale (:default, :native, etc) which we use to 
    # look up the system name and then re-invoke
    def number_symbols_for(locale, system_name) when is_atom(system_name) do
      number_system = Number.System.number_systems_for(locale)[system_name].name
      number_symbols_for(locale, number_system)
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