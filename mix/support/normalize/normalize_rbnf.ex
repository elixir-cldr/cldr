defmodule Cldr.Normalize.Rbnf do
  @moduledoc false

  def normalize(content, locale) do
    content
    |> normalize_rbnf(locale)
  end

  def normalize_rbnf(content, locale) do
    case Cldr.Rbnf.Config.for_locale(locale) do
      {:error, _} -> Map.put(content, "rbnf", %{})
      {:ok, rules} -> Map.put(content, "rbnf", structure_rbnf(rules))
    end
  end

  # Put the rbnf rules into a %Rule{} struct
  defp structure_rbnf(rules) do
    rules
    |> Enum.map(fn {group, sets} ->
      {group, structure_sets(sets)}
    end)
    |> Map.new()
  end

  defp structure_sets(sets) do
    sets
    |> Enum.map(fn {name, set} ->
      {Cldr.Config.underscore(name), Map.put(set, :rules, set[:rules])}
    end)
    |> Map.new()
  end
end
