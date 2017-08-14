defmodule Cldr.DateTime.Relative do
  @moduledoc """
  Functions to support the string formatting of relative time/datetime numbers.
  This allows for the formatting of numbers (as integers, floats, Dates or DateTimes)
  as "ago" or "in" with an appropriate time unit.  For example, "2 days ago" or
  "in 10 seconds"
  """
  @default_options [locale: Cldr.get_current_locale(), format: :default]

  @second 1
  @minute 60
  @hour   3600
  @day    86400
  @week   604800
  @month  2629743.83
  @year   31556926

  @unit %{
    second: @second,
    minute: @minute,
    hour:   @hour,
    day:    @day,
    week:   @week,
    month:  @month,
    year:   @year
  }

  @other_units [:mon, :tue, :wed, :thu, :fri, :sat, :sun, :quarter]
  @unit_keys Map.keys(@unit) ++ @other_units

  @doc """
  Returns a string representing a relative time (ago, in) for a given
  number, Date or Datetime.

  * `relative` is a number or Date/Datetime representing the time distance from `now` or from
  options[:relative_to]

  * `options` is a `Keyword` list of options which are:

    * `:locale` is the locale in which the binary is formatted.  The default is `Cldr.get_current_locale/0`
    * `:format` is the format of the binary.  Format may be `:default`, `:narrow` or `:short`
    * `:unit` is the time unit for the formatting.  The allowable units are `:second`, `:minute`,
    `:hour`, `:day`, `:week`, `:month`, `:year`, `:mon`, `:tue`, `:wed`, `:thu`, `:fri`, `:sat`,
    `:sun`, `:quarter`
    * `:relative_to` is the baseline Date or Datetime from which the difference from `relative` is
    calculated when `relative` is a Date or a DateTime. The default for a Date is `Date.utc_today`,
    for a DateTime it is `DateTime.utc_now`

  ## Examples

      iex> Cldr.DateTime.Relative.to_string(-1)
      "1 second ago"

      iex> Cldr.DateTime.Relative.to_string(1)
      "in 1 second"

      iex> Cldr.DateTime.Relative.to_string(1, unit: :day)
      "tomorrow"

      iex> Cldr.DateTime.Relative.to_string(1, unit: :day, locale: "fr")
      "demain"

      iex> Cldr.DateTime.Relative.to_string(1, unit: :day, format: :narrow)
      "tomorrow"

      iex> Cldr.DateTime.Relative.to_string(1234, unit: :year)
      "in 1,234 years"

      iex> Cldr.DateTime.Relative.to_string(1234, unit: :year, locale: "fr")
      "dans 1 234 ans"

      iex> Cldr.DateTime.Relative.to_string(31)
      "in 31 seconds"

      iex> Cldr.DateTime.Relative.to_string(~D[2017-04-29], relative_to: ~D[2017-04-26])
      "in 3 days"

      iex> Cldr.DateTime.Relative.to_string(310, format: :short, locale: "fr")
      "dans 5 min"

      iex> Cldr.DateTime.Relative.to_string(310, format: :narrow, locale: "fr")
      "+5 min"

      iex> Cldr.DateTime.Relative.to_string 2, unit: :wed, format: :short
      "in 2 Wed."

      iex> Cldr.DateTime.Relative.to_string 1, unit: :wed, format: :short
      "next Wed."

      iex> Cldr.DateTime.Relative.to_string -1, unit: :wed, format: :short
      "last Wed."

      iex> Cldr.DateTime.Relative.to_string -1, unit: :wed
      "last Wednesday"

      iex> Cldr.DateTime.Relative.to_string -1, unit: :quarter
      "last quarter"

      iex> Cldr.DateTime.Relative.to_string -1, unit: :mon, locale: "fr"
      "lundi dernier"

      iex> Cldr.DateTime.Relative.to_string(~D[2017-04-29], unit: :ziggeraut)
      {:error,
       "Unknown time unit :ziggeraut.  Valid time units are [:day, :hour, :minute, :month, :second, :week, :year, :mon, :tue, :wed, :thu, :fri, :sat, :sun, :quarter]"}

  ## Notes

  When `options[:unit]` is not specified, `Cldr.DateTime.Relative.to_string/2` attempts to identify
  the appropriate unit based upon the magnitude of `relative`.  For example, given a parameter
  of less than `60`, then `to_string/2` will assume `:seconds` as the unit.
  """
  @spec to_string(integer | float | Date.t | DateTime.t, []) :: binary
  def to_string(relative, options \\ []) do
    options = Keyword.merge(@default_options, options)
    unit = Keyword.get(options, :unit)
    locale = Keyword.get(options, :locale)
    options = Keyword.delete(options, :unit)
    to_string(relative, unit, locale, options)
  end

  defp to_string(relative, nil, locale, options)
  when is_integer(relative) and relative in [-1, 0, +1] do
    unit = unit_from_seconds(relative)

    binary = to_string(relative, unit, locale, options)
    if is_nil(binary) do
      to_string(relative * 1.0, unit, locale, options)
    else
      binary
    end
  end

  defp to_string(relative, unit, locale, options)
  when is_integer(relative) and relative in [-1, 0, +1] do
    locale
    |> get_locale()
    |> get_in([unit, options[:format], :relative_ordinal])
    |> Enum.at(relative + 1)
  end

  defp to_string(relative, unit, locale, options)
  when is_number(relative) and unit in @unit_keys do
    direction = if relative > 0, do: :relative_future, else: :relative_past

    rules =
      locale
      |> get_locale()
      |> get_in([unit, options[:format], direction])

    rule = Cldr.Number.Cardinal.pluralize(trunc(relative), locale, rules)

    relative
    |> abs
    |> Cldr.Number.to_string(locale: locale)
    |> Cldr.Substitution.substitute(rule)
    |> Enum.join
  end

  defp to_string(%DateTime{} = relative, unit, locale, options) do
    now = (options[:relative_to] || DateTime.utc_now) |> DateTime.to_unix
    then = DateTime.to_unix(relative)
    seconds = then - now
    do_to_string(seconds, unit, locale, options)
  end

  defp to_string(%Date{} = relative, unit, locale, options) do
    today = (options[:relative_to] || Date.utc_today)
    |> Date.to_erl
    |> :calendar.date_to_gregorian_days
    |> Kernel.*(@day)

    then = relative
    |> Date.to_erl
    |> :calendar.date_to_gregorian_days
    |> Kernel.*(@day)

    seconds = then - today
    do_to_string(seconds, unit, locale, options)
  end

  defp to_string(span, unit, locale, options) do
    do_to_string(span, unit, locale, options)
  end

  defp do_to_string(seconds, nil, locale, options) do
    do_to_string(seconds, unit_from_seconds(seconds), locale, options)
  end

  defp do_to_string(seconds, unit, locale, options) when unit in @unit_keys do
    seconds
    |> calculate_unit(unit)
    |> to_string(unit, locale, options)
  end

  defp do_to_string(_, unit, _, _) do
    {:error, "Unknown time unit #{inspect unit}.  Valid time units are #{inspect @unit_keys}"}
  end

  @doc """
  Returns an estimate of the appropriate time unit for an integer of a given
  magnitude of seconds.

  ## Examples

      iex> Cldr.DateTime.Relative.unit_from_seconds(1234)
      :minute

      iex> Cldr.DateTime.Relative.unit_from_seconds(12345)
      :hour

      iex> Cldr.DateTime.Relative.unit_from_seconds(123456)
      :day

      iex> Cldr.DateTime.Relative.unit_from_seconds(1234567)
      :week

      iex> Cldr.DateTime.Relative.unit_from_seconds(12345678)
      :month

      iex> Cldr.DateTime.Relative.unit_from_seconds(123456789)
      :year
  """
  def unit_from_seconds(seconds) do
    case abs(seconds) do
      i when i < @minute  -> :second
      i when i < @hour    -> :minute
      i when i < @day     -> :hour
      i when i < @week    -> :day
      i when i < @month   -> :week
      i when i < @year    -> :month
      _                   -> :year
    end
  end

  @doc """
  Calculates the time span in the given `unit` from the time given in seconds.

  ## Examples

      iex> Cldr.DateTime.Relative.calculate_unit(1234, :second)
      1234

      iex> Cldr.DateTime.Relative.calculate_unit(1234, :minute)
      21

      iex> Cldr.DateTime.Relative.calculate_unit(1234, :hour  )
      0
  """
  def calculate_unit(seconds, unit) do
    (seconds / @unit[unit])
    |> Float.round
    |> trunc
  end

  @doc """
  Returns a list of the valid unit keys for `to_string/2`

  ## Example

      iex> Cldr.DateTime.Relative.known_units
      [:day, :hour, :minute, :month, :second, :week, :year, :mon, :tue, :wed, :thu,
       :fri, :sat, :sun, :quarter]
  """
  def known_units do
    @unit_keys
  end

  for locale <- Cldr.Config.known_locales() do
    locale_data =
      locale
      |> Cldr.Config.get_locale
      |> Map.get(:date_fields)
      |> Map.take(@unit_keys)

    defp get_locale(unquote(locale)), do: unquote(Macro.escape(locale_data))
  end
end