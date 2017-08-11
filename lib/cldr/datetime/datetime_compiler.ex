defmodule Cldr.DateTime.Compiler do
  @moduledoc """
  Tokenizes and parses Date and DateTime format strings
  """

  alias Cldr.DateTime.Formatter

  @doc """
  Scan a number format definition

  Using a leex lexer, tokenize a rule definition

  ## Example

      iex> Cldr.DateTime.Compiler.tokenize "yyyy/MM/dd"
      {:ok,
       [{:year_numeric, 1, 4}, {:literal, 1, "/"}, {:month, 1, 2}, {:literal, 1, "/"},
        {:day_of_month, 1, 2}], 1}
  """
  def tokenize(definition) when is_binary(definition) do
    definition
    |> String.to_charlist
    |> :datetime_format_lexer.string()
  end

  def tokenize(%{number_system: _numbers, format: value}) do
    tokenize(value)
  end

  @doc """
  Parse a number format definition

  Using a yecc lexer, parse a datetime format definition into list of
  elements we can then interpret to format a date or datetime.
  """
  def compile("") do
    {:error, "empty format string cannot be compiled"}
  end

  def compile(nil) do
    {:error, "no format string or token list provided"}
  end

  def compile(definition) when is_binary(definition) do
    {:ok, tokens, _end_line} = tokenize(definition)

    transforms = Enum.map(tokens, fn {fun, _line, count} ->
      quote do
        Formatter.unquote(fun)(var!(date), unquote(count), var!(locale), var!(options))
      end
    end)

    {:ok, transforms}
  end

  def compile(%{number_system: _number_system, format: value}) do
    compile(value)
  end

  def compile(arg) do
    raise ArgumentError, message: "No idea how to compile format: #{inspect arg}"
  end

  def convert_eras_to_iso_days(calendar_data) do
    Enum.map(calendar_data, fn {calendar, content} ->
      {calendar, adjust_eras(content)}
    end)
    |> Enum.into(%{})
  end

  defp adjust_eras(%{"eras" => eras} = content) do
    eras =
      eras
      |> Enum.map(fn {era, dates} -> {era, adjust_era(dates)} end)
      |> Enum.into(%{})

    Map.put(content, "eras", eras)
  end

  defp adjust_eras(%{} = content) do
    content
  end

  defp adjust_era(dates) do
    Enum.map(dates, fn
      {"start", date} -> {"start", to_iso_days(date)}
      {"end", date} -> {"end", to_iso_days(date)}
      {k, v} -> {k, v}
    end)
    |> Enum.into(%{})
  end

  def parse_time_periods(period_data) do
    Enum.map(period_data, fn {language, periods} ->
      {language, adjust_periods(periods)}
    end)
    |> Enum.into(%{})
  end

  defp adjust_periods(periods) do
    Enum.map(periods, fn {period, times} ->
      {period, adjust_times(times)}
    end)
    |> Enum.into(%{})
  end

  defp adjust_times(times) do
    Enum.map(times, fn {key, time} ->
      {key, Enum.map(String.split(time, ":"), &String.to_integer/1)}
    end)
    |> Enum.into(%{})
  end

  def to_iso_days(%{year: year, month: month, day: day}) do
    gregorian_date_to_iso_days(year, month, day)
  end

  def to_iso_days(date) when is_binary(date) do
    {year, month, day} = case String.split(date, "-") do
      [year, month, day] ->
        {String.to_integer(year), String.to_integer(month), String.to_integer(day)}
      ["", year, month, day] ->
        {String.to_integer("-#{year}"), String.to_integer(month), String.to_integer(day)}
    end

    gregorian_date_to_iso_days(year, month, day)
  end

  @doc """
  Converts a `year`, `month` and `day` into a number of days
  for the gregorian calendar

  This should be done in the Calendar.ISO module but today that
  module doesnt handle negative years which are needed here.
  """
  def gregorian_date_to_iso_days(year, month, day) do
    correction =
      cond do
        month <= 2 -> 0
        leap_year?(year) -> -1
        true ->  -2
      end

    (gregorian_epoch_days() - 1) +
    (365 * (year - 1)) +
    Float.floor((year - 1) / 4) -
    Float.floor((year - 1) / 100) +
    Float.floor((year - 1) / 400) +
    Float.floor((367 * month - 362) / 12) +
    correction + day |> trunc
  end

  @doc """
  Returns true if the given year is a leap year.
  """
  def leap_year?(year) when is_integer(year) do
    mod(year, 4) === 0 and (mod(year, 100) > 0 or mod(year, 400) === 0)
  end

  defp gregorian_epoch_days do
    1
  end

  def mod(x, y) when is_integer(x) and is_integer(y) do
    mod(x * 1.0, y) |> round
  end

  def mod(x, y) do
    x - (y * Float.floor(x / y))
  end
end
