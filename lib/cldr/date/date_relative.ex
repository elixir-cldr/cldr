defmodule Cldr.Date.Relative do
  @default_options [locale: Cldr.get_locale(), format: :default]

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

  @unit_keys Map.keys(@unit)

  def to_string(relative, options \\ []) do
    options = Keyword.merge(@default_options, options)
    unit = Keyword.get(options, :unit)
    options = Keyword.delete(options, :unit)
    to_string(relative, unit, options)
  end

  defp to_string(relative, :day = unit, options)
  when is_integer(relative) and relative in [-1, 0, +1] do
    options[:locale]
    |> Cldr.Locale.get_locale
    |> get_in([:date_fields, unit, options[:format], :relative_ordinal])
    |> Enum.at(relative + 1)
  end

  defp to_string(relative, unit, options)
  when is_integer(relative) and unit in @unit_keys do
    direction = if relative > 1, do: :relative_future, else: :relative_past
    rules = options[:locale]
    |> Cldr.Locale.get_locale
    |> get_in([:date_fields, unit, options[:format], direction])

    rule = Cldr.Number.Ordinal.pluralize(relative, options[:locale], rules)

    relative
    |> abs
    |> Cldr.Number.to_string(locale: options[:locale])
    |> Cldr.Substitution.substitute(rule)
    |> Enum.join
  end

  defp to_string(%DateTime{} = relative, unit, options) do
    now = DateTime.utc_now |> DateTime.to_unix
    then = DateTime.to_unix(relative)
    seconds = then - now
    do_to_string(seconds, unit, options)
  end

  defp to_string(%Date{} = relative, unit, options) do
    today = Date.utc_today
    |> Date.to_erl
    |> :calendar.date_to_gregorian_days
    |> Kernel.*(@day)

    then = relative
    |> Date.to_erl
    |> :calendar.date_to_gregorian_days
    |> Kernel.*(@day)

    seconds = then - today
    do_to_string(seconds, unit, options)
  end

  defp to_string(span, unit, options) do
    do_to_string(span, unit, options)
  end

  defp do_to_string(seconds, nil, options) do
    unit = case abs(seconds) do
      i when i < @minute -> :second
      i when i < @hour -> :minute
      i when i < @day -> :hour
      i when i < @week -> :day
      i when i < @month -> :week
      i when i < @year -> :month
      _ -> :year
    end

    do_to_string(seconds, unit, options)
  end

  defp do_to_string(seconds, unit, options)
  when unit in @unit_keys do
    span = (seconds / @unit[unit]) |> abs |> Float.round |> trunc
    to_string(span, unit, options)
  end

  defp do_to_string(_, unit, _) do
    {:error, "Unknown time unit #{inspect unit}.  Valid time units are #{inspect @unit_keys}"}
  end
end