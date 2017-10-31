defmodule Cldr.Normalize.TerritoryContainment do
  @moduledoc """
  Takes the territory containment data and transforms the formats into a more easily
  processable structure.
  """

  def normalize(content) do
    content
    |> normalize_territory_containment
  end

  def normalize_territory_containment(content) do
    content
    |> Enum.map(fn {k, v} ->
         if String.contains?(k, "-status-") do
           nil
         else
           {k, Map.get(v, "_contains")}
         end
       end)
    |> Enum.reject(&is_nil/1)
    |> Enum.into(%{})
  end
end