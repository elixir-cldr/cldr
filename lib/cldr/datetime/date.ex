defmodule Cldr.Date do

  @doc """
  Formats a date according to a format string
  as defined in CLDR and described in [TR35](http://unicode.org/reports/tr35/tr35-dates.html)

  * `date` is a `%Date{}` struct or any map that contains the keys
  `year`, `month`, `day` and `calendar`

  * `options` is a keyword list of options for formatting.  The valid options are:
    * `format:` `:short` | `:medium` | `:long` | `:full` or a format string.  The default is `:medium`
    * `locale:` any locale returned by `Cldr.known_locales()`.  The default is `Cldr.get_current_locale()`

  ## Examples

      iex> Cldr.Date.to_string ~D[2017-07-10], format: :medium
      {:ok, "10 Jul 2017"}

      iex> Cldr.Date.to_string ~D[2017-07-10]
      {:ok, "10 Jul 2017"}

      iex> Cldr.Date.to_string ~D[2017-07-10], format: :full
      {:ok, "Monday, 10 July 2017"}

      iex> Cldr.Date.to_string ~D[2017-07-10], format: :short
      {:ok, "10/7/17"}

      iex> Cldr.Date.to_string ~D[2017-07-10], format: :short, locale: "fr"
      {:ok, "10/07/2017"}

      iex> Cldr.Date.to_string ~D[2017-07-10], format: :long, locale: "af"
      {:ok, "10 Julie 2017"}
  """
  @default_calendar :gregorian
  @format_types [:short, :medium, :long, :full]
  @default_options [format: :medium, locale: Cldr.get_current_locale()]

  def to_string(date, options \\ @default_options)
  def to_string(%{calendar: calendar} = date, options) do
    options = Keyword.merge(@default_options, options)

    with {:ok, locale} <- Cldr.valid_locale?(options[:locale]),
         {:ok, format_string} <- format_string_from_format(options[:format], locale, calendar),
         {:ok, formatted} <- format(date, format_string, locale, options)
    do
      {:ok, formatted}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def to_string!(date, options \\ @default_options) do
    case to_string(date, options) do
      {:ok, string} -> string
      {:error, {exception, message}} -> raise exception, message
    end
  end

  defp format(date, format, locale, options) do
    case Cldr.DateTime.Compiler.tokenize(format) do
      {:ok, tokens, _} ->
        formatted =
          tokens
          |> apply_transforms(date, locale, options)
          |> Enum.join
        {:ok, formatted}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp apply_transforms(tokens, date, locale, options) do
    Enum.map tokens, fn {token, _line, count} ->
      apply(__MODULE__, token, [date, count, locale, options])
    end
  end

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

  # Should be using calendar data to establish start of era (ie epoch())
  # Note its also only good for calendars with a maximum of 2 eras
  # Other calendars, like the Japanese, have many eras.
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

  defp format_string_from_format(format, locale, calendar) when format in @format_types do
    cldr_calendar = type_from_calendar(calendar)

    format_string =
      locale
      |> Cldr.get_locale
      |> Map.get(:dates)
      |> get_in([:calendars, cldr_calendar, :date_formats, format])
    {:ok, format_string}
  end

  defp format_string_from_format(format, _locale, _calendar) when is_atom(format) do
    {:error, {Cldr.InvalidDateFormatType, "Invalid date format type.  " <>
              "The valid types are #{inspect @format_types}."}}
  end

  defp format_string_from_format(format_string, _locale, _calendar) when is_binary(format_string) do
    {:ok, format_string}
  end

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