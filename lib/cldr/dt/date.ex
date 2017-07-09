defmodule Cldr.Date do

  @doc """
  Formats a date or datetime according to a format string
  as defined in CLDR and described in [TR35](http://unicode.org/reports/tr35/tr35-dates.html)

  * `date` is a `%Date{}` struct or any map that contains the keys
  `year`, `month`, `day` and `calendar`

  * `options` is a keyword list of options for formatting.
  """
  def to_string(date, options \\ [format: :short, locale: Cldr.get_locale()])
  def to_string(date, options) do
    format(date, options[:format], options[:locale], options)
  end

  def format(date, format, locale, options) do
    case Cldr.DateTime.Compiler.tokenize(format) do
      {:ok, parse, _} ->
        Enum.map(parse, fn {token, _line, count} ->
          apply(__MODULE__, token, [date, count])
        end)
        |> :erlang.iolist_to_binary
      {:error, reason} ->
        {:error, reason}
    end
  end

  def year_numeric(%{year: year}, 1) do
    Integer.to_string(year)
  end

  def year_numeric(%{year: year}, 2 = n) do
    year
    |> rem(100)
    |> pad(n)
  end

  def year_numeric(%{year: year}, n) do
    pad(year, n)
  end

  def month(%{month: month}, 1) do
    Integer.to_string(month)
  end

  def month(%{month: month}, 2) do
    pad(month, 2)
  end

  def month(%{month: momnth}, 3) do
    abbreviated
  end

  def month(%{month: momnth}, 4) do
    wide
  end

  def month(%{month: momnth}, 5) do
    narrow
  end

  def month_standalone(%{month: month}, 1) do
    Integer.to_string(month)
  end

  def month_standalone(%{month: month}, 2) do
    pad(month, 2)
  end

  def month_standalone(%{month: momnth}, 3) do
    abbreviated
  end

  def month_standalone(%{month: momnth}, 4) do
    wide
  end

  def month_standalone(%{month: momnth}, 5) do
    narrow
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