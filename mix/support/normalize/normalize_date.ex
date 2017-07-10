# credo:disable-for-this-file
defmodule Cldr.Normalize.Date do
  @moduledoc """
  Takes the date part of the locale map and transforms the formats into a more easily
  processable structure that is then stored in map managed by `Cldr.Locale`
  """
  alias Cldr.Substitution

  def normalize(content, locale) do
    content
    |> normalize_dates(locale)
  end

  def normalize_dates(content, _locale) do
    dates = content
    |> get_in(["dates"])
    |> Map.delete("fields")

    Map.put(content, "dates", dates)
  end
end