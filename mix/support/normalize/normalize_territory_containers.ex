defmodule Cldr.Normalize.TerritoryContainers do
  @moduledoc false

  def normalize(content) do
    content
    |> normalize_territory_containers
  end

  def normalize_territory_containers(content) do
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
