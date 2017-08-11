defmodule Cldr.DateTime.Formatter do
  alias Cldr.DateTime.{Format, Compiler}
  alias Cldr.Calendar, as: Kalendar
  alias Cldr.Math

  @default_calendar :gregorian

  def default_calendar do
    @default_calendar
  end

  # Insert generated functions for each locale and format here which
  # means that the lexing is done at compile time not runtime
  # which improves performance quite a bit.
  for format <- Format.format_list() do
    case Compiler.compile(format) do
      {:ok, transforms} ->
        def format(date, unquote(Macro.escape(format)) = f, locale, options) do
          number_system = if is_map(f), do: f[:number_system], else: options[:number_system]
          formatted = unquote(transforms)

          if error_list = format_errors(formatted) do
            {:error, Enum.join(error_list, "; ")}
          else
            formatted = formatted
            |> Enum.join
            |> transliterate(locale, number_system)

            {:ok, formatted}
          end
        end

      {:error, message} ->
        raise Cldr.FormatCompileError, "#{message} compiling date format: #{inspect format}"
    end
  end

  def format(date, format, locale, options) do
    case Compiler.tokenize(format) do
      {:ok, tokens, _} ->
        number_system = if is_map(format), do: format[:number_system], else: options[:number_system]
        formatted = apply_transforms(tokens, date, locale, options)

        if error_list = format_errors(formatted) do
          {:error, Enum.join(error_list, "; ")}
        else
          formatted = formatted
          |> Enum.join
          |> transliterate(locale, number_system)

          {:ok, formatted}
        end
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp apply_transforms(tokens, date, locale, options) do
    Enum.map tokens, fn {token, _line, count} ->
      apply(__MODULE__, token, [date, count, locale, options])
    end
  end

  defp transliterate(formatted, _locale, nil) do
    formatted
  end

  defp transliterate(formatted, locale, number_system) do
    Cldr.Number.Transliterate.transliterate(formatted, locale, number_system)
  end

  def format_errors(list) do
    errors =
      list
      |> Enum.filter(fn {:error, _reason} -> true; _ -> false end)
      |> Enum.map(fn {:error, reason} -> reason end)

    if Enum.empty?(errors), do: nil, else: errors
  end

  # Insert generated functions that will identify which time period key
  # is appropriate for a given time value.  Note that we sort the time
  # periods such that the "at" periods come before the "from"/"before"
  # periods so that the functions are defined in the right order.
  for {language, periods} <- Cldr.Config.day_periods() do
    for {period, times} <- Enum.sort(periods, fn {_k, v}, _p2 -> !!Map.get(v, "at") end) do
      case times do
        %{"at" => [h, m]} ->
          def time_period_for(%{hour: unquote(h), minute: unquote(m)}, unquote(language)) do
            unquote(String.to_existing_atom(period))
          end

        # For when the time range wraps around midnight
        %{"from" => [h1, 0], "before" => [h2, 0]} when h2 < h1 ->
          def time_period_for(%{hour: hour}, unquote(language))
          when rem(hour, 24) >= unquote(h1) or rem(hour, 24) < unquote(h2) do
            unquote(String.to_existing_atom(period))
          end

        # For when the time range does not wrap around midnight
        %{"from" => [h1, 0], "before" => [h2, 0]} ->
          def time_period_for(%{hour: hour}, unquote(language))
          when rem(hour, 24) >= unquote(h1) and rem(hour, 24) < unquote(h2) do
            unquote(String.to_existing_atom(period))
          end
      end
    end

    # We also need a way to find out of a language supports the
    # concept of "noon" and "midnight"
    if Map.get(periods, "noon") && Map.get(periods, "midnight")do
      def language_has_noon_and_midnight?(unquote(language)), do: true
    end
  end

  def language_has_noon_and_midnight?(_), do: false

  #
  # Date Formatters
  #

  @doc """
  Returns the `era` (format symbol `G`) of a date
  for given locale.

  The specific return string is determined by
  how many `G`s are in the format.
  """
  def era(%{year: _year, month: _month, day: _day, calendar: _calendar} = date, n, locale, options) when n in 1..3 do
    get_era(date, :era_abbr, locale, options)
  end

  def era(%{year: _year, month: _month, day: _day, calendar: _calendar} = date, 4, locale, options) do
    get_era(date, :era_names, locale, options)
  end

  def era(%{year: _year, month: _month, day: _day, calendar: _calendar} = date, 5, locale, options) do
    get_era(date, :era_narrow, locale, options)
  end

  def era(date, _n, _locale, _options) do
    error_return(date, "G", [:year, :month, :day, :calendar])
  end

  @doc """
  Returns the `year` (format symbol `y`) of a date
  as an integer. The `y` format returns the year
  as a simple integer.

  Calendar year (numeric). In most cases the length
  of the `y` field specifies the minimum number of
  digits to display, zero-padded as necessary; more
  digits will be displayed if needed to show the full
  year.

  However, `yy` requests just the two low-order digits
  of the year, zero-padded as necessary. For most use
  cases, `y` or `yy` should be adequate.
  """
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

  def year_numeric(date, _n, _locale, _options) do
    error_return(date, "y", [:year])
  end

  @doc """
  Returns the `year` (format symbol `Y`) in “Week of Year”
  based calendars in which the year transition occurs
  on a week boundary.

  The result may differ from calendar year ‘y’ near
  a year transition. This numeric year designation
  is used in conjunction with pattern character ‘w’
  in the ISO year-week calendar as defined
  by ISO 8601, but can be used in non-Gregorian based
  calendar systems where week date processing is desired.

  The field length is interpreted in the same was as for
  `y`; that is, `yy` specifies use of the two low-order
  year digits, while any other field length specifies a
  minimum number of digits to display.
  """
  def year_week_relative(%{year: _year, month: _month, day: _day, calendar: Calendar.ISO} = date, 2 = n, _locale, _options) do
    date
    |> Kalendar.last_week_of_year
    |> Map.get(:year)
    |> rem(100)
    |> pad(n)
  end

  def year_week_relative(%{year: _year, month: _month, day: _day, calendar: calendar} = date, 2 = n, _locale, _options) do
    date
    |> calendar.last_week_of_year
    |> Map.get(:year)
    |> rem(100)
    |> pad(n)
  end

  def year_week_relative(%{year: _year, month: _month, day: _day, calendar: Calendar.ISO} = date, n, _locale, _options) do
    date
    |> Kalendar.last_week_of_year
    |> Map.get(:year)
    |> pad(n)
  end

  def year_week_relative(%{year: _year, month: _month, day: _day, calendar: calendar} = date, n, _locale, _options) do
    date
    |> calendar.last_week_of_year
    |> Map.get(:year)
    |> pad(n)
  end

  def year_week_relative(date, _n, _locale, _options) do
    error_return(date, "Y", [:year, :month, :day, :calendar])
  end

  @doc """
  Returns the Extended year (format symbol `u`).

  This is a single number designating the year of this
  calendar system, encompassing all supra-year fields.

  For example, for the Julian calendar system, year
  numbers are positive, with an era of BCE or CE. An
  extended year value for the Julian calendar system
  assigns positive values to CE years and negative
  values to BCE years, with 1 BCE being year 0.

  For `u`, all field lengths specify a minimum number of
  digits; there is no special interpretation for `uu`.
  """
  def year_extended(%{year: year, calendar: Calendar.ISO}, n, _locale, _options) do
    pad(year, n)
  end

  def year_extended(%{year: _year, calendar: calendar} = date, n, _locale, _options) do
    date
    |> calendar.extended_year_from_date
    |> pad(n)
  end

  def year_extended(date, _n, _locale, _options) do
    error_return(date, "u", [:year, :calendar])
  end

  @doc """
  Returns the cyclic year (format symbol `U`) name for
  non-gregorian calendars.

  Cyclic year name. Calendars such as the Chinese lunar
  calendar (and related calendars) and the Hindu calendars
  use 60-year cycles of year names. If the calendar does
  not provide cyclic year name data, or if the year value
  to be formatted is out of the range of years for which
  cyclic name data is provided, then numeric formatting
  is used (behaves like format symbol `y`).

  Currently the data only provides abbreviated names,
  which will be used for all requested name widths.
  """
  def year_cyclic(%{year: year}, _n, _locale, _options) do
    year
  end

  def year_cyclic(date, _n, _locale, _options) do
    error_return(date, "U", [:year])
  end

  @doc """
  Returns the related gregorian year (format symbol `r`)
  of a date for given locale.

  The specific return string is determined by
  how many `r`s are in the format.

  This corresponds to the extended Gregorian year
  in which the calendar’s year begins. Related
  Gregorian years are often displayed, for example,
  when formatting dates in the Japanese calendar —
  e.g. “2012(平成24)年1月15日” — or in the Chinese
  calendar — e.g. “2012壬辰年腊月初四”. The related
  Gregorian year is usually displayed using the
  "latn" numbering system, regardless of what
  numbering systems may be used for other parts
  of the formatted date. If the calendar’s year
  is linked to the solar year (perhaps using leap
  months), then for that calendar the ‘r’ year
  will always be at a fixed offset from the ‘u’
  year. For the Gregorian calendar, the ‘r’ year
  is the same as the ‘u’ year. For ‘r’, all field
  lengths specify a minimum number of digits; there
  is no special interpretation for “rr”.
  """
  def year_related(%{year: year, calendar: Calendar.ISO}, _n, _locale, _options) do
    year
  end

  def year_related(%{} = date, _n, _locale, _options) do
    date
    |> Date.convert!(Calendar.ISO)
    |> Map.get(:year)
  end

  def year_related(date, _n, _locale, _options) do
    error_return(date, "r", [:year, :calendar])
  end

  @doc """
  Returns the `month` (format symbol `M`) of a date
  for given locale. The `M` format returns the month
  as a simple integer.

  The specific return string is determined by
  how many `M`s are in the format.
  """
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

  def month(date, _n, _locale, _options) do
    error_return(date, "M", [:month])
  end

  @doc """
  Returns the `month` (symbol `L`) in standalone format which is
  intended to formatted without an accompanying day (`d`).

  The specific return string is determined by
  how many `L`s are in the format.
  """
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

  def month_standalone(date, _n, _locale, _options) do
    error_return(date, "L", [:year, :month, :day, :calendar])
  end

  @doc """
  Returns the week of the year (symbol `w`) as an integer.

  The specific return string is determined by
  how many `w`s are in the format.

  Note that determining the week of the year is influenced
  by several factors:

  1. The calendar in use.  For example the ISO calendar (which
  is the default calendar in Elixir) follows the ISO standard
  in which the first week of the year is the week containing
  the first thursday of the year.

  2. The territory in use.  For example, in the US the first
  week of the year is the week containing January 1st whereas
  many territories follow the ISO standard.
  """
  def week_of_year(%{calendar: Calendar.ISO} = date, n, _locale, _options) do
    date
    |> Kalendar.week_of_year
    |> pad(n)
  end

  def week_of_year(%{calendar: calendar} = date, n, _locale, _options) do
    date
    |> calendar.week_of_year
    |> pad(n)
  end

  def week_of_year(date, _n, _locale, _options) do
    error_return(date, "w", [:year, :month, :day, :calendar])
  end

  @doc """
  Returns the week of the month (format symbol `W`) as an integer
  for a given `date`
  """
  def week_of_month(%{calendar: Calendar.ISO} = date, n, _locale, _options) do
    {first_of_month, _fraction} = Kalendar.iso_days_from_date(Kalendar.first_day_of_month(date))
    {days, _fraction} = Kalendar.iso_days_from_date(date)

    (days - first_of_month)
    |> div(7)
    |> pad(n)
  end

  def week_of_month(date, _n, _locale, _options) do
    error_return(date, "W", [:year, :month, :day, :calendar])
  end

  @doc """
  Returns the day of the month (symbol `M`) as an integer.

  The specific return string is determined by
  how many `M`s are in the format.
  """
  def day_of_month(%{day: day}, 1, _locale, _options) do
    day
  end

  def day_of_month(%{day: day}, 2, _locale, _options) do
    pad(day, 2)
  end

  def day_of_month(date, _n, _locale, _options) do
    error_return(date, "M", [:year, :month, :day, :calendar])
  end

  @doc """
  Returns the day of the year (symbol `D`) as an integer.

  The specific return string is determined by
  how many `D`s are in the format.
  """
  def day_of_year(%{} = date, n, _locale, _options) do
    date
    |> Kalendar.day_of_year
    |> pad(n)
  end

  def day_of_year(date, _n, _locale, _options) do
    error_return(date, "D", [:year, :month, :day, :calendar])
  end

  @doc """
  Returns the weekday name (format  symbol `E`) as an string.

  The specific return string is determined by
  how many `E`s are in the format.
  """
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

  def weekday_name(date, _n, _locale, _options) do
    error_return(date, "E", [:year, :month, :day, :calendar])
  end

  @doc """
  Returns the local day of week (format symbol `e`)
  number/name.

  Same as E except that it adds a numeric value that
  will depend on the local starting day of the week.

  Note that for 3 or more `e`s the return string is
  same as that for symbol `E`.
  """
  def weekday_number(%{year: year, month: month, day: day, calendar: calendar}, n, locale, _options)
  when n in 1..2 do
    iso_day_of_week = calendar.day_of_week(year, month, day)
    territory = Cldr.get_territory(locale)

    week_starts_on = get_in(Kalendar.week_data, [:first_day, territory])
    locale_day_of_week = day_ordinal(week_starts_on)

    # Now we have to convert the iso_day_of_week into
    # the day of the week the locale uses
    Math.amod(iso_day_of_week + locale_day_of_week - 1, 7)
    |> trunc
    |> pad(n)
  end

  def weekday_number(%{year: _year, month: _month, day: _day, calendar: _calendar} = date, n, locale, options) when n > 3 do
    weekday_name(date, n, locale, options)
  end

  def weekday_number(%{year: _year, month: _month, day: _day, calendar: _calendar} = date, _n, _locale, _options) do
    error_return(date, "e", [:year, :month, :day, :calendar])
  end

  @doc """
  Returns the Stand-Alone local day (format symbol `c`)
  of week number/name.

  This is the same as `weekday_number/4` except that
  it is intended for use without the associated `d`
  format symbol.
  """
  def standalone_day_of_week(%{year: _year, month: _month, day: _day, calendar: _calendar} = date, n, locale, _options)
  when n in 1..3 do
    get_day(date, locale, :stand_alone, :abbreviated)
  end

  def standalone_day_of_week(%{year: _year, month: _month, day: _day, calendar: _calendar} = date, 4, locale, _options) do
    get_day(date, locale, :stand_alone, :wide)
  end

  def standalone_day_of_week(%{year: _year, month: _month, day: _day, calendar: _calendar} = date, 5, locale, _options) do
    get_day(date, locale, :stand_alone, :narrow)
  end

  def standalone_day_of_week(%{year: _year, month: _month, day: _day, calendar: _calendar} = date, 6, locale, _options) do
    get_day(date, locale, :stand_alone, :short)
  end

  def standalone_day_of_week(%{year: _year, month: _month, day: _day, calendar: _calendar} = date, _n, _locale, _options) do
    error_return(date, "c", [:year, :month, :day, :calendar])
  end

  #
  # Time formatters
  #

  @doc """
  Returns a localised version of "am" or "pm" (format symbol `a`).

  May be upper or lowercase depending on the locale and other options.
  The wide form may be the same as the short form if the “real”
  long form (eg ante meridiem) is not customarily used.
  """
  def period_am_pm(%{hour: _hour} = time, n, locale, options)  do
    calendar = Map.get(time, :calendar, options[:calendar] || Calendar.ISO)
    type = period_type(n)

    key = am_or_pm(time, options[:variant])
    get_period(locale, calendar, :format, type, key, options)
  end

  def period_am_pm(time, _n, _locale, _options) do
    error_return(time, "a", [:hour])
  end

  @doc """
  Returns the formatting of the time period as either
  "noon", "midnight" or "am"/"pm" (format symbol 'b').

  If the langauge doesn't support "noon" or "midnight" then
  "am"/"pm" is used for all time periods.

  May be upper or lowercase depending on the locale and other options.
  If the locale doesn't the notion of a unique "noon" = 12:00,
  then the PM form may be substituted. Similarly for "midnight" = 00:00
  and the AM form.
  """
  def period_noon_mid(%{hour: hour, minute: minute} = time, n, locale, options)
  when (rem(hour, 12) == 0 or rem(hour, 24) == 0) and minute == 0 do
    calendar = Map.get(time, :calendar, options[:calendar] || Calendar.ISO)
    language = Cldr.language_from_locale(locale)
    type = period_type(n)

    if language_has_noon_and_midnight?(language) do
      time_period = time_period_for(time, language)
      get_period(locale, calendar, :format, type, time_period, options)
    else
      period_am_pm(time, n, locale, options)
    end
  end

  def period_noon_mid(%{hour: _hour, minute: _minute} = time, n, locale, options) do
    period_am_pm(time, n, locale, options)
  end

  def period_noon_mid(time, _n, _locale, _options) do
    error_return(time, "b", [:hour, :minute])
  end

  @doc """
  Returns the formatting of the time period as a string, for
  example "at night" (format symbol 'B').

  May be upper or lowercase depending on the locale and other options.
  Often there is only one width that is customarily used.
  """
  def period_flex(%{hour: _hour, minute: _minute} = time, n, locale, options) do
    calendar = Map.get(time, :calendar, options[:calendar] || Calendar.ISO)
    language = Cldr.language_from_locale(locale)
    time_period = time_period_for(time, language)
    type = period_type(n)

    get_period(locale, calendar, :format, type, time_period, options)
  end

  def period_flex(time, _n, _locale, _options) do
    error_return(time, "B", [:hour, :minute])
  end

  defp period_type(n) when n in 1..3, do: :abbreviated
  defp period_type(4), do: :wide
  defp period_type(5), do: :narrow

  defp am_or_pm(%{hour: hour, minute: _minute}, _variants) when hour < 12 do
    :am
  end

  defp am_or_pm(%{}, _variants) do
    :pm
  end

  def hour_1_12(%{hour: hour}, n, _locale, _options) do
    hour
    |> add(1)
    |> rem(12)
    |> pad(n)
  end

  def hour_0_11(%{hour: hour}, n, _locale, _options) do
    hour
    |> rem(12)
    |> pad(n)
  end

  def hour_1_24(%{hour: hour}, n, _locale, _options) do
    hour
    |> add(1)
    |> rem(24)
    |> pad(n)
  end

  def hour_0_23(%{hour: hour}, n, _locale, _options) do
    hour
    |> rem(24)
    |> pad(n)
  end

  def minute(%{minute: minute}, n, _locale, _options) do
    minute
    |> pad(n)
  end

  def second(%{second: second}, n, _locale, _options) do
    second
    |> pad(n)
  end

  @doc """
  Returns a literal.
  """
  def literal(_date, binary, _locale, _options) do
    binary
  end

  # Helpers

  defp get_era(%{calendar: calendar} = date, type, locale, options) do
    cldr_calendar = type_from_calendar(calendar)
    variant? = options[:variant]

    locale
    |> Cldr.get_locale
    |> Map.get(:dates)
    |> get_in([:calendars, cldr_calendar, :eras, type, era_key(date, cldr_calendar, variant?)])
  end

  defp era_key(date, calendar, variant?) do
    index = Kalendar.era_number_from_date(date, calendar)
    if variant? do
      :"#{index}_alt_variant"
    else
      index
    end
  end

  defp get_period(locale, calendar, type, style, key, _options) do
    cldr_calendar = type_from_calendar(calendar)

    locale
    |> Cldr.get_locale
    |> Map.get(:dates)
    |> get_in([:calendars, cldr_calendar, :day_periods, type, style, key])
  end

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

  # erlang/elixir standard is that Monday -> 1
  defp day_key(1), do: :mon
  defp day_key(2), do: :tue
  defp day_key(3), do: :wed
  defp day_key(4), do: :thu
  defp day_key(5), do: :fri
  defp day_key(6), do: :sat
  defp day_key(7), do: :sun

  defp day_ordinal("mon"), do: 1
  defp day_ordinal("tue"), do: 2
  defp day_ordinal("wed"), do: 3
  defp day_ordinal("thu"), do: 4
  defp day_ordinal("fri"), do: 5
  defp day_ordinal("sat"), do: 6
  defp day_ordinal("sun"), do: 7

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

  # This should be more performant than doing
  # Enum.count(Integer.digits(n)) for all cases
  defp number_of_digits(n) when n < 0, do: number_of_digits(abs(n))
  defp number_of_digits(n) when n < 10, do: 1
  defp number_of_digits(n) when n < 100, do: 2
  defp number_of_digits(n) when n < 1_000, do: 3
  defp number_of_digits(n) when n < 10_000, do: 4
  defp number_of_digits(n) when n < 100_000, do: 5
  defp number_of_digits(n) when n < 1_000_000, do: 6
  defp number_of_digits(n) when n < 10_000_000, do: 7
  defp number_of_digits(n) when n < 100_000_000, do: 8
  defp number_of_digits(n) when n < 1_000_000_000, do: 9
  defp number_of_digits(n) when n < 10_000_000_000, do: 10
  defp number_of_digits(n), do: Enum.count(Integer.digits(n))

  defp add(x, n) do
    x + n
  end

  def error_return(map, symbol, requirements) do
    {:error, "The format symbol '#{symbol}' requires at least #{inspect requirements}.  Found: #{inspect map}"}
  end
end