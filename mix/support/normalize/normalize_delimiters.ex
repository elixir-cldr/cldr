defmodule Cldr.Normalize.Delimiter do
  @moduledoc false

  def normalize(content, locale) do
    content
    |> normalize_delimiters(locale)
  end

  def normalize_delimiters(content, _locale) do
    content
  end
end
