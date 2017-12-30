defmodule Cldr.Calendar.Conversion do
  def convert_eras_to_iso_days(calendar_data) do
    Enum.map(calendar_data, fn {calendar, content} ->
      {calendar, adjust_eras(content)}
    end)
    |> Enum.into(%{})
  end

  defp adjust_eras(%{"eras" => eras} = content) do
    eras =
      eras
      |> Enum.map(fn {era, dates} -> {era, adjust_era(dates)} end)
      |> Enum.into(%{})

    Map.put(content, "eras", eras)
  end

  defp adjust_eras(%{} = content) do
    content
  end

  defp adjust_era(dates) do
    Enum.map(dates, fn
      {"start", date} -> {"start", to_iso_days(date)}
      {"end", date} -> {"end", to_iso_days(date)}
      {k, v} -> {k, v}
    end)
    |> Enum.into(%{})
  end

  def parse_time_periods(period_data) do
    Enum.map(period_data, fn {language, periods} ->
      {language, adjust_periods(periods)}
    end)
    |> Enum.into(%{})
  end

  defp adjust_periods(periods) do
    Enum.map(periods, fn {period, times} ->
      {period, adjust_times(times)}
    end)
    |> Enum.into(%{})
  end

  defp adjust_times(times) do
    Enum.map(times, fn {key, time} ->
      {key, Enum.map(String.split(time, ":"), &String.to_integer/1)}
    end)
    |> Enum.into(%{})
  end

  def to_iso_days(%{year: year, month: month, day: day}) do
    gregorian_date_to_iso_days(year, month, day)
  end

  def to_iso_days(date) when is_binary(date) do
    {year, month, day} =
      case String.split(date, "-") do
        [year, month, day] ->
          {String.to_integer(year), String.to_integer(month), String.to_integer(day)}

        ["", year, month, day] ->
          {String.to_integer("-#{year}"), String.to_integer(month), String.to_integer(day)}
      end

    gregorian_date_to_iso_days(year, month, day)
  end

  @doc """
  Converts a `year`, `month` and `day` into a number of days
  for the gregorian calendar

  This should be done in the Calendar.ISO module but today that
  module doesnt handle negative years which are needed here.
  """
  def gregorian_date_to_iso_days(year, month, day) do
    correction =
      cond do
        month <= 2 -> 0
        leap_year?(year) -> -1
        true -> -2
      end

    (gregorian_epoch_days() - 1 + 365 * (year - 1) + Float.floor((year - 1) / 4) -
       Float.floor((year - 1) / 100) + Float.floor((year - 1) / 400) +
       Float.floor((367 * month - 362) / 12) + correction + day)
    |> trunc
  end

  @doc """
  Returns true if the given year is a leap year.
  """
  def leap_year?(year) when is_integer(year) do
    mod(year, 4) === 0 and (mod(year, 100) > 0 or mod(year, 400) === 0)
  end

  defp gregorian_epoch_days do
    1
  end

  def mod(x, y) when is_integer(x) and is_integer(y) do
    mod(x * 1.0, y) |> round
  end

  def mod(x, y) do
    x - y * Float.floor(x / y)
  end
end
