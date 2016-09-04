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

  import Cldr.Macros
  import Cldr.Number.String
  import Cldr.Number.Format, only: [formats_for: 2]
  import Cldr.Number.Transliterate, only: [transliterate: 3]
  import Cldr.Number.Symbol, only: [number_symbols_for: 2,
                                    minimum_grouping_digits_for: 1]

  alias Cldr.Currency
  alias Cldr.Number
  alias Cldr.Number.Math
  alias Cldr.Number.Format.Compiler

  # Compiles known decimal formats and creates functions to process them
  use Number.Generate.DecimalFormats

  # Creates functions to process short formats
  use Number.Generate.ShortFormats

  @type format_type ::
    :standard |
    :decimal_short |
    :decimal_long |
    :currencu_short |
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

      iex> Cldr.Number.to_string 12345, format: :accounting, currency: "THB", locale: "th"
      "THB12,345.00"

      iex> Cldr.Number.to_string 12345, format: :accounting, currency: "THB", locale: "th", number_system: :native
      "THB๑๒,๓๔๕.๐๐"

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
       `number_system`.  This happens typically when the number system is
       :algorithmic rather than the more common :numeric.  In this case the
       error return looks like:

       iex> Number.to_string(1234, locale: "he", number_system: "hebr")
       {:error,
        "The locale \"he\" with number system \"hebr\" does not define a format :standard.  This usually happens when the number system is :algorithmic rather than :numeric.  Either change options[:number_system] or define a format string like format: \"#,##0.00\""}

  ## Exceptions

  An exception `Cldr.UnknownLocaleError` will be raised if the specific locale
  is not known to `Cldr`.


  """
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

  defp to_string(_number, nil, options) do
    {:error,
      "The locale #{inspect options[:locale]} with number system " <>
      "#{inspect options[:number_system]} does not define a format " <>
      "#{inspect options[:format]}."
    }
  end

  # For formats not precompiled we need to compile first
  # and then process
  defp to_string(number, format, options) do
    case Compiler.decode(format) do
    {:ok, meta} ->
      do_to_string(number, meta, options)
    {:error, message} ->
      {:error, message}
    end
  end

  # Now we have the number to be formatted, the meta data that
  # defines the formatting and the options to be applied
  # (which is related to localisation of the final format)
  defp do_to_string(number, meta, options) do
    meta = meta
    |> adjust_fraction_for_currency(options[:currency], options[:cash])
    |> adjust_fraction_for_significant_digits(number, meta[:significant_digits])

    number
    |> to_decimal
    |> multiply_by_factor(meta[:multiplier])
    |> round_to_significant_digits(meta[:significant_digits])
    |> round_to_nearest(meta[:rounding], options[:rounding_mode])
    |> adjust_for_exponent(meta, meta[:exponent_digits])
    |> output_to_string(meta[:fractional_digits], options[:rounding_mode])
    |> adjust_leading_zeros(:integer, meta[:integer_digits])
    |> adjust_trailing_zeros(:fraction, meta[:fractional_digits])
    |> set_max_integer_digits(meta[:integer_digits].max)
    |> apply_grouping(meta[:grouping], options[:locale])
    |> reassemble_number_string
    |> transliterate(options[:locale], options[:number_system])
    |> assemble_format(number, meta, options)
  end

  # When formatting a currency we need to adjust the number of fractional
  # digits to match the currency definition.  We also need to adjust the
  # rounding increment to match the currency definition.
  defp adjust_fraction_for_currency(meta, nil, _cash) do
    meta
  end

  defp adjust_fraction_for_currency(meta, currency, cash) when is_false(cash) do
    currency = Currency.for_code(currency)
    do_adjust_fraction(meta, currency.digits, currency.rounding)
  end

  defp adjust_fraction_for_currency(meta, currency, _cash) do
    currency = Currency.for_code(currency)
    do_adjust_fraction(meta, currency.cash_digits, currency.cash_rounding)
  end

  defp do_adjust_fraction(meta, digits, rounding) do
    rounding = Decimal.new(:math.pow(10, -digits) * rounding)
    %{meta | fractional_digits: %{max: digits, min: digits},
             rounding: rounding}
  end

  # If we round to sigificant digits then the format won't (usually)
  # have any fractional part specified and if we don't do something
  # then we're truncating the number - not really what is intended
  # for significant digits display.

  # For no significant digits
  defp adjust_fraction_for_significant_digits(meta, _number,
      %{max: 0, min: 0}) do
    meta
  end

  # No fractional digits for an integer
  defp adjust_fraction_for_significant_digits(meta, number,
      %{max: _max, min: _min}) when is_integer(number) do
    meta
  end

  # Decimal version of an integer => exponent > 0
  defp adjust_fraction_for_significant_digits(meta, %Decimal{exp: exp},
      %{max: _max, min: _min}) when exp >= 0 do
    meta
  end

  # For all float or Decimal fraction
  defp adjust_fraction_for_significant_digits(meta, _number,
      %{max: _max, min: _min}) do
    %{meta | fractional_digits: %{max: 10, min: 1}}
  end

  # Convert the number to a decimal since it preserves precision
  # better when we round.  Then use the absolute value since
  # the sign only determines which pattern we use (positive
  # or negative)
  defp to_decimal(number = %Decimal{}) do
    number
    |> Decimal.abs()
  end

  defp to_decimal(number) do
    number
    |> Decimal.new
    |> Decimal.abs()
  end

  # If the format includes a % (percent) or permille then we
  # adjust the number by a factor.  All other formats the factor
  # is 1 and hence we avoid the multiplication.
  defp multiply_by_factor(number, %Decimal{coef: 1} = _factor) do
    number
  end

  defp multiply_by_factor(number, factor) do
    Decimal.mult(number, factor)
  end

  # Round to significant digits.  This is different to rounding
  # to decimal places and is a more expensive mathematical
  # calculation.  Although the specification allows for minimum
  # and maximum, I haven't found an example of where minimum is a
  # useful rounding value since maximum already removes trailing
  # insignificant zeros.
  #
  # Also note that this implementation allows for both significatn
  # digit rounding as we as decimal precision rounding.  Its likely
  # not a good idea to combine the two in a format mask and results
  # are unspecified if you do.
  defp round_to_significant_digits(number, %{min: 0, max: 0}) do
    number
  end

  defp round_to_significant_digits(number, %{min: _min, max: max}) do
    Math.round_significant(number, max)
  end

  # A format can include a rounding specification which we apply
  # here except if there is no rounding specified.
  defp round_to_nearest(number, %Decimal{coef: 0}, _rounding_mode) do
    number
  end

  defp round_to_nearest(number, rounding, rounding_mode) do
    number
    |> Decimal.div(rounding)
    |> Decimal.round(0, rounding_mode)
    |> Decimal.mult(rounding)
  end

  # For a scientific format we need to adjust to a
  # mantissa * 10^exponent format.
  defp adjust_for_exponent(number, _meta, exponent_digits)
  when exponent_digits == 0 do
    number
  end

  defp adjust_for_exponent(number, meta, exponent_digits) do
    {mantissa, exponent} = Math.mantissa_exponent(number)

    # Take care of minimum exponent digits
    exponent_adjustment = exponent_digits - Math.number_of_integer_digits(exponent)
    {mantissa, exponent} = adjust_exponent(mantissa, exponent, exponent_adjustment)

    # Now take care of exponent digit multiples
    # first grouping size is what defines that
    grouping = meta.grouping.integer.first
    {mantissa, exponent} = adjust_exponent_mod(mantissa, exponent, grouping)

    # Lastly we do significant digit rounding on the mantissa
    mantissa = if meta.scientific_rounding > 0 do
      Math.round_significant(mantissa, meta.scientific_rounding)
    else
      mantissa
    end

    {mantissa, exponent}
  end

  # Adjust the number of digits in the exponent to match the minimum
  # number of exponent digits
  defp adjust_exponent(mantissa, exponent, _adjustment) do
    {mantissa, exponent}
  end

  defp adjust_exponent_mod(mantissa, exponent, grouping) when grouping == 0 do
    {mantissa, exponent}
  end

  defp adjust_exponent_mod(mantissa, exponent, _grouping) do
    {mantissa, exponent}
  end

  # defp adjust_exponent_mod(mantissa, exponent, grouping) when exponent < grouping do
  #   IO.puts "Less than #{inspect exponent}; #{inspect grouping}"
  #   adjustment = exponent - grouping
  #   exponent = exponent - adjustment
  #   mantissa = %{mantissa | exp: mantissa.exp + adjustment}
  #   {mantissa, exponent}
  # end
  #
  # defp adjust_exponent_mod(mantissa, exponent, grouping) do
  #   IO.puts "Default"
  #   adjustment = Math.mod(exponent, grouping) |> trunc
  #   exponent = exponent - adjustment
  #   mantissa = %{mantissa | exp: mantissa.exp + adjustment}
  #   {mantissa, exponent}
  # end


  # Output the number to a string - all the other transformations
  # are done on the string version split into its constituent
  # parts
  defp output_to_string({mantissa, exponent}, _fraction_digits, _rounding_mode) do
    mantissa_string = mantissa
    |> Decimal.to_string(:normal)

    Compiler.number_match_regex()
    |> Regex.named_captures(mantissa_string)
    |> Map.put("exponent", Integer.to_string(exponent))
  end

  defp output_to_string(number, fraction_digits, rounding_mode) do
    string = number
    |> Decimal.round(fraction_digits[:max], rounding_mode)
    |> Decimal.to_string(:normal)

    Regex.named_captures(Compiler.number_match_regex(), string)
    |> Map.put("exponent", @empty_string)
  end

  # Remove all the trailing zeros from a fraction and add back what
  # is required for the format
  defp adjust_trailing_zeros(number, :fraction, fraction_digits) do
    fraction = String.trim_trailing(number["fraction"], "0")
    %{number | "fraction" => pad_trailing_zeros(fraction, fraction_digits[:min])}
  end

  defp adjust_trailing_zeros(number, _fraction, _fraction_digits) do
    number
  end

  # Remove all the leading zeros from an integer and add back what
  # is required for the format
  defp adjust_leading_zeros(number, :integer, integer_digits) do
    integer = String.trim_leading(number["integer"], "0")
    %{number | "integer" => pad_leading_zeros(integer, integer_digits[:min])}
  end

  defp adjust_leading_zeros(number, _integer, _integer_digits) do
    number
  end

  # Take the rightmost maximum digits only - this is a truncation from the
  # right.
  def set_max_integer_digits(number, maximum_digits) when maximum_digits == 0 do
    number
  end

  def set_max_integer_digits(%{"integer" => integer} = number, maximum_digits) do
    if (length = String.length(integer)) <= maximum_digits do
      number
    else
      offset = length - maximum_digits
      string = String.slice(integer, offset, maximum_digits)
      %{number | "integer" => string}
    end
  end

  # Insert the grouping placeholder in the right place in the number.
  # There may be one or two different groupings for the integer part
  # and one grouping for the fraction part.
  defp apply_grouping(%{"integer" => integer, "fraction" => fraction} = string, groups, locale) do
    integer = do_grouping(integer, groups[:integer],
                String.length(integer),
                minimum_group_size(groups[:integer], locale),
                :reverse)

    fraction = do_grouping(fraction, groups[:fraction],
                 String.length(fraction),
                 minimum_group_size(groups[:fraction], locale))

    %{string | "integer" => integer, "fraction" => fraction}
  end

  defp minimum_group_size(%{first: group_size}, locale) do
    minimum_grouping_digits_for(locale) + group_size
  end

  # The actual grouping function.  Note there are two directions,
  # `:forward` and `:reverse`.  Thats because we group from the decimal
  # placeholder outwards and there may be a final group that is less than
  # the grouping size.  For the fraction part the dangling part is at the
  # end (:forward direction) whereas for the integer part the dangling
  # group is at the beginning (:reverse direction)
  defp do_grouping(string, groups, string_length, min_grouping, direction \\ :forward)

  # No grouping if the string length (number of digits) is less than the
  # minimum grouping size.
  defp do_grouping(string, _, string_length, min_grouping, _)
  when string_length < min_grouping do
    string
  end

  # The case when there is only one grouping. Always true for fraction part.
  @group_separator Compiler.placeholder(:group)
  defp do_grouping(string, %{first: first, rest: rest}, _, _, direction)
  when first == rest do
    string
    |> chunk_string(first, direction)
    |> Enum.join(@group_separator)
  end

  # The case when there are two different groupings. This applies only to
  # The integer part, it can never be true for the fraction part.
  defp do_grouping(string, %{first: first, rest: rest}, string_length, _, :reverse = direction) do
    {rest_of_string, first_group} = String.split_at(string, string_length - first)
    other_groups = chunk_string(rest_of_string, rest, direction)
    Enum.join(other_groups ++ [first_group], @group_separator)
  end

  @decimal_separator  Compiler.placeholder(:decimal)
  @exponent_separator Compiler.placeholder(:exponent)
  defp reassemble_number_string(%{} = number) do
    number["integer"]
    |> append(number["fraction"], @decimal_separator)
    |> append(number["exponent"], @exponent_separator)
  end

  # Conditionally add a separator and number component to the output string
  # if it exists
  defp append(string, @empty_string, _separator) do
    string
  end

  defp append(string, part, separator) do
    string <> separator <> part
  end

  # Now we can assemble the final format.  Based upon
  # whether the number is positive or negative (as indicated
  # by options[:sign]) we assemble the parts and transliterate
  # the currency sign, percent and permille characters.
  defp assemble_format(number_string, number, meta, options) do
    format = meta.format[options[:pattern]]
    format_length = length(format)
    do_assemble_format(number_string, number, meta, format, options, format_length)
  end

  # If the format length is 1 (one) then it can only be the number format
  # and therefore we don't have to do the reduction.
  defp do_assemble_format(number_string, _number, _meta, _format, _options, 1) do
    number_string
  end

  @lint false
  defp do_assemble_format(number_string, number, meta, format, options, _length) do
    system = options[:number_system]
    locale = options[:locale]
    symbols = number_symbols_for(locale, system)

    Enum.reduce format, @empty_string, fn (token, string) ->
      string <> case token do
        {:format, _format}   -> number_string
        {:pad, _}            -> padding_string(meta, number_string)
        {:plus, _}           -> symbols.plus_sign
        {:minus, _}          -> symbols.minus_sign
        {:currency, type}    ->
          currency_symbol(options[:currency], number, type, locale)
        {:percent, _}        -> symbols.percent_sign
        {:permille, _}       -> symbols.permille
        {:literal, literal}  -> literal
        {:quote, _char}      -> "'"
        {:quoted_char, char} -> char
      end
    end
  end

  # Calculate the padding by subtracting the length of the number
  # string from the padding length.
  defp padding_string(%{padding_length: 0}, _number_string) do
    @empty_string
  end

  defp padding_string(meta, number_string) do
    pad_length = meta[:padding_length] - String.length(number_string)
    if pad_length > 0 do
      String.duplicate(meta[:padding_char], pad_length)
    else
      @empty_string
    end
  end

  # Extract the appropriate currency symbol based upon how many currency
  # placeholders are in the format as follows:
  #   ¤      Standard currency symbol
  #   ¤¤     ISO currency symbol (constant)
  #   ¤¤¤    Appropriate currency display name for the currency, based on the
  #          plural rules in effect for the locale
  #   ¤¤¤¤   Narrow currency symbol.
  defp currency_symbol(%Currency{} = currency, _number, 1, _locale) do
    currency.symbol
  end

  defp currency_symbol(%Currency{} = currency, _number, 2, _locale) do
    currency.code
  end

  defp currency_symbol(%Currency{} = currency, number, 3, locale) do
    selector = Number.Cardinal.plural_rule(number, locale)
    currency.count[selector] || currency.count[:other]
  end

  defp currency_symbol(%Currency{} = currency, _number, 4, _locale) do
    currency.narrow_symbol || currency.symbol
  end

  defp currency_symbol(currency, number, size, locale) do
    currency = Currency.for_code(currency, locale)
    currency_symbol(currency, number, size, locale)
  end

  # Merge options and default options with supplied options always
  # the winner.  If :currency is specified then the default :format
  # will be format: currency
  @short_format_styles Number.Format.short_format_styles()
  defp normalize_options(options, defaults) do
    options = if options[:currency] && !options[:format] do
      options ++ [{:format, :currency}]
    else
      options
    end

    options = if options[:format] == :short && options[:currency] do
      options = Keyword.delete(options, :format) |> Keyword.put(:format, :currency_short)
    else
      options
    end

    options = if options[:format] == :short && !options[:currency] do
      options = Keyword.delete(options, :format) |> Keyword.put(:format, :decimal_short)
    else
      options
    end

    options = if options[:format] == :long && !options[:currency] do
      options = Keyword.delete(options, :format) |> Keyword.put(:format, :decimal_long)
    else
      options
    end

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
