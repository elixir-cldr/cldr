defmodule Cldr.Normalize.List do

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