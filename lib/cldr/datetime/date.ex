defmodule Cldr.Date do
  alias Cldr.DateTime.Formatter

  @doc """
  Formats a date according to a format string
  as defined in CLDR and described in [TR35](http://unicode.org/reports/tr35/tr35-dates.html)

  * `date` is a `%Date{}` struct or any map that contains the keys
  `year`, `month`, `day` and `calendar`

  * `options` is a keyword list of options for formatting.  The valid options are:
    * `format:` `:short` | `:medium` | `:long` | `:full` or a format string.  The default is `:medium`
    * `locale:` any locale returned by `Cldr.known_locales()`.  The default is `Cldr.get_current_locale()`
    * `number_system:` a number system into which the formatted date digits should be transliterated

  ## Examples

      iex> Cldr.Date.to_string ~D[2017-07-10], format: :medium
      {:ok, "Jul 10, 2017"}

      iex> Cldr.Date.to_string ~D[2017-07-10]
      {:ok, "Jul 10, 2017"}

      iex> Cldr.Date.to_string ~D[2017-07-10], format: :full
      {:ok, "Monday, July 10, 2017"}

      iex> Cldr.Date.to_string ~D[2017-07-10], format: :short
      {:ok, "7/10/17"}

      iex> Cldr.Date.to_string ~D[2017-07-10], format: :short, locale: "fr"
      {:ok, "10/07/2017"}

      iex> Cldr.Date.to_string ~D[2017-07-10], format: :long, locale: "af"
      {:ok, "10 Julie 2017"}
  """
  @format_types [:short, :medium, :long, :full]

  def to_string(date, options \\ [])
  def to_string(%{year: _year, month: _month, day: _day, calendar: calendar} = date, options) do
    default_options = [format: :medium, locale: Cldr.get_current_locale()]
    options = Keyword.merge(default_options, options)

    with {:ok, locale} <- Cldr.valid_locale?(options[:locale]),
         {:ok, format_string} <- format_string_from_format(options[:format], locale, calendar),
         {:ok, formatted} <- Formatter.format(date, format_string, locale, options)
    do
      {:ok, formatted}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def to_string(date, _options) do
    error_return(date, [:year, :month, :day, :calendar])
  end

  def to_string!(date, options \\ [])
  def to_string!(%{year: _year, month: _month, day: _day, calendar: _calendar} = date, options) do
    case to_string(date, options) do
      {:ok, string} -> string
      {:error, {exception, message}} -> raise exception, message
    end
  end

  defp format_string_from_format(format, locale, calendar) when format in @format_types do
    cldr_calendar = Cldr.DateTime.Formatter.type_from_calendar(calendar)

    format_string =
      locale
      |> date_formats_for(cldr_calendar)
      |> Map.get(format)

    {:ok, format_string}
  end

  defp format_string_from_format(%{number_system: number_system, format: format}, locale, calendar) do
    {:ok, format_string} = format_string_from_format(format, locale, calendar)
    {:ok, %{number_system: number_system, format: format_string}}
  end

  defp format_string_from_format(format, _locale, _calendar) when is_atom(format) do
    {:error, {Cldr.InvalidDateFormatType, "Invalid date format type.  " <>
              "The valid types are #{inspect @format_types}."}}
  end

  defp format_string_from_format(format_string, _locale, _calendar) when is_binary(format_string) do
    {:ok, format_string}
  end

  def error_return(map, requirements) do
    {:error, "Invalid date. Date is a map that requires at least #{inspect requirements} fields. " <>
             "Found: #{inspect map}"}
  end

  for locale <- Cldr.Config.known_locales() do
    locale_data = Cldr.Config.get_locale(locale)

    for calendar <- Cldr.Config.calendars_for_locale(locale_data) do
      time_formats =
        locale_data
        |> Map.get(:dates)
        |> get_in([:calendars, calendar, :date_formats])

      defp date_formats_for(unquote(locale), unquote(calendar)) do
        unquote(Macro.escape(time_formats))
      end
    end
  end
end