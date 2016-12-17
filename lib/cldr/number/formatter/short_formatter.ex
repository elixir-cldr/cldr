defmodule Cldr.Number.Formatter.Short do
  @moduledoc """
  Formats a number according to the locale-specific `:short` formats

  This is best explained by some
  examples:

      iex> Cldr.Number.to_string 123, format: :short
      "123"

      iex> Cldr.Number.to_string 1234, format: :short
      "1K"

      iex> Cldr.Number.to_string 523456789, format: :short
      "523M"

      iex> Cldr.Number.to_string 7234567890, format: :short
      "7B"

      iex> Cldr.Number.to_string 7234567890, format: :long
      "7 billion"

  These formats are compact representations however they do lose
  precision in the presentation in favour of human readibility.

  Note that for a `:currency` short format the number of decimal places
  is retrieved from the currency definition itself.  You can see the difference
  in the following examples:

      iex> Cldr.Number.to_string 1234, format: :short, currency: "EUR"
      "€1.23K"

      iex> Cldr.Number.to_string 1234, format: :short, currency: "JPY"
      "¥1K"
  """

  import Cldr.Macros, only: [docp: 1]
  alias Cldr.Math
  alias Cldr.Number.{System, Format, Formatter, Cardinal}

  docp """
  Notes from Unicode TR35 on formatting short formats:

  To format a number N, the greatest type less than or equal to N is
  used, with the appropriate plural category. N is divided by the type, after
  removing the number of zeros in the pattern, less 1. APIs supporting this
  format should provide control over the number of significant or fraction
  digits (note: this implementation does not currently support specifying
  fractional digits).

  If the value is precisely 0, or if the type is less than 1000, then the
  normal number format pattern for that sort of object is supplied. For
  example, formatting 1200 would result in “$1.2K”, while 990 would result in
  simply “$990”.

  Thus N=12345 matches <pattern type="10000" count="other">00 K</pattern> . N
  is divided by 1000 (obtained from 10000 after removing "00" and restoring one
  "0". The result is formatted according to the normal decimal pattern. With no
  fractional digits, that yields "12 K".
  """

  def to_string(number, style, options) do
    locale = options[:locale]

    number_system = options[:number_system]
    |> System.system_name_from(locale)

    number
    |> do_to_short_string(style, locale, number_system, options)
  end

  @spec do_to_short_string(number, atom, Locale.t, binary, Keyword.t) :: List.t
  defp do_to_short_string(number, style, locale, number_system, options) do
    formats = Format.formats_for(locale, number_system) |> Map.get(style)
    format  = choose_short_format(number, formats, options)
    number  = normalise_number(number, format)
    Formatter.Decimal.to_string(number, elem(format,1), options)
  end

  @doc false
  defp choose_short_format(number, _rules, options) when is_number(number) and number < 1000 do
    format = options[:locale]
    |> Format.formats_for(options[:number_system])
    |> Map.get(:standard)
    {number, format}
  end

  @doc false
  defp choose_short_format(number, rules, options) when is_number(number) do
    [range, rule] = rules
    |> Enum.filter(fn [range, _rules] -> range <= number end)
    |> Enum.reverse
    |> hd

    mod = number
    |> trunc
    |> rem(range)

    {range, Cardinal.pluralize(mod, options[:locale], rule)}
  end

  defp choose_short_format(%Decimal{} = number, rules, options) do
    number
    |> Decimal.round(0, :floor)
    |> Decimal.to_integer
    |> choose_short_format(rules, options)
  end

  @doc false
  @one_thousand Decimal.new(1000)
  defp normalise_number(%Decimal{} = number, {range, format}) do
    if Decimal.cmp(number, @one_thousand) == :lt do
      number
    else
      Decimal.div(number, Decimal.new(adjustment(range, format)))
    end
  end

  defp normalise_number(number, _format) when number < 1000 do
    number
  end

  defp normalise_number(number, {range, format}) do
    number / adjustment(range, format)
  end

  @doc false
  # TODO: We can precompute these at compile time which would
  # save this lookup
  defp adjustment(range, format) do
    count = format
    |> String.to_char_list
    |> number_of_zeros

    range / Math.power_of_10(count - 1)
  end

  defp number_of_zeros(list) do
    Enum.reduce(list, 0, fn c, acc -> if c == ?0, do: acc + 1, else: acc end)
  end
end
