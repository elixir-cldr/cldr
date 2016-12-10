defmodule Cldr.Number.Formatter.Decimal do
  @moduledoc """
  Formats a number according to a locale-specific predefined format or a user-defined format.

  As a performance optimization, all decimal formats known at compile time are
  compiled into function that roughly halves the time to format a number
  compared to a non-precompiled format.

  The available format styles for a locale can be returned by:

      iex> Cldr.Number.Format.decimal_format_styles_for "en"
      [:accounting, :currency, :currency_long, :percent, :scientific, :standard]

  This allows a number to be formatted in a locale-specific way but using
  a standard method of describing the purpose of the format.

  ## Examples

      iex> Number.to_string 1234, format: :accounting, currency: "JPY"
      "¥1,234"

      iex> Number.to_string -1234, format: :accounting, currency: "JPY"
      "(¥1,234)"

  User defined formats can also be used.  See `Cldr.Number.Format` for
  more information on defining number formats.

  Examples:

      iex> Number.to_string 12345, format: "#,##0.00"
      "12,345.00"

      iex> Number.to_string 12345, format: "0000.00"
      "2345.00"

      iex> Number.to_string 12345, format: "000000"
      "012345"

      # Rounds to the nearest 6.00
      iex> Number.to_string 12345, format: "#,##6.00"
      "12,348.00"
  """

  import Cldr.Macros
  import Cldr.Number.String
  import Cldr.Number.Transliterate, only: [transliterate: 3]
  import Cldr.Number.Symbol,        only: [number_symbols_for: 2]

  alias Cldr.{Currency, Number, Math, Digits}
  alias Cldr.Number.Format
  alias Cldr.Number.Format.Compiler

  @empty_string ""

  # Precompile the known formats
  for format <- Cldr.Number.Format.decimal_format_list() do
    case Compiler.decode(format) do
    {:ok, meta} ->
      quote do
        def to_string(number, unquote(format), options) do
          do_to_string(number, unquote(Macro.escape(meta)), options)
        end
      end
    {:error, message} ->
      raise Cldr.FormatCompileError, message: "#{message} compiling #{inspect format}"
    end
  end

  # For formats not precompiled we need to compile first
  # and then process.
  def to_string(number, format, options) do
    case Compiler.decode(format) do
    {:ok, meta} ->
      do_to_string(number, meta, options)
    {:error, message} ->
      {:error, {Cldr.FormatCompileError, message}}
    end
  end

  # Now we have the number to be formatted, the meta data that
  # defines the formatting and the options to be applied
  # (which is related to localisation of the final format)
  defp do_to_string(number, %{integer_digits: _integer_digits} = meta, options) do
    meta = meta
    |> adjust_fraction_for_currency(options[:currency], options[:cash])
    |> adjust_fraction_for_significant_digits(number)

    number
    |> absolute_value
    |> multiply_by_factor(meta)
    |> round_to_significant_digits(meta)
    |> round_to_nearest(meta, options[:rounding_mode])
    |> adjust_for_exponent(meta)
    |> output_to_string(meta, options[:rounding_mode])
    |> adjust_leading_zeros(:integer, meta)
    |> adjust_trailing_zeros(:fraction, meta)
    |> set_max_integer_digits(meta[:integer_digits].max)
    |> apply_grouping(meta[:grouping], options[:locale])
    |> reassemble_number_string(meta)
    |> transliterate(options[:locale], options[:number_system])
    |> assemble_format(number, meta, options)
  end

  # For when the format itself actually has only literal components
  # and no number format.
  defp do_to_string(number, meta, options) do
    assemble_format("", number, meta, options)
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
    rounding = :math.pow(10, -digits) * rounding
    %{meta | fractional_digits: %{max: digits, min: digits},
             rounding: rounding}
  end

  # If we round to sigificant digits then the format won't (usually)
  # have any fractional part specified and if we don't do something
  # then we're truncating the number - not really what is intended
  # for significant digits display.

  # For when there is no number format
  defp adjust_fraction_for_significant_digits(%{significant_digits: nil} = meta, _number) do
    meta
  end

  # For no significant digits
  defp adjust_fraction_for_significant_digits(%{significant_digits: %{max: 0, min: 0}} = meta, _number) do
    meta
  end

  # No fractional digits for an integer
  defp adjust_fraction_for_significant_digits(%{significant_digits: %{max: _max, min: _min}} = meta, number)
  when is_integer(number) do
    meta
  end

  # Decimal version of an integer => exponent > 0
  defp adjust_fraction_for_significant_digits(%{significant_digits: %{max: _max, min: _min}} = meta,
  %Decimal{exp: exp}) when exp >= 0 do
    meta
  end

  # For all float or Decimal fraction
  defp adjust_fraction_for_significant_digits(%{significant_digits: %{max: _max, min: _min}} = meta, _number) do
    %{meta | fractional_digits: %{max: 10, min: 1}}
  end

  def absolute_value(%Decimal{} = number) do
    Decimal.abs(number)
  end

  def absolute_value(number) do
    abs(number)
  end

  # If the format includes a % (percent) or permille then we
  # adjust the number by a factor.  All other formats the factor
  # is 1 and hence we avoid the multiplication.
  defp multiply_by_factor(number, 1 = _factor) do
    number
  end

  defp multiply_by_factor(%Decimal{} = number, %{multiplier: factor}) when is_integer(factor) do
    Decimal.mult(number, Decimal.new(factor))
  end

  defp multiply_by_factor(number, %{multiplier: factor})
  when is_number(number) and is_number(factor) do
    number * factor
  end

  # Round to significant digits.  This is different to rounding
  # to decimal places and is a more expensive mathematical
  # calculation.  Although the specification allows for minimum
  # and maximum, I haven't found an example of where minimum is a
  # useful rounding value since maximum already removes trailing
  # insignificant zeros.
  #
  # Also note that this implementation allows for both significant
  # digit rounding as we as decimal precision rounding.  Its likely
  # not a good idea to combine the two in a format mask and results
  # are unspecified if you do.
  defp round_to_significant_digits(number, %{significant_digits: %{min: 0, max: 0}}) do
    number
  end

  defp round_to_significant_digits(number, %{significant_digits: %{min: _min, max: max}}) do
    Math.round_significant(number, max)
  end

  # A format can include a rounding specification which we apply
  # here except if there is no rounding specified.
  defp round_to_nearest(number, %{rounding: rounding}, _rounding_mode) when rounding == 0 do
    number
  end

  defp round_to_nearest(%Decimal{} = number, %{rounding: rounding}, rounding_mode) do
    rounding = Decimal.new(rounding)

    number
    |> Decimal.div(rounding)
    |> Decimal.round(0, rounding_mode)
    |> Decimal.mult(rounding)
  end

  defp round_to_nearest(number, %{rounding: rounding}, _rounding_mode) when is_float(number) do
    number
    |> Kernel./(rounding)
    |> Float.round(0)
    |> Kernel.*(rounding)
  end

  defp round_to_nearest(number, %{rounding: rounding}, _rounding_mode) when is_integer(number) do
    number
    |> Kernel./(rounding)
    |> Float.round(0)
    |> Kernel.*(rounding)
    |> trunc
  end

  # For a scientific format we need to adjust to a
  # mantissa * 10^exponent format.
  defp adjust_for_exponent(number, %{exponent_digits: exponent_digits})
  when exponent_digits == 0 do
    {Digits.to_tuple(number), 0}
  end

  defp adjust_for_exponent(number, %{exponent_digits: exponent_digits} = meta) do
    {mantissa, exponent} = Math.mantissa_exponent(number, meta)

    # Take care of minimum exponent digits
    exponent_adjustment = exponent_digits - Digits.number_of_integer_digits(exponent)
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
  # TODO: Not yet implemented
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
  defp output_to_string(number, %{fractional_digits: _fraction_digits}, _rounding_mode) do
    IO.puts inspect(number)
  end

  # Remove all the leading zeros from an integer and add back what
  # is required for the format
  defp adjust_leading_zeros(number, :integer, %{integer_digits: integer_digits}) do
    integer = String.trim_leading(number["integer"], "0")
    %{number | "integer" => pad_leading_zeros(integer, integer_digits[:min])}
  end

  defp adjust_leading_zeros(number, _integer, %{integer_digits: _integer_digits}) do
    number
  end

  # Remove all the trailing zeros from a fraction and add back what
  # is required for the format
  defp adjust_trailing_zeros(number, :fraction, %{fractional_digits: fraction_digits}) do
    fraction = String.trim_trailing(number["fraction"], "0")
    %{number | "fraction" => pad_trailing_zeros(fraction, fraction_digits[:min])}
  end

  defp adjust_trailing_zeros(number, _fraction, %{fractional_digits: _fraction_digits}) do
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
    Format.minimum_grouping_digits_for(locale) + group_size
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
  @exponent_sign      Compiler.placeholder(:exponent_sign)
  defp reassemble_number_string(%{} = number, meta) do
    number["integer"]
    |> append(number["fraction"], @decimal_separator, meta)
    |> append(number["exponent"], @exponent_separator, meta.exponent_sign)
  end

  # Conditionally add a separator and number component to the output string
  # if it exists
  defp append(string, @empty_string, _separator, _meta) do
    string
  end

  # When the exponent is negative then there is no special formatting.  If
  # however the exponent is positive, then we insert a '+' if there is
  # an exponent sign requested.
  defp append(string, part, @exponent_separator = separator, true) do
    if String.starts_with?(part, "-") do
      string <> separator <> part
    else
      string <> separator <> @exponent_sign <> part
    end
  end

  defp append(string, part, separator, _meta) do
    string <> separator <> part
  end

  # Now we can assemble the final format.  Based upon
  # whether the number is positive or negative (as indicated
  # by options[:sign]) we assemble the parts and transliterate
  # the currency sign, percent and permille characters.
  defp assemble_format(number_string, number, meta, options) do
    format = meta.format[options[:pattern]]

    number_string
    |> do_assemble_format(number, meta, format, options)
    |> Enum.join
  end

  defp do_assemble_format(number_string, number, meta, format, options) do
    system   = options[:number_system]
    locale   = options[:locale]
    currency = options[:currency]
    symbols  = number_symbols_for(locale, system)

    Enum.map format, fn (token) ->
      case token do
        {:format, _format}   -> number_string
        {:pad, _}            -> padding_string(meta, number_string)
        {:plus, _}           -> symbols.plus_sign
        {:minus, _}          -> symbols.minus_sign
        {:currency, type}    -> currency_symbol(currency, number, type, locale)
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

  # We can't make the assumption that the padding character is
  # an ascii character - it could be any grapheme so we can't use
  # binary pattern matching.
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
    Number.Cardinal.pluralize(number, locale, currency.count)
  end

  defp currency_symbol(%Currency{} = currency, _number, 4, _locale) do
    currency.narrow_symbol || currency.symbol
  end

  defp currency_symbol(currency, number, size, locale) do
    currency = Currency.for_code(currency, locale)
    currency_symbol(currency, number, size, locale)
  end
end