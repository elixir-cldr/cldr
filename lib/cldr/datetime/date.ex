defmodule Cldr.Date do
  alias Cldr.DateTime.{Format, Formatter, Compiler}

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
         {:ok, formatted} <- format(date, format_string, locale, options)
    do
      {:ok, formatted}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def to_string!(date, options \\ [])
  def to_string!(%{year: _year, month: _month, day: _day, calendar: _calendar} = date, options) do
    case to_string(date, options) do
      {:ok, string} -> string
      {:error, {exception, message}} -> raise exception, message
    end
  end

  # Insert generated functions for each locale and format here which
  # means that the lexing is done at compile time not runtime
  # which improves performance quite a bit.
  for format <- Format.date_format_list() do
    case Compiler.compile(format) do
      {:ok, transforms} ->
        defp format(date, unquote(Macro.escape(format)) = f, locale, options) do
          number_system = if is_map(f), do: f[:number_system], else: options[:number_system]
          formatted =
            unquote(transforms)
            |> Enum.join
            |> transliterate(locale, number_system)
          {:ok, formatted}
        end

      {:error, message} ->
        raise Cldr.FormatCompileError, "#{message} compiling date format: #{inspect format}"
    end
  end

  defp format(date, format, locale, options) do
    case Compiler.tokenize(format) do
      {:ok, tokens, _} ->
        number_system = if is_map(format), do: format[:number_system], else: options[:number_system]
        formatted =
          tokens
          |> apply_transforms(date, locale, options)
          |> Enum.join
          |> transliterate(locale, number_system)
        {:ok, formatted}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp apply_transforms(tokens, date, locale, options) do
    Enum.map tokens, fn {token, _line, count} ->
      apply(Formatter, token, [date, count, locale, options])
    end
  end

  defp transliterate(formatted, _locale, nil) do
    formatted
  end

  defp transliterate(formatted, locale, number_system) do
    Cldr.Number.Transliterate.transliterate(formatted, locale, number_system)
  end

  defp format_string_from_format(format, locale, calendar) when format in @format_types do
    cldr_calendar = Cldr.DateTime.Formatter.type_from_calendar(calendar)

    format_string =
      locale
      |> Cldr.get_locale
      |> Map.get(:dates)
      |> get_in([:calendars, cldr_calendar, :date_formats, format])
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
end