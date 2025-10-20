defmodule Cldr.Normalize.TerritoryNames do
  @moduledoc false

  alias Cldr.Consolidate

  def normalize(content, locale) do
    content
    |> normalize_territory_names(locale)
  end

  def normalize_territory_names(content, _locale) do
    territories =
      content
      |> get_in(["locale_display_names", "territories"])
      |> Consolidate.group_alt_content(&String.upcase/1)
      |> Cldr.Map.rename_keys(:default, :standard)
      |> Cldr.Map.atomize_keys()

    Map.put(content, "territories", territories)
  end
end
