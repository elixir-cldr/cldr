defmodule Cldr.Normalize.List do
  @moduledoc false

  alias Cldr.Substitution

  def normalize(content, locale) do
    content
    |> normalize_lists(locale)
  end

  def normalize_lists(content, _locale) do
    lists =
      content
      |> get_in(["list_patterns"])
      |> Enum.map(fn {"list_pattern_type_" <> type, data} -> {type, compile_formats(data)} end)
      |> Map.new()
      |> Cldr.Map.integerize_keys()
      |> Cldr.Map.atomize_keys()

    Map.put(content, "list_formats", lists)
  end

  def compile_formats(formats) do
    Enum.map(formats, fn {key, template} -> {key, Substitution.parse(template)} end)
    |> Enum.into(%{})
  end
end
