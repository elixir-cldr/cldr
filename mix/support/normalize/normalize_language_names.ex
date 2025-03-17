defmodule Cldr.Normalize.LanguageNames do
  @moduledoc false

  def normalize(content, locale) do
    content
    |> normalize_language_names(locale)
  end

  def normalize_language_names(content, _locale) do
    territories =
      content
      |> get_in(["locale_display_names", "languages"])
      |> Cldr.Consolidate.default([])
      |> Enum.map(fn {k, v} ->
        k =
          k
          |> String.replace("__", "_")
          |> String.replace(~r/^(.)_(.)/, "\\1\\2")

        case String.split(k, "_alt_") do
          [lang] ->
            {Cldr.Locale.canonical_locale_name!(lang), v}

          [lang, alt] ->
            {Cldr.Locale.canonical_locale_name!(lang) <> "_alt_" <> alt, v}
        end
      end)
      |> Enum.group_by(fn {k, _v} -> hd(String.split(k, "_alt_")) end, fn {k, v} ->
        parts = String.split(k, "_alt_")

        if length(parts) == 1 do
          %{"standard" => v}
        else
          %{String.downcase(hd(Enum.reverse(parts))) => v}
        end
      end)
      |> Enum.map(fn {k, v} -> {k, Cldr.Map.merge_map_list(v)} end)
      |> Enum.into(%{})
      |> Cldr.Map.atomize_keys(only: ["standard", "long", "menu", "variant"])

    Map.put(content, "languages", territories)
  end
end
