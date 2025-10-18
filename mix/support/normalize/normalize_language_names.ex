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
      |> Consolidate.group_alt_content(&Cldr.Locale.canonical_locale_name!/1)
      |> Cldr.Map.atomize_keys(level: 2..4)

    Map.put(content, "languages", languages)
  end
end
