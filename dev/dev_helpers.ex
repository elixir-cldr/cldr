defmodule Cldr.DevHelpers do
  @doc """
  What are the known symbol types?
  In CLDR 46 there are only :standard and :us

  """
  @dialyzer {:nowarn_function, [known_separator_types: 0]}
  def known_separator_types do
    config = %Cldr.Config{locales: :all}
    locales = Cldr.Locale.Loader.known_locale_names(config)

    Enum.map(locales, fn l ->
      symbols = Cldr.Locale.Loader.get_locale(l, config).number_symbols |> Map.values()
      Enum.map(symbols, fn
        nil -> nil
        other -> Map.get(other, :decimal) |> Map.keys()
      end)
    end)
    |> List.flatten()
    |> Enum.uniq()
    |> List.delete(nil)
  end
end