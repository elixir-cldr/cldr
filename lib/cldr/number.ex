defmodule Cldr.Number do
  @moduledoc """
  Cldr formatting for numbers.

  Provides the public API for the formatting of numbers based upon
  CLDR's decimal formats specification documentated [Unicode TR35](http://unicode.org/reports/tr35/tr35-numbers.html#Number_Formats)

  ### Non-Scientific Notation Formatting

  The following description applies to formats that do not use scientific
  notation or significant digits:

  * If the number of actual integer digits exceeds the maximum integer digits,
    then only the least significant digits are shown. For example, 1997 is
    formatted as "97" if the maximum integer digits is set to 2.

  * If the number of actual integer digits is less than the minimum integer
    digits, then leading zeros are added. For example, 1997 is formatted as
    "01997" if the minimum integer digits is set to 5.

  * If the number of actual fraction digits exceeds the maximum fraction
    digits, then half-even rounding it performed to the maximum fraction
    digits. For example, 0.125 is formatted as "0.12" if the maximum fraction
    digits is 2. This behavior can be changed by specifying a rounding
    increment and a rounding mode.

  * If the number of actual fraction digits is less than the minimum fraction
    digits, then trailing zeros are added. For example, 0.125 is formatted as
    "0.1250" if the minimum fraction digits is set to 4.

  * Trailing fractional zeros are not displayed if they occur j positions after
    the decimal, where j is less than the maximum fraction digits. For example,
    0.10004 is formatted as "0.1" if the maximum fraction digits is four or
    less.

  ### Scientific Notation Formatting

  Numbers in scientific notation are expressed as the product of a mantissa and
  a power of ten, for example, 1234 can be expressed as 1.234 x 10^3. The
  mantissa is typically in the half-open interval [1.0, 10.0) or sometimes
  [0.0, 1.0), but it need not be. In a pattern, the exponent character
  immediately followed by one or more digit characters indicates scientific
  notation. Example: "0.###E0" formats the number 1234 as "1.234E3".

  * The number of digit characters after the exponent character gives the
    minimum exponent digit count. There is no maximum. Negative exponents are
    formatted using the localized minus sign, not the prefix and suffix from
    the pattern. This allows patterns such as "0.###E0 m/s". To prefix positive
    exponents with a localized plus sign, specify '+' between the exponent and
    the digits: "0.###E+0" will produce formats "1E+1", "1E+0", "1E-1", and so
    on. (In localized patterns, use the localized plus sign rather than '+'.)

  * The minimum number of integer digits is achieved by adjusting the exponent.
    Example: 0.00123 formatted with "00.###E0" yields "12.3E-4". This only
    happens if there is no maximum number of integer digits. If there is a
    maximum, then the minimum number of integer digits is fixed at one.

  * The maximum number of integer digits, if present, specifies the exponent
    grouping. The most common use of this is to generate engineering notation,
    in which the exponent is a multiple of three, for example, "##0.###E0". The
    number 12345 is formatted using "##0.####E0" as "12.345E3".

  * When using scientific notation, the formatter controls the digit counts
    using significant digits logic. The maximum number of significant digits
    limits the total number of integer and fraction digits that will be shown
    in the mantissa; it does not affect parsing. For example, 12345 formatted
    with "##0.##E0" is "12.3E3". Exponential patterns may not contain grouping
    separators.

  ### Significant Digits

  There are two ways of controlling how many digits are shows: (a)
  significant digits counts, or (b) integer and fraction digit counts. Integer
  and fraction digit counts are described above. When a formatter is using
  significant digits counts, it uses however many integer and fraction digits
  are required to display the specified number of significant digits. It may
  ignore min/max integer/fraction digits, or it may use them to the extent
  possible.
  """

  alias Cldr.Number.Formatter
  alias Cldr.Number.Format.Compiler
  import Cldr.Number.Format, only: [formats_for: 2]

  @type format_type ::
    :standard |
    :decimal_short |
    :decimal_long |
    :currency_short |
    :currency_long |
    :percent |
    :accounting |
    :scientific |
    :currency

  @empty_string ""

  @default_options [
    format:        :standard,
    currency:      nil,
    cash:          false,
    rounding_mode: :half_even,
    number_system: :default,
    locale:        Cldr.get_locale()
  ]

  @doc """
  Returns a number formatted according to a pattern and options.

  * `number` is an integer, float or Decimal to be formatted

  * `options` is a keyword list defining how the number is to be formatted. The
    valid options are:

    * `format`: the format style or a format string defining how the number is
      formatted. See `Cldr.Number.Format` for how formats can be constructed.
      See `Cldr.Number.Format.format_styles_for/1` to see what format styles
      are available for a locale. The default `format` is `:standard`.

    * If `:format` is set to `:long` or `:short` then the formatting depends on
      whether `:currency` is specified. If not specified then the number is
      formatted as `:decimal_long` or `:decimal_short. If `:currency` is
      specified the number is formatted at `:currency_long` or
      `:currency_short`.

    * `currency`: is the currency for which the number is formatted. For
      available currencies see Cldr.Currency.known_currencies/0`. This option
      is required if `format` is set to `:currency`.  If `currency` is set
      and no `format` is set, `format` will be set to `:currency` as well.

    * `cash`: a boolean which indicates whether a number being formatted as a
      `:currency` is to be considered a cash value or not. Currencies can be
      rounded differently depending on whether `cash` is `true` or `false`.

    * `rounding_mode`: determines how a number is rounded to meet the precision
      of the format requested. The available rounding modes are `:down`,
      :half_up, :half_even, :ceiling, :floor, :half_down, :up. The default is
      `:half_even`.

    * `number_system`: determines which of the number systems for a locale
      should be used to define the separators and digits for the formatted
      number. If `number_system` is an `atom` then `number_system` is
      interpreted as a number system. See
      Cldr.Number.System.number_systems_for/1`. If the `number_system` is
      `binary` then it is interpreted as a number system name. See
      `Cldr.Number.System.number_system_names_for/1`. The default is `:default`.

    * `locale`: determines the locale in which the number is formatted. See
      `Cldr.known_locales/0`. THe default is `Cldr.get_locale()` which is the
      locale currently in affect for this `Process` and which is set by
      `Cldr.put_locale/1`.

  ## Examples

      iex> Cldr.Number.to_string 12345
      "12,345"

      iex> Cldr.Number.to_string 12345, locale: "fr"
      "12 345"

      iex> Cldr.Number.to_string 12345, locale: "fr", currency: "USD"
      "12 345,00 $US"

      iex(4)> Cldr.Number.to_string 12345, format: "#E0"
      "1.2345E4"

      iex> Cldr.Number.to_string 12345, format: :accounting, currency: "THB"
      "THB12,345.00"

      iex> Cldr.Number.to_string -12345, format: :accounting, currency: "THB"
      "(THB12,345.00)"

      iex> Cldr.Number.to_string 12345, format: :accounting, currency: "THB", locale: "th"
      "THB12,345.00"

      iex> Cldr.Number.to_string 12345, format: :accounting, currency: "THB", locale: "th", number_system: :native
      "THB๑๒,๓๔๕.๐๐"

      iex> Number.to_string 1244.30, format: :long
      "1 thousand"

      iex> Number.to_string 1244.30, format: :long, currency: "USD"
      "1,244.30 US dollars"

      iex> Number.to_string 1244.30, format: :short
      "1K"

      iex> Number.to_string 1244.30, format: :short, currency: "EUR"
      "€1.24K"

  ## Errors

  An error tuple `{:error, "message"}` will be returned if an error is detected.
  The two most likely causes of an error return are:

    * A format cannot be compiled. In this case the error tuple will look like:

      iex> Cldr.Number.to_string(12345, format: "0#")
      {:error, "Decimal format compiler: syntax error before: \"#\""}

    * A currency was not specific for a format type of `format: :currency` or
      `format: :accounting` or any other format that specifies a currency
      symbol placeholder. In this case the error return looks like:

      iex> Cldr.Number.to_string(12345, format: :accounting)
      {:error,
       "currency format \"¤#,##0.00;(¤#,##0.00)\" requires that options[:currency] be specified"}

    * The format style requested is not defined for the `locale` and
      `number_system`. This happens typically when the number system is
      :algorithmic rather than the more common :numeric. In this case the error
      return looks like:

      iex> Number.to_string(1234, locale: "he", number_system: "hebr")
      {:error,
       "The locale \"he\" with number system \"hebr\" does not define a format :standard.  This usually happens when the number system is :algorithmic rather than :numeric.  Either change options[:number_system] or define a format string like format: \"#,##0.00\""}

  ## Exceptions

  An exception `Cldr.UnknownLocaleError` will be raised if the specific locale
  is not known to `Cldr`.
  """

  # `to_string/2` is the public API to number formatting.  Its basic job is
  # to retrieve the actually format mask to be used and then invoke
  # `to_string/3` on the appropriate module which is the internal API.

  @spec to_string(number, [Keyword.t]) :: String.t
  def to_string(number, options \\ @default_options) do
    {format, options} = options
    |> normalize_options(@default_options)
    |> detect_negative_number(number)

    if currency_format?(format) && !Keyword.get(options, :currency) do
      {:error, "currency format #{inspect format} requires that " <>
        "options[:currency] be specified"}
    else
      to_string(number, format, options)
    end
  end

  # For the :currency_long format only
  defp to_string(number, :currency_long = format, options) do
    Formatter.Currency.to_string(number, format, options)
  end

  # For when there is no format found!
  defp to_string(_number, nil, options) do
    {:error,
      "The locale #{inspect options[:locale]} with number system " <>
      "#{inspect options[:number_system]} does not define a format " <>
      "#{inspect options[:format]}."
    }
  end

  # For all opther short formats
  defp to_string(number, format, options) when is_atom(format) do
    Formatter.Short.to_string(number, format, options)
  end

  # For all other formats
  defp to_string(number, format, options) do
    Formatter.Decimal.to_string(number, format, options)
  end

  # Merge options and default options with supplied options always
  # the winner.  If :currency is specified then the default :format
  # will be format: currency
  @short_format_styles Cldr.Number.Format.short_format_styles()
  defp normalize_options(options, defaults) do
    options = if options[:currency] && !options[:format] do
      options ++ [{:format, :currency}]
    else
      options
    end

    options = check_options(:short, options[:currency],  :currency_short, options)
    options = check_options(:long,  options[:currency],  :currency_long, options)
    options = check_options(:short, !options[:currency], :decimal_short, options)
    options = check_options(:long,  !options[:currency], :decimal_long, options)

    options = Keyword.merge defaults, options, fn _k, _v1, v2 -> v2 end

    case format = options[:format] do
     format when is_binary(format) ->
       {format, options}
     format when is_atom(format) and format in @short_format_styles ->
       {format, options}
     _ ->
       format = options[:locale]
       |> formats_for(options[:number_system])
       |> Map.get(options[:format])
       {format, options}
    end
  end

  # if the format is :short or :long then we set the full format name
  # based upon whether there is a :currency set in options or not.
  defp check_options(format, check, finally, options) do
    if options[:format] == format && check do
      options = Keyword.delete(options, :format)
      |> Keyword.put(:format, finally)
    else
      options
    end
  end

  defp detect_negative_number({format, options}, number)
  when (is_float(number) or is_integer(number)) and number < 0 do
    {format, Keyword.put(options, :pattern, :negative)}
  end

  defp detect_negative_number({format, options}, %Decimal{sign: sign})
  when sign < 0 do
    {format, Keyword.put(options, :pattern, :negative)}
  end

  defp detect_negative_number({format, options}, _number) do
    {format, Keyword.put(options, :pattern, :positive)}
  end

  defp currency_format?(format) when is_atom(format) do
    format == :currency_short
  end

  defp currency_format?(format) when is_binary(format) do
    format && String.contains?(format, Compiler.placeholder(:currency))
  end
end
