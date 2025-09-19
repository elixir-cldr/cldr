# credo:disable-for-this-file
defmodule Cldr.Normalize.DateFields do
  @moduledoc false

  alias Cldr.Substitution

  def normalize(content, _locale) do
    updated_content =
      content
      |> normalize_date_fields

    Map.put(content, "date_fields", updated_content)
  end

  def normalize_date_fields(content) do
    date_fields_path = ["dates", "fields"]

    content
    |> get_in(date_fields_path)
    |> fold_default_content
    |> fold_variant_content
    |> normalize_elements
    |> Cldr.Map.rename_keys("dayperiod", "day_period")
    |> Cldr.Map.deep_map(&group_day_period/1,
      only: "day_period"
    )
    |> Cldr.Map.atomize_keys()
  end

  defp group_day_period({key, day_period}) do
    day_period =
      day_period
      |> Enum.map(fn {key, periods} ->
        {key, Cldr.Consolidate.group_by_alt(periods, "display_name")}
      end)
      |> Map.new()

    {key, day_period}
  end

  defp group_day_period(other) do
    other
  end

  defp fold_default_content(content) do
    Enum.reduce(base_keys(content), content, fn key, acc ->
      base_content =
        acc
        |> Map.get(key)
        |> normalize_content

      Map.put(acc, key, %{"default" => base_content})
    end)
  end

  defp fold_variant_content(content) do
    Enum.reduce(variant_keys(content), content, fn key, acc ->
      variant_content =
        acc
        |> Map.get(key)
        |> normalize_content

      [base_key, variant_key] = base_and_variant_from(key)

      Map.put(acc, base_key, Map.merge(acc[base_key], %{variant_key => variant_content}))
      |> Map.delete(key)
    end)
  end

  @relative_keys [
    "relative_type__1",
    "relative_type_0",
    "relative_type_1",
    "relative_type_2",
    "relative_type__2"
  ]

  defp normalize_content(content) do
    relative_ordinals = Enum.map(@relative_keys, &Map.get(content, &1))

    Map.put(content, "relative_ordinal", relative_ordinals)
    |> Map.drop(@relative_keys)
  end

  defp normalize_elements(content) do
    Enum.map(content, fn {element, data} ->
      {element, normalize_variant(data)}
    end)
    |> Enum.into(%{})
  end

  # Iterate over each item and normalize each variant
  defp normalize_variant(content) do
    Enum.map(content, fn {element, variant} ->
      {element, normalize_relative_times(variant)}
    end)
    |> Enum.into(%{})
  end

  defp normalize_relative_times(content) do
    Enum.map(content, fn
      {"relative_time_type_future", relative} ->
        {"relative_future", normalize_time_patterns(relative)}

      {"relative_time_type_past", relative} ->
        {"relative_past", normalize_time_patterns(relative)}

      {"relative_period", relative} ->
        {"relative_period", Substitution.parse(relative)}

      {key, value} ->
        {key, value}
    end)
    |> Enum.into(%{})
  end

  defp normalize_time_patterns(nil) do
    %{}
  end

  defp normalize_time_patterns(content) do
    content
    |> Enum.map(fn {"relative_time_pattern_count_" <> type, data} ->
      {type, Substitution.parse(data)}
    end)
    |> Enum.into(%{})
  end

  defp base_keys(content) do
    content
    |> Map.keys()
    |> Enum.reject(&(String.ends_with?(&1, "narrow") or String.ends_with?(&1, "short")))
  end

  defp variant_keys(content) do
    content
    |> Map.keys()
    |> Enum.filter(&(String.ends_with?(&1, "narrow") or String.ends_with?(&1, "short")))
  end

  defp base_and_variant_from(key) do
    parts = String.split(key, "_")

    variant =
      parts
      |> Enum.reverse()
      |> hd

    base =
      parts
      |> Enum.reverse()
      |> tl
      |> Enum.reverse()
      |> Enum.join("_")

    [base, variant]
  end
end
