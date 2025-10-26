defmodule Cldr.Normalize.TerritoryContainers do
  @moduledoc false

  def normalize(content) do
    content
    |> normalize_territory_containers
  end

  def normalize_territory_containers(content) do
    content
    |> Enum.map(fn
      {<<container::binary-3>>, v} ->
        {container, Map.get(v, "_contains")}
      {<<container::binary-2>>, v} ->
        {container, Map.get(v, "_contains")}
      {<<container::binary-3, "-status-grouping">>, v} ->
        {container, Map.get(v, "_contains")}
      _other ->
        nil
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.sort()
    |> merge()
    |> Map.new()
  end

  def merge([]) do
    []
  end

  def merge([{container, values_1}, {container, values_2} | rest]) do
    values = Enum.uniq(values_1 ++ values_2)
    merge([{container, values} | rest])
  end

  def merge([container | rest]) do
    [container | merge(rest)]
  end
end
