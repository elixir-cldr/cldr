defmodule Cldr.Normalize.LocaleDisplayNames do
  @moduledoc false

  alias Cldr.Consolidate

  def normalize(content, locale) do
    content
    |> normalize_locale_display_names(locale)
  end

  def normalize_locale_display_names(content, _locale) do
    locale_display_names =
      content
      |> Map.fetch!("locale_display_names")
      |> Consolidate.default([])

    languages =
      locale_display_names
      |> Map.get("languages")
      |> Consolidate.group_alt_content(&Cldr.Locale.canonical_locale_name!/1)

    scripts =
      locale_display_names
      |> Map.get("scripts", %{})
      |> Consolidate.group_alt_content(&String.capitalize/1)
      |> Cldr.Map.atomize_keys()

    territories =
      locale_display_names
      |> Map.get("territories", %{})
      |> Consolidate.group_alt_content(&String.upcase/1)
      |> Cldr.Map.atomize_keys()

    locale_display_pattern =
      locale_display_names
      |> Map.get("locale_display_pattern", %{})
      |> Enum.map(fn {k, v} -> {k, Cldr.Substitution.parse(v)} end)
      |> Map.new()
      |> Cldr.Map.atomize_keys()

    code_patterns =
      locale_display_names
      |> Map.get("code_patterns")
      |> Enum.map(fn {k, v} -> {k, Cldr.Substitution.parse(v)} end)
      |> Map.new()
      |> Cldr.Map.atomize_keys()

    measurement_systems =
      locale_display_names
      |> Map.get("types", %{})
      |> Map.get("ms", %{})
      |> Enum.map(fn
        {"uksystem", description} -> {"imperial", description}
        other -> other
      end)
      |> Map.new()
      |> Cldr.Map.atomize_keys()

    types =
      locale_display_names
      |> Map.get("types", %{})
      |> Map.put("ms", measurement_systems)
      |> Cldr.Map.atomize_keys()

    locale_display_names =
      locale_display_names
      |> Cldr.Map.rename_keys("variants", "language_variants")
      |> Map.delete("languages")
      |> Map.delete("scripts")
      |> Map.delete("territories")
      |> Map.put("language", languages)
      |> Map.put("script", scripts)
      |> Map.put("territory", territories)
      |> Map.put("types", types)
      |> Map.put("locale_display_pattern", locale_display_pattern)
      |> Map.put("code_patterns", code_patterns)

    Map.put(content, "locale_display_names", locale_display_names)
  end

end
