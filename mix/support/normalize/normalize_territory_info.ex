defmodule Cldr.Normalize.TerritoryInfo do
  @moduledoc """
  Takes the territory info data and transforms the formats into a more easily
  processable structure.
  """

  def normalize(content) do
    content
    |> normalize_territory_info
  end

  def normalize_territory_info(content) do
    content
    |> Cldr.Map.remove_leading_underscores
    |> Cldr.Map.underscore_keys
    |> Cldr.Map.integerize_values
    |> Cldr.Map.floatize_values
    |> Enum.map(fn {k, v} -> {String.upcase(k), v} end)
    |> Enum.map(&normalize_language_codes/1)
    |> Enum.into(%{})
  end

  @key "language_population"
  def normalize_language_codes({k, v}) do
    if language_population = Map.get(v, @key) do
      language_population =
        language_population
        |> Enum.map(fn {k1, v1} ->
             if String.contains?(k1, "_") do
               [lang, script] = String.split(k1, "_")
               {"#{lang}-#{String.capitalize(script)}", v1}
             else
               {k1, v1}
             end
           end)
        |> Enum.into(%{})

      {k, Map.put(v, @key, language_population)}
    else
      {k, v}
    end
  end

end