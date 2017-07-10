defmodule Cldr.Date do

  @doc """
  Formats a date according to a format string
  as defined in CLDR and described in [TR35](http://unicode.org/reports/tr35/tr35-dates.html)

  * `date` is a `%Date{}` struct or any map that contains the keys
  `year`, `month`, `day` and `calendar`

  * `options` is a keyword list of options for formatting.
    * format: :short | :medium | :long | :full or a format string.  The default is :medium
    * locale: any locale returned by `Cldr.known_locales()`.  Default is `Cldr.get_current_locale()`

  ## Examples

  """
  @default_calendar :gregorian
  @format_types [:short, :medium, :long, :full]

  def to_string(date, options \\ [format: :medium, locale: Cldr.get_current_locale()])
  def to_string(date, options) do
    format(date, options[:format], options[:locale], options)
  end

  def format(%{calendar: calendar} = date, format, locale, options) do
    format = format_string_from_format(format, locale, calendar)

    case Cldr.DateTime.Compiler.tokenize(format) do
      {:ok, parse, _} ->
        Enum.map(parse, fn {token, _line, count} ->
          apply(__MODULE__, token, [date, count, locale, options])
        end)
        |> :erlang.iolist_to_binary
      {:error, reason} ->
        {:error, reason}
    end
  end

  def year_numeric(%{year: year}, 1, _locale, _options) do
    Integer.to_string(year)
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
    Integer.to_string(month)
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
    Integer.to_string(month)
  end

  def month_standalone(%{month: month}, 2, _locale, _options) do
    pad(month, 2)
  end

  def month_standalone(%{month: month, calendar: calendar}, 3, locale, _options) do
    get_month(month, locale, calendar, :standalone, :abbreviated)
  end

  def month_standalone(%{month: month, calendar: calendar}, 4, locale, _options) do
    get_month(month, locale, calendar, :standalone, :wide)
  end

  def month_standalone(%{month: month, calendar: calendar}, 5, locale, _options) do
    get_month(month, locale, calendar, :standalone, :narrow)
  end

  def day_of_month(%{day: day}, 1, _locale, _options) do
    Integer.to_string(day)
  end

  def day_of_month(%{day: day}, 2, _locale, _options) do
    pad(day, 2)
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

  def literal(_date, charlist, _locale, _options) do
    charlist
  end

  def get_month(month, locale, calendar, type, style) do
    cldr_calendar = type_from_calendar(calendar)

    locale
    |> Cldr.get_locale
    |> Map.get(:dates)
    |> get_in([:calendars, cldr_calendar, :months, type, style, Integer.to_string(month) |> String.to_existing_atom])
  end

  def get_day(%{year: year, month: month, day: day, calendar: calendar}, locale, type, style) do
    cldr_calendar = type_from_calendar(calendar)
    day_of_week = calendar.day_of_week(year, month, day) |> days

    locale
    |> Cldr.get_locale
    |> Map.get(:dates)
    |> get_in([:calendars, cldr_calendar, :days, type, style, day_of_week])
  end

  def days(1), do: :mon
  def days(2), do: :tue
  def days(3), do: :wed
  def days(4), do: :thu
  def days(5), do: :fri
  def days(6), do: :sat
  def days(7), do: :sun

  def format_string_from_format(format, locale, calendar) when format in @format_types do
    cldr_calendar = type_from_calendar(calendar)

    locale
    |> Cldr.get_locale
    |> Map.get(:dates)
    |> get_in([:calendars, cldr_calendar, :date_formats, format])
  end

  def format_string_from_format(format, _locale, _calendar) when is_binary(format) do
    format
  end

  def type_from_calendar(calendar) do
    if :cldr_calendar in Keyword.keys(calendar.__info__(:functions)) do
      calendar.cldr_calendar
    else
      @default_calendar
    end
  end

  defp pad(integer, n) when integer >= 0 do
    padding = n - Enum.count(Integer.digits(integer))
    if n <= 0 do
      integer
    else
      [List.duplicate(?0, padding), Integer.to_string(integer)]
    end
  end

  defp pad(integer, n) when integer < 0 do
    [?-, pad(abs(integer), n)]
  end
end