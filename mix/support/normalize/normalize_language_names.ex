defmodule Cldr.Normalize.LanguageNames do
  @moduledoc false

  alias Cldr.Consolidate

  def normalize(content, locale) do
    content
    |> normalize_language_names(locale)
  end

  def normalize_language_names(content, _locale) do
    languages =
      content
      |> get_in(["locale_display_names", "languages"])
      |> Consolidate.default([])
      # |> Enum.map(fn {k, v} ->
      #   k =
      #     k
      #     |> String.replace("__", "_")
      #     |> String.replace(~r/^(.)_(.)/, "\\1\\2")
      #
      #   {k, v}
      # end)
      |> Consolidate.group_alt_content(&Cldr.Locale.canonical_locale_name!/1)

    Map.put(content, "languages", languages)
  end
end
