defmodule Cldr.Normalize.Delimiter do
  @moduledoc false

  def normalize(content, locale) do
    content
    |> normalize_delimiters(locale)
  end

  def normalize_delimiters(content, _locale) do
    delimiters =
      content
      |> Map.fetch!("delimiters")
      |> Cldr.Map.rename_keys("alternate_quotation_start", "quotation_start_alt_variant")
      |> Cldr.Map.rename_keys("alternate_quotation_end", "quotation_end_alt_variant")
      |> Cldr.Consolidate.group_by_alt("quotation_start")
      |> Cldr.Consolidate.group_by_alt("quotation_end")

    Map.put(content, "delimiters", delimiters)
  end
end
