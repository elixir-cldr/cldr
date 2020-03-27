# credo:disable-for-this-file
defmodule Cldr.Normalize.Calendar do
  @moduledoc false

  @calendar_location ["dates", "calendars"]

  def normalize(content, _locale) do
    updated_content =
      content
      |> normalize_calendar

    put_in(content, @calendar_location, updated_content)
  end

  def normalize_calendar(content) do
    date_fields_path = @calendar_location

    content
    |> get_in(date_fields_path)
    |> rename_day_name_keys
    |> rename_era_keys
    |> rename_variants
  end

  def rename_day_name_keys(content) do
    content
    |> Cldr.Map.rename_keys("mon", 1)
    |> Cldr.Map.rename_keys("tue", 2)
    |> Cldr.Map.rename_keys("wed", 3)
    |> Cldr.Map.rename_keys("thu", 4)
    |> Cldr.Map.rename_keys("fri", 5)
    |> Cldr.Map.rename_keys("sat", 6)
    |> Cldr.Map.rename_keys("sun", 7)
  end

  def rename_era_keys(content) do
    content
    |> Cldr.Map.rename_keys("era_abbr", "abbreviated")
    |> Cldr.Map.rename_keys("era_narrow", "narrow")
    |> Cldr.Map.rename_keys("era_names", "wide")
  end

  def rename_variants(content) do
    content
    |> Cldr.Map.rename_keys("0_alt_variant", -1)
    |> Cldr.Map.rename_keys("1_alt_variant", -2)
  end
end
