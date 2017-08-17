defmodule Cldr.Calendar do
  alias Cldr.DateTime.Compiler
  require Cldr

  # Default territory is "World"
  @default_territory :"001"

  @week_data Cldr.Config.week_data
  def week_data do
    @week_data
  end

  def minumim_days_in_week_1(territory \\ @default_territory) do
    get_in(week_data(), [:min_days, territory])
  end

  @calendar_data Cldr.Config.calendar_data
  def calendars do
    @calendar_data
  end

  def available_calendars do
    calendars()
    |> Map.keys
  end

  def era_number_from_date(date, calendar) do
    date
    |> Compiler.to_iso_days
    |> era_from_iso_days(calendar)
  end

  @doc """
  Returns the era number for a given rata die.

  The era number is an index into Cldr list of
  eras for a given calendar which is primarily
  for the use of `Cldr.Date.to_string/2` when
  processing the format symbol `G`. For further
  information see `Cldr.DateTime.Formatter.era/4`.
  """
  def era_from_iso_days(iso_days, calendar)

  for {calendar, content} <- @calendar_data do
    Enum.each content[:eras], fn
      {era, %{start: start, end: finish}} ->
        def era_from_iso_days(iso_days, unquote(calendar))
          when iso_days in unquote(start)..unquote(finish), do: unquote(era)
      {era, %{start: start}} ->
        def era_from_iso_days(iso_days, unquote(calendar))
          when iso_days >= unquote(start), do: unquote(era)
      {era, %{end: finish}} ->
        def era_from_iso_days(iso_days, unquote(calendar))
          when iso_days <= unquote(finish), do: unquote(era)
    end
  end

  def date_from_iso_days(days, calendar) do
    {year, month, day, _, _, _, _} = calendar.naive_datetime_from_iso_days(days)
    %{year: year, month: month, day: day, calendar: calendar}
  end

  def iso_days_from_date(%{year: _, month: _, day: _, calendar: _} = date) do
    date
    |> naive_datetime_from_date
    |> iso_days_from_datetime
  end

  def naive_datetime_from_date(%{year: year, month: month, day: day, calendar: calendar}) do
    {:ok, naive_datetime} = NaiveDateTime.new(year, month, day, 0, 0, 0, {0, 6}, calendar)
    naive_datetime
  end

  def iso_days_from_datetime(%NaiveDateTime{year: year, month: month, day: day,
                hour: hour, minute: minute, second: second, microsecond: microsecond,
                calendar: calendar}) do
    calendar.naive_datetime_to_iso_days(year, month, day, hour, minute, second, microsecond)
  end

  def iso_days_from_datetime(%DateTime{year: year, month: month, day: day,
                hour: hour, minute: minute, second: second, microsecond: microsecond,
                calendar: calendar, zone_abbr: "UTC", time_zone: "Etc/UTC"}) do
    calendar.naive_datetime_to_iso_days(year, month, day, hour, minute, second, microsecond)
  end

  def day_of_year(%{year: year, calendar: calendar} = date) do
    {days, _fraction} = iso_days_from_date(date)
    {new_year, _fraction} = iso_days_from_date(%{year: year, month: 1, day: 1, calendar: calendar})
    days - new_year
  end

  def day_of_week(%{year: year, month: month, day: day, calendar: calendar}) do
    calendar.day_of_week(year, month, day)
  end

  defdelegate new_year(date), to: __MODULE__, as: :first_day_of_year
  def first_day_of_year(%{year: _year} = date) do
    date
    |> Map.put(:month, 1)
    |> Map.put(:day, 1)
  end

  def last_day_of_year(%{year: _year} = date) do
    date
    |> Map.put(:month, 12)
    |> Map.put(:day, 31)
  end

  @doc """
  Returns the date of the first day of the first week of the year that includes
  the provided `date`.

  This conforms with the ISO standard definition of when the first week of the year
  begins:

  * If 1 January is on a Monday, Tuesday, Wednesday or Thursday, it is in week 01.
  * If 1 January is on a Friday, it is part of week 53 of the previous year;
  * If on a Saturday, it is part of week 52 (or 53 if the previous Gregorian year was a leap year)
  * If on a Sunday, it is part of week 52 of the previous year.
  """
  def first_week_of_year(%{year: year, calendar: calendar} = date) do
    first_week_starts = first_week_of_year(year, calendar)

    if Date.diff(date, first_week_starts) >= 365 do
      first_week_of_year(year + 1)
    else
      first_week_starts
    end
  end

  def first_week_of_year(year, calendar \\ Calendar.ISO) when is_integer(year) do
    new_year = new_year(%{year: year, month: 1, day: 1, calendar: calendar})
    {days, _fraction} = iso_days_from_date(new_year)
    case day_of_week(new_year) do
      day when day in 1..4 ->
        date_from_iso_days({days - day + 1, {0, 1}}, calendar)
      day when day in 5..7 ->
        date_from_iso_days({days - day + 1 + 7, {0, 1}}, calendar)
    end
  end

  @doc """
  Returns the date of the first day of the first week of the year that includes
  the provided `date`.

  This conforms with the ISO standard definition of when the first week of the year
  begins:

  * If 31 December is on a Monday, Tuesday or Wednesday, it is in week 01 of the next year.
  * If it is on a Thursday, it is in week 53 of the year just ending;
  * If on a Friday it is in week 52 (or 53 if the year just ending is a leap year);
  * If on a Saturday or Sunday, it is in week 52 of the year just ending.
  """
  def last_week_of_year(%{year: year, calendar: calendar} = date) do
    last_week = last_week_of_year(year, calendar)

    # Its possible that the last week of year finishes before the
    # date provided so we need to see if thats the case and then get the
    # last week of the next year
    {last_week_starts, _fraction} = iso_days_from_date(last_week)
    last_week_ends = last_week_starts + 6
    days = iso_days_from_date(date)

    if days > last_week_ends do
      last_week_of_year(year + 1, calendar)
    else
      last_week
    end
  end

  def last_week_of_year(year, calendar \\ Calendar.ISO) when is_integer(year) do
    first_week_of_next_year = first_week_of_year(year + 1)
    {days, _fraction} = iso_days_from_date(first_week_of_next_year)
    date_from_iso_days({days - 7, {0, 1}}, calendar)
  end

  @doc """
  Returns the date that is the first day of the `n`th week of
  the given `date`
  """
  def nth_week_of_year(%{year: year, calendar: calendar}, n) do
    nth_week_of_year(year, n, calendar)
  end

  def nth_week_of_year(year, n, calendar \\ Calendar.ISO) do
    first_week = first_week_of_year(year)
    {first_week_starts, _fraction} = iso_days_from_date(first_week)

    date_from_iso_days({first_week_starts + ((n - 1) * 7), {0, 1}}, calendar)
  end

  @doc """
  Returns the week of the year for the given date.

  Note that for some calendars (like `Calendar.ISO`), the first week
  of the year may not be the week that includes January 1st therefore
  for some dates near the start or end of the year, the week number
  may refer to a date in the following or previous year.

  ## Examples

  """
  def week_of_year(%{year: year, month: _month, day: _day, calendar: _calendar} = date) do
    week = div(day_of_year(date) - day_of_week(date) + 10, 7)
    cond do
      week >= 1 and week < 53 -> week
      week < 1 -> week_of_year(last_week_of_year(year - 1))
      week > week_of_year(last_week_of_year(year - 1)) -> 1
    end
  end

  @doc """
  Returns the number of weeks in a year

  ## Examples

      iex> Cldr.Calendar.weeks_in_year 2008
      52
      iex> Cldr.Calendar.weeks_in_year 2009
      53
      iex> Cldr.Calendar.weeks_in_year 2017
      52
  """
  def weeks_in_year(%{year: year}) do
    if leap_mod(year) == 4 or leap_mod(year - 1) == 3, do: 53, else: 52
  end

  def weeks_in_year(year, calendar \\ Calendar.ISO) do
    weeks_in_year(%{year: year, month: 1, day: 1, calendar: calendar})
  end

  @doc """
  Returns the first day of the month.

  Note that whilst this is trivial for an ISO/Gregorian calendar it may
  well be quite different for other types of calendars
  """
  def first_day_of_month(%{year: _year, month: _month, calendar: Calendar.ISO} = date) do
    date
    |> Map.put(:day, 1)
  end

  defp leap_mod(year) do
    rem(year + div(year, 4) - div(year, 100) + div(year, 400), 7)
  end

  def year(%{calendar: Calendar.ISO} = date) do
    date
    |> last_week_of_year
    |> Map.get(:year)
  end

  def iso_days_to_float({days, {numerator, denominator}}) do
    days + (numerator / denominator)
  end

  def calendar_error(calendar_name) do
    {Cldr.UnknownCalendarError, "The calendar #{inspect calendar_name} is not known."}
  end
  #
  # Data storage functions
  #

  for locale <- Cldr.known_locales() do
    date_data =
      locale
      |> Cldr.Config.get_locale
      |> Map.get(:dates)

    calendars = Map.get(date_data, :calendars) |> Map.keys

    for calendar <- calendars do
      def era(unquote(locale), unquote(calendar)) do
        unquote(Macro.escape(get_in(date_data, [:calendars, calendar, :eras])))
      end

      def period(unquote(locale), unquote(calendar)) do
        unquote(Macro.escape(get_in(date_data, [:calendars, calendar, :day_periods])))
      end

      def month(unquote(locale), unquote(calendar)) do
        unquote(Macro.escape(get_in(date_data, [:calendars, calendar, :months])))
      end

      def day(unquote(locale), unquote(calendar)) do
        unquote(Macro.escape(get_in(date_data, [:calendars, calendar, :days])))
      end
    end
  end
end

