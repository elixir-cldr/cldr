# credo:disable-for-this-file
defmodule Cldr.Normalize.Rbnf do
  @moduledoc """
  Takes the rbnf part of the locale map and transforms the formats into a more easily
  processable structure that is then stored in map managed by `Cldr.Locale`
  """
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