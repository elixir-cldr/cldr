defmodule Cldr.Normalize.DateTime do
  @moduledoc false

  def normalize(content, locale) do
    content
    |> normalize_dates(locale)
  end

  @normalize_number_systems_for [
    "date_formats",
    "time_formats",
    "date_skeletons",
    "time_skeletons"
  ]

  def normalize_dates(content, _locale) do
    dates =
      content
      |> get_in(["dates"])
      |> Map.delete("fields")
      |> Cldr.Map.rename_keys("_numbers", "number_system")
      |> Cldr.Map.rename_keys("_value", "format")
      |> Cldr.Map.rename_keys("exemplar_city_alt_formal", "formal")
      |> Cldr.Map.underscore_keys(only: "intervalFormatFallback")
      |> Cldr.Map.deep_map(&normalize_number_system/1,
        filter: @normalize_number_systems_for,
        only: "number_system"
      )
      |> Cldr.Map.deep_map(&compile_items/1,
        filter: "date_time_formats",
        only: ["interval_format_fallback"]
      )
      |> Cldr.Map.deep_map(&compile_items/1,
        filter: "append_items"
      )
      |> Cldr.Map.deep_map(&compile_items/1,
        filter: "time_zone_names",
        only: ["gmt_format", "fallback_format"]
      )
      |> Cldr.Map.deep_map(&compile_items/1,
        filter: "month_patterns",
        only: "leap"
      )
      |> Cldr.Map.deep_map(&group_region_formats/1,
        only: "time_zone_names"
      )
      |> Cldr.Map.deep_map(&group_available_formats/1,
        filter: "date_time_formats",
        only: "available_formats"
      )
      |> Cldr.Map.deep_map(&group_interval_formats/1,
        filter: "date_time_formats",
        only: "interval_formats"
      )

    Map.put(content, "dates", dates)
  end

  defp compile_items({key, value}) when is_binary(value) do
    {key, Cldr.Substitution.parse(value)}
  end

  defp compile_items(other) do
    other
  end

  defp normalize_number_system({"number_system" = key, value}) do
    value =
      value
      |> String.split(";")
      |> Enum.map(&split_number_system/1)
      |> Map.new()

    {key, value}
  end

  defp split_number_system(system) do
    case String.split(system, "=") do
      [system] -> {"all", String.trim(system)}
      [format_code, system] -> {String.trim(format_code), String.trim(system)}
    end
  end

  def group_region_formats({"time_zone_names" = key, formats}) do
    {generic, formats} = Map.pop(formats, "region_format")
    {daylight, formats} = Map.pop(formats, "region_format_type_daylight")
    {standard, formats} = Map.pop(formats, "region_format_type_standard")

    region_formats = %{
      "generic" => Cldr.Substitution.parse(generic),
      "daylight_savings" => Cldr.Substitution.parse(daylight),
      "standard" => Cldr.Substitution.parse(standard)
    }

    formats = Map.put(formats, "region_format", region_formats)
    {key, formats}
  end

  # Some of these formats may have _count_ structures so we need to
  # group these. Assumes that a format is either -count-, -alt-variant
  # or -alt-ascii but not both.
  defp group_available_formats({"available_formats" = key, formats}) do
    formats =
      formats
      |> Enum.map(fn {name, format} ->
        case String.split(name, "-count-") do
          [_no_count] -> {name, format}
          [name, count] -> {name, %{count => format}}
        end
      end)
      |> Enum.map(fn {name, format} ->
        case String.split(name, "-alt-ascii") do
          [_no_count] -> {name, format}
          [ascii_format, ""] -> {ascii_format, %{ascii: format}}
        end
      end)
      |> Enum.map(fn {name, format} ->
        case String.split(name, "-alt-variant") do
          [_no_count] -> {name, format}
          [variant_format, ""] -> {variant_format, %{variant: format}}
        end
      end)
      |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
      |> Enum.map(fn
        {key, [item]} -> {key, item}
        {key, [format, %{ascii: ascii_format}]} -> {key, %{unicode: format, ascii: ascii_format}}
        {key, [%{ascii: ascii_format}, format]} -> {key, %{unicode: format, ascii: ascii_format}}
        {key, [format, %{variant: variant_format}]} -> {key, %{default: format, variant: variant_format}}
        {key, [%{variant: variant_format}, format]} -> {key, %{default: format, variant: variant_format}}
        {key, list} when is_list(list) -> {key, Cldr.Map.merge_map_list(list)}
      end)
      |> Map.new()

    {key, formats}
  end

  defp group_interval_formats({"interval_formats" = key, formats}) do
    formats =
      formats
      |> Enum.map(fn {interval_name, interval_formats} ->
          interval_formats = map_interval_formats(interval_formats)
          {interval_name, interval_formats}
      end)
      |> Map.new()

    {key, formats}
  end

  defp map_interval_formats(interval_formats) when is_map(interval_formats) do
    Enum.map(interval_formats, fn
      {name, format} ->
        case String.split(name, "-alt-variant") do
          [_no_count] -> {name, format}
          [variant_format, ""] -> {variant_format, %{variant: format}}
        end
    end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Enum.map(fn
      {key, [item]} -> {key, item}
      {key, [format, %{variant: variant_format}]} -> {key, %{default: format, variant: variant_format}}
      {key, [%{variant: variant_format}, format]} -> {key, %{default: format, variant: variant_format}}
      {key, list} when is_list(list) -> {key, Cldr.Map.merge_map_list(list)}
    end)
    |> Map.new()
  end

  defp map_interval_formats(interval_formats) do
    interval_formats
  end
end
