defmodule Cldr.Number.Format do 
  @doc """
  The unique decimal formats in the configured locales
  """
  @spec known_decimal_formats :: [String.t]
  def known_decimal_formats do
    all_formats = Enum.reduce Cldr.known_locales, [], fn (locale, decimal_formats) ->
      {:ok, numbers} = Path.join([Cldr.data_dir, "cldr-numbers-full/main/", locale, "/numbers.json"])
      |> File.read!
      |> Poison.decode
      
      number_systems = Enum.uniq [numbers["main"]["numbers"]["defaultNumberingSystem"], "latn"]
      |> Enum.reject(fn (f) -> is_nil(f) end)
      
      locale_formats = Enum.reduce number_systems, [], fn (system, fmt) ->
        Enum.reject fmt ++ [
          numbers["main"][locale]["numbers"]["decimalFormats-numberSystem-#{system}"]["standard"],
          numbers["main"][locale]["numbers"]["currencyFormats-numberSystem-#{system}"]["currency"],
          numbers["main"][locale]["numbers"]["currencyFormats-numberSystem-#{system}"]["accounting"],
          numbers["main"][locale]["numbers"]["scientificFormats-numberSystem-#{system}"]["standard"],
          numbers["main"][locale]["numbers"]["percentFormats-numberSystem-#{system}"]["standard"]
          ], fn (f) -> is_nil(f) end
      end
      decimal_formats ++ locale_formats
    end
    Enum.uniq all_formats
  end
end 