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

    languages =
      locale_display_names
      |> Map.get("languages")
      |> Enum.map(fn {language, display_name} ->
        case String.split(language, "_alt_") do
          [name] -> {Cldr.Locale.normalize_locale_name(name), display_name}
          [name, alt] -> {{:alt, Cldr.Locale.normalize_locale_name(name)}, {alt, display_name}}
        end
      end)
      |> Map.new

    # Now take care of -ALT-VARIANT and -ALT-SHORT
    filter = fn {k, _v} -> match?({:alt, _x}, k) end

    alt =
      languages
      |> Enum.filter(filter)
      |> Map.new

    languages =
      languages
      |> Enum.reject(filter)
      |> Enum.map(fn {k, v} ->
        case Map.fetch(alt, {:alt, k}) do
          {:ok, {alt, display_name}} ->
            {k, %{:default => v, String.to_atom(alt) => display_name}}
          :error -> {k, v}
        end
      end)
      |> Map.new

    locale_display_names = Map.put(locale_display_names, "languages", languages)
    Map.put(content, "locale_display_names", locale_display_names)
  end

end
