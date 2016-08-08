if Mix.env == :dev do
  defmodule Cldr.Number.Utils do
    alias Cldr.Number
  
    # Just checking if we have more than one scientific or percentage
    # formats.  As of this writing there are no formats beyond "standard"
    # although there are several locales with number systems without 
    # either scientific or percentage formats defined.
    @doc false
    def format_inspector(locales \\ Cldr.known_locales()) do
      Enum.each locales, fn (locale) ->
        Enum.each Number.System.number_systems_for(locale), fn (system) ->
          numbers = Number.System.numbers_for(locale)
          number_system = elem(system, 1)
          if scientific = numbers["scientificFormats-numberSystem-#{number_system}"] do
            if (count = Enum.count(scientific)) > 1 do
              IO.puts "Found #{inspect count} scientific formats for number system #{inspect number_system} in locale #{inspect locale}"
            end
          else
            IO.puts "No scientific formats found for number system #{inspect number_system} in locale #{locale}"          
          end
          if percentage = numbers["percentFormats-numberSystem-#{number_system}"] do
            if (count = Enum.count(percentage)) > 1 do
              IO.puts "Found #{inspect count} percent formats for number system #{inspect number_system} in locale #{inspect locale}"
            end
          else
            IO.puts "No percentage formats found for number system #{inspect number_system} in locale #{locale}"
          end       
        end
      end
    end
  end 
end