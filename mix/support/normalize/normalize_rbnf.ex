defmodule Cldr.Normalize.Rbnf do
  @moduledoc false

  def normalize(content, locale) do
    content
    |> normalize_rbnf(locale)
  end

  def normalize_rbnf(content, locale) do
    case Cldr.Rbnf.Config.for_locale(locale) do
      {:error, _}  -> Map.put(content, "rbnf", %{})
      {:ok, rules} -> Map.put(content, "rbnf", rules)
    end
  end
end