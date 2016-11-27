defmodule Cldr.Normalize.Rbnf do

  def normalize(content, locale) do
    content
    |> normalize_rbnf(locale)
  end

  def normalize_rbnf(content, locale) do
    case rbnf = Cldr.Rbnf.Config.for_locale(locale) do
      {:error, _} -> Map.put(content, "rbnf", %{})
      _           -> Map.put(content, "rbnf", rbnf)
    end
  end
end