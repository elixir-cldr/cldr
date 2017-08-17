defmodule Cldr.Time do
  alias Cldr.DateTime.{Format, Formatter}

  @doc """
  Formats a time according to a format string
  as defined in CLDR and described in [TR35](http://unicode.org/reports/tr35/tr35-dates.html)

  * `time` is a `%DateTime{}` or `%NaiveDateTime{}` struct or any map that contains the keys
  `hour`, `minute`, `second` and optionally `calendar` and `microsecond`

  * `options` is a keyword list of options for formatting.  The valid options are:
    * `format:` `:short` | `:medium` | `:long` | `:full` or a format string.  The default is `:medium`
    * `locale:` any locale returned by `Cldr.known_locales()`.  The default is `Cldr.get_current_locale()`
    * `number_system:` a number system into which the formatted date digits should be transliterated

  ## Examples


  """
  @format_types [:short, :medium, :long, :full]

  def to_string(time, options \\ [])
  def to_string(%{hour: _hour, minute: _minute} = time, options) do
    default_options = [format: :medium, locale: Cldr.get_current_locale()]
    options = Keyword.merge(default_options, options)
    calendar = Map.get(time, :calendar) || Calendar.ISO

    with {:ok, locale} <- Cldr.valid_locale?(options[:locale]),
         {:ok, cldr_calendar} <- Formatter.type_from_calendar(calendar),
         {:ok, format_string} <- format_string_from_format(options[:format], locale, cldr_calendar),
         {:ok, formatted} <- Formatter.format(time, format_string, locale, options)
    do
      {:ok, formatted}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def to_string(time, _options) do
    error_return(time, [:hour, :minute, :second])
  end

  def to_string!(time, options \\ [])
  def to_string!(time, options) do
    case to_string(time, options) do
      {:ok, string} -> string
      {:error, {exception, message}} -> raise exception, message
    end
  end

  defp format_string_from_format(format, locale, calendar) when format in @format_types do
    format_string =
      locale
      |> Format.time_formats(calendar)
      |> Map.get(format)

    {:ok, format_string}
  end

  defp format_string_from_format(%{number_system: number_system, format: format}, locale, calendar) do
    {:ok, format_string} = format_string_from_format(format, locale, calendar)
    {:ok, %{number_system: number_system, format: format_string}}
  end

  defp format_string_from_format(format, _locale, _calendar) when is_atom(format) do
    {:error, {Cldr.InvalidTimeFormatType, "Invalid time format type.  " <>
              "The valid types are #{inspect @format_types}."}}
  end

  defp format_string_from_format(format_string, _locale, _calendar) when is_binary(format_string) do
    {:ok, format_string}
  end

  def error_return(map, requirements) do
    {:error, "Invalid time. Time is a map that requires at least #{inspect requirements} fields. " <>
             "Found: #{inspect map}"}
  end
end