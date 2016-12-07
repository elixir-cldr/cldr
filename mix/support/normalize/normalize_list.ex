defmodule Cldr.Normalize.List do
  @moduledoc """
  Takes the list part of the locale map and transforms the formats into a more easily
  processable structure that is then stored in map managed by `Cldr.Locale`
  """

  def normalize(content, locale) do
    content
    |> normalize_lists(locale)
  end

  def normalize_lists(content, _locale) do
    lists = content
    |> get_in(["list_patterns"])
    |> Enum.map(fn {"list_pattern_type_" <> type, data} -> {type, data} end)
    |> Enum.into(%{})

    Map.put(content, "list_formats", lists)
  end
end