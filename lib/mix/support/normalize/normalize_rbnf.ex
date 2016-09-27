defmodule Cldr.Normalize.Rbnf do

  def normalize(content, locale) do
    content
    |> normalize_rbnf(locale)
  end

  def normalize_rbnf(content, locale) do
    case rbnf = Cldr.Rbnf.for_locale(locale) do
      {:error, _} -> content
      _           -> Map.put(content, "rbnf", rbnf)
    end
  end
end