defmodule Cldr.Normalize.CalendarEra do
  @moduledoc false

  def convert_eras(calendar_data) do
    Enum.map(calendar_data, fn {calendar, content} ->
      {calendar, adjust_eras(content)}
    end)
    |> Enum.into(%{})
  end

  defp adjust_eras(%{"eras" => eras} = content) do
    eras =
      eras
      |> Enum.map(fn {era, dates} ->
        [String.to_integer(String.replace(era, "_", "-")), adjust_era(dates)]
      end)
      |> Enum.sort()

    Map.put(content, "eras", eras)
  end

  defp adjust_eras(%{} = content) do
    content
  end

  defp adjust_era(dates) do
    Enum.map(dates, fn
      {"start", date} -> {"start", split_date(date)}
      {"end", date} -> {"end", split_date(date)}
      {k, v} -> {k, v}
    end)
    |> Map.new()
  end

  def parse_time_periods(period_data) do
    Enum.map(period_data, fn {language, periods} ->
      {language, adjust_periods(periods)}
    end)
    |> Map.new()
  end

  defp adjust_periods(periods) do
    Enum.map(periods, fn {period, times} ->
      {period, adjust_times(times)}
    end)
    |> Map.new()
  end

  defp adjust_times(times) do
    Enum.map(times, fn {key, time} ->
      {key, Enum.map(String.split(time, ":"), &String.to_integer/1)}
    end)
    |> Map.new()
  end

  def split_date(%{year: year, month: month, day: day}) do
    [year, month, day]
  end

  def split_date(date) when is_binary(date) do
    {year, month, day} =
      case String.split(date, "-") do
        [year, month, day] ->
          {String.to_integer(year), String.to_integer(month), String.to_integer(day)}

        ["", year, month, day] ->
          {String.to_integer("-#{year}"), String.to_integer(month), String.to_integer(day)}
      end

    [year, month, day]
  end
end
