defmodule Cldr.Normalize.LocaleDisplayNames do
  @moduledoc false

  def normalize(content, locale) do
    content
    |> normalize_locale_display_names(locale)
  end

  def normalize_locale_display_names(content, _locale) do
    locale_display_names =
      content
      |> Map.fetch!("locale_display_names")
      |> Cldr.Consolidate.default([])

    languages =
      locale_display_names
      |> Map.get("languages")
      |> merge_alt(&Cldr.Locale.canonical_locale_name!/1)

    scripts =
      locale_display_names
      |> Map.get("scripts", %{})
      |> merge_alt(&String.capitalize/1)
      |> Cldr.Map.atomize_keys()

    territories =
      locale_display_names
      |> Map.get("territories", %{})
      |> merge_alt(&String.upcase/1)
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

  def merge_alt(map, normalizer_fun \\ & &1) do
    map =
      map
      |> Cldr.Consolidate.default([])
      |> Enum.map(fn {code, display_name} ->
        case String.split(code, "_alt_") do
          [name] -> {normalizer_fun.(name), display_name}
          [name, alt] -> {{:alt, normalizer_fun.(name)}, {alt, display_name}}
        end
      end)
      |> Map.new()

    # Now take care of -ALT-VARIANT and -ALT-SHORT
    filter = fn {k, _v} -> match?({:alt, _x}, k) end

    alt =
      map
      |> Enum.filter(filter)
      |> Map.new()

    map
    |> Enum.reject(filter)
    |> Enum.map(fn {k, v} ->
      case Map.fetch(alt, {:alt, k}) do
        {:ok, {alt, display_name}} ->
          {k, %{"default" => v, alt => display_name}}

        :error ->
          {k, v}
      end
    end)
    |> Map.new()
  end
end
