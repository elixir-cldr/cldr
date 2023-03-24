defmodule Cldr.Normalize.TerritoryNames do
  @moduledoc false

  def normalize(content, locale) do
    content
    |> normalize_territory_names(locale)
  end

  def normalize_territory_names(content, _locale) do
    territories =
      content
      |> get_in(["locale_display_names", "territories"])
      |> Cldr.Consolidate.default([])
      |> Enum.map(fn {k, v} ->
        k = String.replace(k, ~r/^(.)_(.)/, "\\1\\2")
        {String.upcase(k), v}
      end)
      |> Enum.group_by(fn {k, _v} -> hd(String.split(k, "_")) end, fn {k, v} ->
        parts = String.split(k, "_ALT_")

        if length(parts) == 1 do
          %{"standard" => v}
        else
          %{String.downcase(hd(Enum.reverse(parts))) => v}
        end
      end)
      |> Enum.map(fn {k, v} -> {k, Cldr.Map.merge_map_list(v)} end)
      |> Enum.into(%{})

    Map.put(content, "territories", territories)
  end
end
