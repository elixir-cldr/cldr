defmodule Cldr.Number.Formatter.Short do
  @moduledoc """
  Formats a number according to the locale-specific `:short` formats

  This is best explained by some
  examples:

      iex> Cldr.Number.to_string 123, format: :short
      {:ok, "123"}

      iex> Cldr.Number.to_string 1234, format: :short
      {:ok, "1K"}

      iex> Cldr.Number.to_string 523456789, format: :short
      {:ok, "523M"}

      iex> Cldr.Number.to_string 7234567890, format: :short
      {:ok, "7B"}

      iex> Cldr.Number.to_string 7234567890, format: :long
      {:ok, "7 billion"}

  These formats are compact representations however they do lose
  precision in the presentation in favour of human readibility.

  Note that for a `:currency` short format the number of decimal places
  is retrieved from the currency definition itself.  You can see the difference
  in the following examples:

      iex> Cldr.Number.to_string 1234, format: :short, currency: "EUR"
      {:ok, "€1K"}

      iex> Cldr.Number.to_string 1234, format: :short, currency: "EUR", fractional_digits: 2
      {:ok, "€1.23K"}

      iex> Cldr.Number.to_string 1234, format: :short, currency: "JPY"
      {:ok, "¥1K"}
  """

  import Cldr.Macros, only: [docp: 1]
  alias Cldr.Math
  alias Cldr.Locale
  alias Cldr.Number.{System, Format, Formatter, Cardinal}

  docp """
  Notes from Unicode TR35 on formatting short formats:

  To format a number N, the greatest type less than or equal to N is
  used, with the appropriate plural category. N is divided by the type, after
  removing the number of zeros in the pattern, less 1. APIs supporting this
  format should provide control over the number of significant or fraction
  digits.

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
    locale = (options[:locale] || Cldr.get_current_locale())

    with {:ok, _} <- Cldr.valid_locale?(locale),
         {:ok, number_system} <- System.system_name_from(options[:number_system], locale)
    do
      do_to_short_string(number, style, locale, number_system, options)
    else
      {:error, _} = error -> error
    end
  end

  @spec do_to_short_string(number, atom, Locale.name, atom, Map.t) :: List.t
  defp do_to_short_string(number, style, locale, number_system, options) do
    case Format.formats_for(locale, number_system) do
      {:ok, formats} ->
        formats = Map.get(formats, style)
        {number, format} = case choose_short_format(number, formats, options) do
          {range, [format, number_of_zeros]} ->
            {normalise_number(number, range, number_of_zeros), format}
          {_range, format} ->
            {number, format}
        end
        Formatter.Decimal.to_string(number, format, digits(options, options[:fractional_digits]))
      {:error, _} = error ->
        error
    end
  end

  # For short formats the fractional digits should be 0 unless otherwise specified,
  # even for currencies
  defp digits(options, nil) do
    Map.put(options, :fractional_digits, 0)
  end

  defp digits(options, _digits) do
    options
  end

  defp choose_short_format(number, _rules, options) when is_number(number) and number < 1000 do
    format = options[:locale]
    |> Format.formats_for!(options[:number_system])
    |> Map.get(standard_or_currency(options))

    {number, format}
  end

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

  defp standard_or_currency(options) do
    if options[:currency] do
      :currency
    else
      :standard
    end
  end

  @one_thousand Decimal.new(1000)
  defp normalise_number(%Decimal{} = number, range, number_of_zeros) do
    if Decimal.cmp(number, @one_thousand) == :lt do
      number
    else
      Decimal.div(number, Decimal.new(adjustment(range, number_of_zeros)))
    end
  end

  defp normalise_number(number, _range, _number_of_zeros) when number < 1000 do
    number
  end

  defp normalise_number(number, range, number_of_zeros) do
    number / adjustment(range, number_of_zeros)
  end

  @doc false
  # TODO: We can precompute these at compile time which would
  # save this lookup
  defp adjustment(range, number_of_zeros) do
    range / Math.power_of_10(number_of_zeros - 1)
  end

end
