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
      |> Cldr.Map.rename_keys("_type", "type")
      |> Cldr.Map.rename_keys("exemplar_city_alt_formal", "formal")
      |> Cldr.Map.underscore_keys(only: "intervalFormatFallback")
      |> Cldr.Map.deep_map(&normalize_number_system/1,
        filter: @normalize_number_systems_for,
        only: "number_system"
      )
      |> Cldr.Map.deep_map(&compile_items/1,
        filter: "date_time_formats",
        only: ["interval_format_fallback", "short", "full", "long", "medium"]
      )
      |> Cldr.Map.deep_map(&compile_items/1,
        filter: "append_items"
      )
      |> Cldr.Map.deep_map(&compile_items/1,
        filter: "time_zone_names",
        only: ["gmt_format", "fallback_format"]
      )
      |> Cldr.Map.atomize_values(
        filter: "time_zone_names",
        only: ["type"]
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
      |> Cldr.Map.deep_map(&group_formats/1,
        only: "time_formats"
      )
      |> Cldr.Map.deep_map(&group_formats(&1, :standard),
        only: "date_formats"
      )
      |> Cldr.Map.deep_map(&group_day_periods/1,
        filter: "day_periods"
      )
      |> Cldr.Map.atomize_keys(filter: "calendars", skip: :number_system)
      |> Cldr.Map.atomize_keys(filter: "time_zone_names", level: 1..2)
      |> Cldr.Map.atomize_values(only: [:type])
      |> Cldr.Map.atomize_keys(level: 1..2)
      |> add_to_date_time_available_formats(:time_skeletons, :time_formats)
      |> add_to_date_time_available_formats(:date_skeletons, :date_formats)
      |> hoist(:append_items)
      |> hoist(:available_formats)
      |> hoist(:interval_formats)

    Map.put(content, "dates", dates)
  end

  # Move an item from date_time_formats to the base calendar
  # map.
  defp hoist(content, key) do
    calendars =
      Enum.map(content.calendars, fn {calendar, formats} ->
        item = Map.fetch!(formats.date_time_formats, key)
        date_time_formats = Map.delete(formats.date_time_formats, key)

        formats =
          formats
          |> Map.put(:date_time_formats, date_time_formats)
          |> Map.put(key, item)

        {calendar, formats}
      end)
      |> Map.new()

    Map.put(content, :calendars, calendars)
  end

  # Merge the predefined date and time formats into the available formats
  # list.
  defp add_to_date_time_available_formats(content, skeletons, standard_formats) do
    calendars =
      Enum.map(content.calendars, fn {calendar, formats} ->
        merged_standard_formats =
          Map.merge(formats[skeletons], formats[standard_formats], fn
            _k, a, b when is_binary(a) ->
              [String.to_atom(a), b]

            _k, %{format: skeleton}, b ->
              [String.to_atom(skeleton), b]
          end)

        new_standard_formats =
          Enum.map(merged_standard_formats, fn {format, [skeleton, _format_string]} ->
            {format, skeleton}
          end)
          |> Map.new()

        added_available_formats =
          merged_standard_formats
          |> Map.values()
          |> Enum.map(&List.to_tuple/1)
          |> Map.new()

        merged_available_formats =
          Map.merge(formats.date_time_formats.available_formats, added_available_formats)

        formats =
          formats
          |> put_in([:date_time_formats, :available_formats], merged_available_formats)
          |> put_in([standard_formats], new_standard_formats)
          |> Map.delete(skeletons)

        {calendar, formats}
      end)
      |> Map.new()

    Map.put(content, :calendars, calendars)
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

  defp group_day_periods({key, periods}) when key in ["narrow", "wide", "abbreviated"] do
    day_periods =
      periods
      |> Cldr.Consolidate.group_by_alt("am")
      |> Cldr.Consolidate.group_by_alt("pm")

    {key, day_periods}
  end

  defp group_day_periods(other) do
    other
  end

  defp group_formats(item, default \\ :unicode)

  defp group_formats({key, formats}, default) do
    formats =
      formats
      |> Cldr.Consolidate.group_by_alt("short", default: default)
      |> Cldr.Consolidate.group_by_alt("full", default: default)
      |> Cldr.Consolidate.group_by_alt("medium", default: default)
      |> Cldr.Consolidate.group_by_alt("long", default: default)
      |> Cldr.Consolidate.unnest_if_only_one(["short", "full", "medium", "long"])

    {key, formats}
  end

  defp group_formats(other, _) do
    other
  end

  def group_region_formats({"time_zone_names" = key, formats}) do
    {generic, formats} = Map.pop(formats, "region_format")
    {daylight, formats} = Map.pop(formats, "region_format_type_daylight")
    {standard, formats} = Map.pop(formats, "region_format_type_standard")

    region_formats = %{
      "generic" => Cldr.Substitution.parse(generic),
      "daylight" => Cldr.Substitution.parse(daylight),
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
        {key, [item]} ->
          {key, item}

        {key, [format, %{ascii: ascii_format}]} ->
          {key, %{unicode: format, ascii: ascii_format}}

        {key, [%{ascii: ascii_format}, format]} ->
          {key, %{unicode: format, ascii: ascii_format}}

        {key, [format, %{variant: variant_format}]} ->
          {key, %{default: format, variant: variant_format}}

        {key, [%{variant: variant_format}, format]} ->
          {key, %{default: format, variant: variant_format}}

        {key, list} when is_list(list) ->
          {key, Cldr.Map.merge_map_list(list)}
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
      {key, [item]} ->
        {key, item}

      {key, [format, %{variant: variant_format}]} ->
        {key, %{default: format, variant: variant_format}}

      {key, [%{variant: variant_format}, format]} ->
        {key, %{default: format, variant: variant_format}}

      {key, list} when is_list(list) ->
        {key, Cldr.Map.merge_map_list(list)}
    end)
    |> Map.new()
  end

  defp map_interval_formats(interval_formats) do
    interval_formats
  end
end
