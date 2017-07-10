defmodule Cldr.DateTime.Formatter do
  @default_calendar :gregorian

  # Era should be calculated after checking the era
  # ranges - this implementation is assuming positive
  # and negative years represent the era boundary which
  # is not correct for many calendars - some of which
  # have multiple eras (like the Japanese calendar)

  def era(date, n, locale, options) when n in 1..3 do
    get_era(date, :era_abbr, locale, options)
  end

  def era(date, 4, locale, options) do
    get_era(date, :era_names, locale, options)
  end

  def era(date, 5, locale, options) do
    get_era(date, :era_narrow, locale, options)
  end

  def year_numeric(%{year: year}, 1, _locale, _options) do
    year
  end

  def year_numeric(%{year: year}, 2 = n, _locale, _options) do
    year
    |> rem(100)
    |> pad(n)
  end

  def year_numeric(%{year: year}, n, _locale, _options) do
    pad(year, n)
  end

  def month(%{month: month}, 1, _locale, _options) do
    month
  end

  def month(%{month: month}, 2, _locale, _options) do
    pad(month, 2)
  end

  def month(%{month: month, calendar: calendar}, 3, locale, _options) do
    get_month(month, locale, calendar, :format, :abbreviated)
  end

  def month(%{month: month, calendar: calendar}, 4, locale, _options) do
    get_month(month, locale, calendar, :format, :wide)
  end

  def month(%{month: month, calendar: calendar}, 5, locale, _options) do
    get_month(month, locale, calendar, :format, :narrow)
  end

  def month_standalone(%{month: month}, 1, _locale, _options) do
    month
  end

  def month_standalone(%{month: month}, 2, _locale, _options) do
    pad(month, 2)
  end

  def month_standalone(%{month: month, calendar: calendar}, 3, locale, _options) do
    get_month(month, locale, calendar, :stand_alone, :abbreviated)
  end

  def month_standalone(%{month: month, calendar: calendar}, 4, locale, _options) do
    get_month(month, locale, calendar, :stand_alone, :wide)
  end

  def month_standalone(%{month: month, calendar: calendar}, 5, locale, _options) do
    get_month(month, locale, calendar, :stand_alone, :narrow)
  end

  def day_of_month(%{day: day}, 1, _locale, _options) do
    day
  end

  def day_of_month(%{day: day}, 2, _locale, _options) do
    pad(day, 2)
  end

  def day_of_year(%{year: year, calendar: calendar} = date, n, _locale, _options) do
    {days, _} = rata_die_from_date(date)
    {:ok, new_year} = Date.new(year, 1, 1, calendar)
    {new_years_day, _} = rata_die_from_date(new_year)
    pad(days - new_years_day + 1, n)
  end

  def weekday_name(date, n, locale, _options) when n in 1..3 do
    get_day(date, locale, :format, :abbreviated)
  end

  def weekday_name(date, 4, locale, _options) do
    get_day(date, locale, :format, :wide)
  end

  def weekday_name(date, 5, locale, _options) do
    get_day(date, locale, :format, :narrow)
  end

  def weekday_name(date, 6, locale, _options) do
    get_day(date, locale, :format, :short)
  end

  def weekday_number(date, 1, locale, options) do

  end

  def weekday_number(date, 2, locale, options) do

  end

  def weekday_number(date, n, locale, options) when n > 3 do
    weekday_name(date, n, locale, options)
  end

  def literal(_date, charlist, _locale, _options) do
    charlist
  end

  defp get_era(%{year: year, calendar: calendar}, type, locale, options) do
    cldr_calendar = type_from_calendar(calendar)

    locale
    |> Cldr.get_locale
    |> Map.get(:dates)
    |> get_in([:calendars, cldr_calendar, :eras, type, era_key(year, options[:variant])])
  end

  defp era_key(year, variant) when year >= 0 and is_nil(variant), do: 1
  defp era_key(year, variant) when year < 0 and is_nil(variant), do: 0
  defp era_key(year, _variant) when year >= 0, do: :"1_alt_variant"
  defp era_key(year, _variant) when year < 0, do: :"0_alt_variant"

  defp get_month(month, locale, calendar, type, style) do
    cldr_calendar = type_from_calendar(calendar)

    locale
    |> Cldr.get_locale
    |> Map.get(:dates)
    |> get_in([:calendars, cldr_calendar, :months, type, style, month])
  end

  defp get_day(%{year: year, month: month, day: day, calendar: calendar}, locale, type, style) do
    cldr_calendar = type_from_calendar(calendar)
    day_of_week = day_key(calendar.day_of_week(year, month, day))

    locale
    |> Cldr.get_locale
    |> Map.get(:dates)
    |> get_in([:calendars, cldr_calendar, :days, type, style, day_of_week])
  end

  defp day_key(1), do: :mon
  defp day_key(2), do: :tue
  defp day_key(3), do: :wed
  defp day_key(4), do: :thu
  defp day_key(5), do: :fri
  defp day_key(6), do: :sat
  defp day_key(7), do: :sun

  def type_from_calendar(calendar) do
    if :cldr_calendar in functions_exported(calendar) do
      calendar.cldr_calendar
    else
      @default_calendar
    end
  end

  defp functions_exported(calendar) do
    Keyword.keys(calendar.__info__(:functions))
  end

  defp pad(integer, n) when integer >= 0 do
    padding = n - number_of_digits(integer)
    if padding <= 0 do
      Integer.to_string(integer)
    else
      [List.duplicate(?0, padding), Integer.to_string(integer)]
    end
  end

  defp pad(integer, n) when integer < 0 do
    [?-, pad(abs(integer), n)]
  end

  defp number_of_digits(n) when n < 0, do: number_of_digits(abs(n))
  defp number_of_digits(n) when n < 10, do: 1
  defp number_of_digits(n) when n < 100, do: 2
  defp number_of_digits(n) when n < 1000, do: 3
  defp number_of_digits(n) when n < 10000, do: 4
  defp number_of_digits(n) when n < 100000, do: 5
  defp number_of_digits(n) when n < 1000000, do: 6
  defp number_of_digits(n) when n < 10000000, do: 7
  defp number_of_digits(n) when n < 100000000, do: 8
  defp number_of_digits(n) when n < 1000000000, do: 9
  defp number_of_digits(n) when n < 10000000000, do: 10
  defp number_of_digits(n), do: Enum.count(Integer.digits(n))

  defp rata_die_from_date(%Date{} = date) do
    date
    |> naive_datetime_from_date
    |> rata_die_from_naive_datetime
  end

  defp naive_datetime_from_date(%Date{year: year, month: month, day: day, calendar: calendar}) do
    {:ok, naive_datetime} = NaiveDateTime.new(year, month, day, 0, 0, 0, {0, 6}, calendar)
    naive_datetime
  end

  defp rata_die_from_naive_datetime(%NaiveDateTime{year: year, month: month, day: day,
                hour: hour, minute: minute, second: second, microsecond: microsecond,
                calendar: calendar}) do
    calendar.naive_datetime_to_rata_die(year, month, day, hour, minute, second, microsecond)
  end
end