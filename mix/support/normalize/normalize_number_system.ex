defmodule Cldr.Normalize.NumberSystem do
  @moduledoc """
  Takes the number system part of the locale map and transforms the formats into a more easily
  processable structure that is then stored in map managed by `Cldr.Locale`
  """
  def normalize(content, locale) do
    content
    |> normalize_number_systems(locale)
  end

  def normalize_number_systems(content, _locale) do
    numbers = content["numbers"]
    number_systems = %{"default" => numbers["default_numbering_system"]}
    |> Map.merge(numbers["other_numbering_systems"])
    |> Enum.map(fn {type, system} -> {type, system} end)
    |> Enum.into(%{})

    Map.put(content, "number_systems", number_systems)
  end
end