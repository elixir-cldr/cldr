defmodule Cldr.Number do
  @moduledoc """
  ## Cldr formatting for numbers.
  
  Provides the public API for the formatting of numbers based upon
  CLDR's decimal formats specification documentated [Unicode TR35]
  (http://unicode.org/reports/tr35/tr35-numbers.html#Number_Formats)
  
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
  digits, then half-even rounding it performed to the maximum fraction digits.
  For example, 0.125 is formatted as "0.12" if the maximum fraction digits is
  2. This behavior can be changed by specifying a rounding increment and a
  rounding mode.

  * If the number of actual fraction digits is less than the minimum fraction
  digits, then trailing zeros are added. For example, 0.125 is formatted as
  "0.1250" if the minimum fraction digits is set to 4.

  * Trailing fractional zeros are not displayed if they occur j positions
  after the decimal, where j is less than the maximum fraction digits. For
  example, 0.10004 is formatted as "0.1" if the maximum fraction digits is 
  four or less.
 
  ### Scientific Notation Formatting
  
  Numbers in scientific notation are expressed as the product of a mantissa and
  a power of ten, for example, 1234 can be expressed as 1.234 x 103. The
  mantissa is typically in the half-open interval [1.0, 10.0) or sometimes
  [0.0, 1.0), but it need not be. In a pattern, the exponent character
  immediately followed by one or more digit characters indicates scientific
  notation. Example: "0.###E0" formats the number 1234 as "1.234E3".
  
  * The number of digit characters after the exponent character gives the
  minimum exponent digit count. There is no maximum. Negative exponents are
  formatted using the localized minus sign, not the prefix and suffix from the
  pattern. This allows patterns such as "0.###E0 m/s". To prefix positive
  exponents with a localized plus sign, specify '+' between the exponent and
  the digits: "0.###E+0" will produce formats "1E+1", "1E+0", "1E-1", and so
  on. (In localized patterns, use the localized plus sign rather than '+'.)

  * The minimum number of integer digits is achieved by adjusting the
  exponent. Example: 0.00123 formatted with "00.###E0" yields "12.3E-4". This
  only happens if there is no maximum number of integer digits. If there is a
  maximum, then the minimum number of integer digits is fixed at one.

  * The maximum number of integer digits, if present, specifies the exponent
  grouping. The most common use of this is to generate engineering notation,
  in which the exponent is a multiple of three, for example, "##0.###E0". The
  number 12345 is formatted using "##0.####E0" as "12.345E3".

  * When using scientific notation, the formatter controls the digit counts
  using significant digits logic. The maximum number of significant digits
  limits the total number of integer and fraction digits that will be shown in
  the mantissa; it does not affect parsing. For example, 12345 formatted with
  "##0.##E0" is "12.3E3". Exponential patterns may not contain grouping
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
  import Cldr.Number.String
  import Cldr.Number.Format, only: [format_from: 2]
  alias Cldr.Number.Format.Compiler
  
  @type format_type :: :standard | :short | :long | :percent 
                      | :accounting | :scientific

  @default_options [as:            :standard,
                    locale:        Cldr.default_locale(),
                    number_system: :default, 
                    currency:      nil, 
                    rounding_mode: :half_even, 
                    precision:     Cldr.Number.Math.default_rounding()]
  
  @spec to_string(number, [Keyword.t]) :: String.t
  def to_string(number, options) do
    options = normalize_options(options, @default_options)
    if options[:format] do
      options = options |> Keyword.delete(:as)
      format = options[:format]
      to_string(number, format, options)
    else
      options = options |> Keyword.delete(:format)
      format = format_from(options[:locale], options[:number_system]) 
        |> Map.get(options[:as])
      to_string(number, format, options)
    end
  end
  
  # Compile the known decimal formats extracted from the 
  # current configuration of Cldr.  This avoids having to tokenize
  # parse and analyse the format on each invokation.  There
  # are around 74 Cldr defined decimal formats so this isn't
  # to burdensome on the compiler of the BEAM.
  #
  # TODO:  Is it worth precompiling even further using "en"
  # locale?
  Enum.each Cldr.Number.Format.decimal_format_list(), fn format ->
    meta = Compiler.decode(format)
    defp to_string(number, unquote(format), options) do
      do_to_string(number, unquote(Macro.escape(meta)), options)
    end
  end
  
  # For formats not predefined we need to compile first
  # and then process
  defp to_string(number, format, options) do
    meta = Compiler.decode(format)
    do_to_string(number, meta, options)
  end
  
  # Now we have the number to be formatted, the meta data that 
  # defines the formatting and the options to be applied 
  # (which is related to localisation of the final format)
  defp do_to_string(number, meta, options) do
    to_decimal(number)
    |> multiply_by_factor(meta[:multiplier])
    |> round_to_nearest(meta[:rounding], options[:rounding_mode])
    |> output_to_string(meta[:fractional_digits], options[:rounding_mode])
    |> adjust_leading_zeroes(meta[:integer_digits])
    |> adjust_trailing_zeroes(meta[:fractional_digits])
    |> apply_grouping(meta[:grouping])
    |> reassemble_number_string
    # |> transliterate(options[:locale], options[:number_system])
    # |> apply_padding(meta[:padding_length], meta[:padding_char])
    # |> assemble_format(meta[:format])
  end

  defp to_decimal(number = %Decimal{}), 
    do: number
  defp to_decimal(number), 
    do: Decimal.new(number)
  
  defp multiply_by_factor(number, %Decimal{coef: 1} = _factor) do
    number
  end
  
  defp multiply_by_factor(number, factor) do
    Decimal.mult(number, factor)
  end
  
  defp round_to_nearest(number, %Decimal{coef: 0}, _rounding_mode) do
    number
  end
  
  defp round_to_nearest(number, rounding, rounding_mode) do
    Decimal.div(number, rounding)
    |> Decimal.round(0, rounding_mode)
    |> Decimal.mult(rounding)
  end
  
  defp output_to_string(number, fraction_digits, rounding_mode) do
    string = number
    |> Decimal.round(fraction_digits[:max], rounding_mode)
    |> Decimal.to_string
    
    Regex.named_captures(Compiler.number_match_regex(), string)
  end
  
  # Remove all the trailing zeroes and add back what we
  # need
  defp adjust_trailing_zeroes(number, fraction_digits) do
    fraction = String.trim_trailing(number["fraction"], "0")
    %{number | "fraction" => pad_trailing_zeroes(fraction, fraction_digits[:min])}
  end
 
  # Remove all the leading zeroes and add back what we
  # need
  defp adjust_leading_zeroes(number, integer_digits) do
    integer = String.trim_leading(number["integer"], "0")
    %{number | "integer" => pad_leading_zeroes(integer, integer_digits[:min])}
  end

  # Grouping for when there is only one group size
  defp apply_grouping(string, %{first: first, rest: rest})  when first == rest do
    do_grouping(string, first)
  end
  
  # Group the digits
  defp apply_grouping(number, groups) do
    integer = do_grouping(number["integer"], groups[:integer], :reverse)
    fraction = do_grouping(number["fraction"], groups[:fraction])
    
    %{number | "integer" => integer, "fraction" => fraction}
  end
  
  # TODO: Currently is ignoring the `rest` grouping size
  def do_grouping(string, groups, direction \\ :forward)
  def do_grouping(string, groups, :reverse) do
    String.reverse(string) 
    |> do_grouping(groups)
    |> String.reverse
  end
  def do_grouping(string, %{first: first, rest: _rest}, :forward) do
    chunk_string(string, first)
    |> Enum.join(Compiler.placeholder(:group))
  end
  
  # Put the parts of the number back together again
  # TODO: Not yet handling the exponent
  def reassemble_number_string(%{"fraction" => ""} = number) do
    number["integer"]
  end
  def reassemble_number_string(number) do
    number["integer"] <> Compiler.placeholder(:decimal) <> number["fraction"]
  end
   
  # Merge options and default options with supplied options always
  # the winner.
  defp normalize_options(options, defaults) do
    Keyword.merge defaults, options, fn _k, _v1, v2 -> v2 end
  end
  
end 