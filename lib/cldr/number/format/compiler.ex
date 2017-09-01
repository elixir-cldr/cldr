# http://unicode.org/reports/tr35/tr35-numbers.html#Language_Plural_Rules
defmodule Cldr.Number.Format.Compiler do
  @moduledoc """
  Compiles number patterns with a lexer/parser into patterns for fast runtime interpretation.

  Number patterns affect how numbers are interpreted in a localized context.
  Here are some examples, based on the French locale. The "." shows where the
  decimal point should go. The "," shows where the thousands separator should go.
  A "0" indicates zero-padding: if the number is too short, a zero (in the
  locale's numeric set) will go there. A "#" indicates no padding: if the number
  is too short, nothing goes there. A "¤" shows where the currency sign will go.
  The following illustrates the effects of different patterns for the French
  locale, with the number "1234.567". Notice how the pattern characters ',' and
  '.' are replaced by the characters appropriate for the locale.

  ### Number Pattern Examples

  Pattern	   | Currency	 | Text
  ---------- | --------- | ----------
  #,##0.##	 | n/a	     | 1 234,57
  #,##0.###	 | n/a	     | 1 234,567
  ###0.##### | n/a	     | 1234,567
  ###0.0000# | n/a	     | 1234,5670
  00000.0000 | n/a	     | 01234,5670
  #,##0.00 ¤ | EUR	     | 1 234,57 €

  The number of # placeholder characters before the decimal do not matter,
  since no limit is placed on the maximum number of digits. There should,
  however, be at least one zero someplace in the pattern. In currency formats,
  the number of digits after the decimal also do not matter, since the
  information in the supplemental data (see Supplemental Currency Data) is used
  to override the number of decimal places — and the rounding — according to
  the currency that is being formatted. That can be seen in the above chart,
  with the difference between Yen and Euro formatting.

  ## Special Pattern Characters

  Many characters in a pattern are taken literally; they are matched during
  parsing and output unchanged during formatting. Special characters, on the
  other hand, stand for other characters, strings, or classes of characters.
  For example, the '#' character is replaced by a localized digit for the
  chosen numberSystem. Often the replacement character is the same as the
  pattern character; in the U.S. locale, the ',' grouping character is replaced
  by ','. However, the replacement is still happening, and if the symbols are
  modified, the grouping character changes. Some special characters affect the
  behavior of the formatter by their presence; for example, if the percent
  character is seen, then the value is multiplied by 100 before being displayed.

  To insert a special character in a pattern as a literal, that is, without any
  special meaning, the character must be quoted. There are some exceptions to
  this which are noted below.

  ### Number Pattern Character Definitions

  Symbol | Meaning
  ------ | -------
  0	     | Digit
  1..9   | '1' through '9' indicate rounding
  @	     | Significant digit
  #	     | Digit, omitting leading/trailing zeros
  .	     | Decimal separator or monetary decimal separator
  -	     | Minus sign
  ,	     | Grouping separator
  +	     | Prefix positive exponents with localized plus sign
  %	     | Multiply by 100 and show as percentage
  ‰      | Multiply by 1000 and show as per mille (aka “basis points”)
  ;	     | Separates positive and negative subpatterns
  ¤      | Any sequence is replaced by the localized currency symbol
  *	     | Pad escape, precedes pad character
  '	     | Used to quote special characters in a prefix or suffix

  A pattern contains a positive subpattern and may contain a negative
  subpattern, for example, "#,##0.00;(#,##0.00)". Each subpattern has a prefix,
  a numeric part, and a suffix. If there is no explicit negative subpattern,
  the implicit negative subpattern is the ASCII minus sign (-) prefixed to the
  positive subpattern. That is, "0.00" alone is equivalent to "0.00;-0.00".
  (The data in CLDR is normalized to remove an explicit subpattern where it
  would be identical to the explicit form.) If there is an explicit negative
  subpattern, it serves only to specify the negative prefix and suffix; the
  number of digits, minimal digits, and other characteristics are ignored in
  the negative subpattern. That means that "#,##0.0#;(#)" has precisely the
  same result as "#,##0.0#;(#,##0.0#)". However in the CLDR data, the format is
  normalized so that the other characteristics are preserved, just for
  readability.

  Note: The thousands separator and decimal separator in patterns are always
  ASCII ',' and '.'. They are substituted by the code with the correct local
  values according to other fields in CLDR. The same is true of the - (ASCII
  minus sign) and other special characters listed above.

  Extracted from [Unicode number formats in TR35]
  (http://unicode.org/reports/tr35/tr35-numbers.html#Number_Formats)
  """

  import Kernel, except: [length: 1]
  import Cldr.Macros, only: [docp: 1]

  # Placeholders in a pattern that will be replaces with
  # locale specific symbols at run time.  There is a later
  # optimization based upon the understanding that these
  # symbols are also the same as those in the "latn" number
  # system.
  @decimal_separator    "."
  @grouping_separator   ","
  @exponent_separator   "E"
  @currency_placeholder "¤"
  @plus_placeholder     "+"
  @minus_placeholder    "-"
  @digit_omit_zeroes    "#"
  @digits               "[0-9]"
  @significant_digit    "@"
  @default_pad_char     " "

  # Basically no maximum and one minimum integer digit
  # by default
  @max_integer_digits   0
  @min_integer_digits   1

  # Default is a minimum of no fractional digits and
  # a max thats as big as it takes.
  # @max_fraction_digits  0
  @min_fraction_digits  0

  @rounding_pattern     Regex.compile!("[" <> @digit_omit_zeroes <>
    @significant_digit <> @grouping_separator <> "]")

  # Default rounding increment (not the same as rounding decimal
  # digits.  `0` means no rounding increment to be applied.
  @default_rounding     0

  @doc """
  Returns a number placeholder symbol.

  * `symbol` is one of `:decimal`, `group`, `:exponent`,
  `:plus`, `:minus`, `:currency`

  These symbols are used in decimal number format
  and are replaced with locale-specific characters
  during number formatting.

  ## Example

      iex> Cldr.Number.Format.Compiler.placeholder(:plus)
      "+"
  """
  @spec placeholder(:decimal | :group | :exponent | :exponent_sign |
                    :plus | :minus | :currency) :: String.t

  def placeholder(:decimal),        do: @decimal_separator
  def placeholder(:group),          do: @grouping_separator
  def placeholder(:exponent),       do: @exponent_separator
  def placeholder(:plus),           do: @plus_placeholder
  def placeholder(:minus),          do: @minus_placeholder
  def placeholder(:currency),       do: @currency_placeholder
  def placeholder(:exponent_sign),  do: @plus_placeholder

  @doc """
  Scan a number format definition

  Using a leex lexer, tokenize a rule definition
  """
  def tokenize(definition) when is_binary(definition) do
    definition
    |> String.to_charlist
    |> :decimal_formats_lexer.string
  end

  @doc """
  Parse a number format definition

  Using a yexx lexer, parse a nunber format definition into list of
  elements we can then interpret to format a number.

  ## Example

      iex> Cldr.Number.Format.Compiler.parse "¤ #,##0.00;¤-#,##0.00"
      {:ok,
       [positive: [currency: 1, literal: " ", format: "#,##0.00"],
        negative: [currency: 1, minus: '-', format: :same_as_positive]]}
  """
  def parse(tokens) when is_list(tokens) do
    :decimal_formats_parser.parse tokens
  end

  def parse(definition) when is_binary(definition) do
    {:ok, tokens, _end_line} = tokenize(definition)
    tokens |> :decimal_formats_parser.parse
  end

  def parse("") do
    {:error, "empty format string cannot be compiled"}
  end

  def parse(nil) do
    {:error, "no format string or token list provided"}
  end

  def parse(arg) do
    raise ArgumentError, message: "Now idea how to compile format: #{inspect arg}"
  end

  @doc """
  Parse a number format definition and analyze it.

  After parsing, reduce the format to a set of metrics
  that can then be used to format a number.
  """
  def compile(definition) do
    case parse(definition) do
    {:ok, format} ->
      meta_data = analyze(format)
      {:ok, meta_data, formatting_pipeline(meta_data)}
    {:error, {_line, _parser, [message, context]}} ->
      {:error, "Decimal format compiler: #{message}#{Enum.join(context)}"}
    {:error, message} ->
      {:error, message}
    end
  end

  @doc """
  Returns an Elixir AST of a formatting pipeline that
  when executed produces the formatted output for a given
  format string.

  Not all formats require all parts of the full formatting
  pipeline so by compiling only those parts of the pipeline
  that are required we produce an optimal code path.
  """
  def formatting_pipeline(meta) do
    first_stage(:absolute_value)
    |> stage_if_not(:multiply_by_factor, match?(%{multiplier: 1}, meta))
    |> stage_if_not(:round_to_significant_digits, match?(%{significant_digits: %{min: 0, max: 0}}, meta))
    |> stage_if_not(:round_to_nearest, match?(%{rounding: 0}, meta))
    |> stage(:set_exponent)
    # |> stage_if_not(:round_fractional_digits, match?(%{fractional_digits: %{max: 0, min: 0}}, meta))
    |> stage(:round_fractional_digits)
    |> stage(:output_to_tuple)
    |> stage(:adjust_leading_zeros)
    |> stage(:adjust_trailing_zeros)
    |> stage_if_not(:set_max_integer_digits, match?(%{integer_digits: %{max: 0}}, meta))
    |> stage_if_not(:apply_grouping, match?(%{grouping: %{fraction: %{first: 0, rest: 0}, integer: %{first: 0, rest: 0}}}, meta))
    |> stage(:reassemble_number_string)
    |> stage(:transliterate)
    |> stage(:assemble_format)
  end

  defp first_stage(fun) do
    quote context: Cldr.Number.Formatter.Decimal, do: unquote(fun)(var!(number), var!(meta), var!(options))
  end

  defp stage(fun) do
    quote context: Cldr.Number.Formatter.Decimal, do: unquote(fun)(var!(meta), var!(options))
  end

  defp stage(pipeline, fun) do
    Macro.pipe(pipeline, stage(fun), 0)
  end

  defp stage_if_not(pipeline, fun, false) do
    stage(pipeline, fun)
  end

  defp stage_if_not(pipeline, _fun, true) do
    pipeline
  end

  @doc false
  # Outputs the formatting pipeline for a given format
  # Intended primarily to help develop optimization
  # strategies.
  def pipeline(format) do
    case compile(format) do
      {:ok, _meta, stages} ->
        {_, pipe} = Macro.prewalk(stages, [], fn ({name, _, _} = t, acc) ->
          if name not in [:var!, :meta, :options, :number] do
            {t, [name | acc]}
          else
            {t, acc}
          end
        end)
        pipe
      error ->
        error
    end
  end

  docp """
  Extract the metadata from the format.

  The metadata is used to generate the formatted output.  A numeric format
  is optional and in such cases no analysis is required.
  """
  defp analyze(format) do
    do_analyse(format, format[:positive][:format])
  end

  # defp do_analyse(format, nil) do
  #   %{format: format}
  # end

  defp do_analyse(format, positive_format) do
    format_parts = split_format(positive_format)

    meta = %{
      integer_digits:      %{min: required_integer_digits(format_parts),
                             max: max_integer_digits(format_parts)},
      fractional_digits:   %{min: required_fraction_digits(format_parts),
                             max: optional_fraction_digits(format_parts) +
                                  required_fraction_digits(format_parts)},
      significant_digits:  significant_digits(format_parts),
      exponent_digits:     exponent_digits(format_parts),
      exponent_sign:       exponent_sign(format_parts),
      scientific_rounding: scientific_rounding(format_parts),
      grouping:            grouping(format_parts),
      rounding:            rounding(format_parts),
      padding_length:      padding_length(format[:positive][:pad], format),
      padding_char:        padding_char(format),
      multiplier:          multiplier(format),
      format:              format
    }

    reconcile_significant_and_scientific_digits(meta)
  end

  # If we have significant digits defined then they take
  # priority over using the default pattern for significant digits
  defp reconcile_significant_and_scientific_digits(meta) do
    if meta.significant_digits > 0 && meta.exponent_digits > 0 do
      %{meta | scientific_rounding: 0}
    else
      meta
    end
  end

  docp """
  Extract how many integer digits are to be displayed.
  """
  @digits_match Regex.compile!("(?<digits>" <> @digits <> "+)")
  defp required_integer_digits(%{"compact_integer" => integer_format}) do
    if captures = Regex.named_captures(@digits_match, integer_format) do
      String.length(captures["digits"])
    else
      @min_integer_digits
    end
  end
  defp required_integer_digits(_), do: @min_integer_digits

  docp """
  If the pattern starts with a non-digit then its no limit on integer
  digits.  If the pattern starts with a digit then the maximum number
  of digits is the length of the integer pattern.  We can assume there
  are no '#' after digits since thats not permitted by the parser.
  """
  @first_is_digit Regex.compile!("^" <> @digits)
  defp max_integer_digits(%{"compact_integer" => integer_format}) do
    if Regex.match?(@first_is_digit, integer_format) do
      String.length(integer_format)
    else
      @max_integer_digits
    end
  end
  defp max_integer_digits(_), do: @max_integer_digits

  docp """
  Extract how many fraction digits must be displayed.
  """
  defp required_fraction_digits(%{"compact_fraction" => nil}), do: 0
  defp required_fraction_digits(%{"compact_fraction" => fraction_format}) do
    if captures = Regex.named_captures(@digits_match, fraction_format) do
      String.length(captures["digits"])
    else
      @min_fraction_digits
    end
  end
  defp required_fraction_digits(_), do: @min_fraction_digits

  docp """
  Extract how many additional fraction digits may be displayed.
  """
  @hashes_match Regex.compile!("(?<hashes>[" <> @digit_omit_zeroes <> "]+)")
  defp optional_fraction_digits(%{"compact_fraction" => ""}), do: 0
  defp optional_fraction_digits(%{"compact_fraction" => fraction_format}) do
    if captures = Regex.named_captures(@hashes_match, fraction_format) do
      String.length(captures["hashes"])
    else
      0
    end
  end
  defp optional_fraction_digits(_), do: 0

  docp """
  Extract the exponent from the format
  """
  defp exponent_digits(%{"exponent_digits" => ""}), do: 0
  defp exponent_digits(%{"exponent_digits" => exp}) do
    String.length(exp)
  end
  defp exponent_digits(_), do: 0

  docp """
  Extract whether a + sign was given the format exponent
  """
  def exponent_sign(%{"exponent_sign" => ""}), do: false
  def exponent_sign(%{"exponent_sign" => _exponent_sign}), do: true
  def exponent_sign(_), do: false

  docp """
  Extract the number of significant digits to round the mantissa
  to.  If we've already calculated a significant digits number
  using the "@@###" form then we'll use that instead.
  """
  @scientific_match Regex.compile!("(?<scientific_rounding>0[0#]*)?")
  defp scientific_rounding(%{"exponent_digits" => ""}), do: 0

  defp scientific_rounding((%{"compact_integer"  => integer_format,
                             "compact_fraction" => fraction_format})) do
    format = integer_format <> fraction_format
    if captures = Regex.named_captures(@scientific_match, format) do
      String.length(captures["scientific_rounding"])
    else
      0
    end
  end
  defp scientific_rounding(_), do: 0

  docp """
  Extract the padding length of the format.

  Patterns support padding the result to a specific width. In a pattern the pad
  escape character, followed by a single pad character, causes padding to be
  parsed and formatted. The pad escape character is '*'. For example,
  "$*x#,##0.00" formats 123 to "$xx123.00" , and 1234 to "$1,234.00" .

  When padding is in effect, the width of the positive subpattern, including
  prefix and suffix, determines the format width. For example, in the pattern
  "* #0 o''clock", the format width is 10.

  Some parameters which usually do not matter have meaning when padding is
  used, because the pattern width is significant with padding. In the pattern
  "* ##,##,#,##0.##", the format width is 14. The initial characters "##,##,"
  do not affect the grouping size or maximum integer digits, but they do affect
  the format width.

  Padding may be inserted at one of four locations: before the prefix, after
  the prefix, before the suffix, or after the suffix. No padding can be
  specified in any other location. If there is no prefix, before the prefix and
  after the prefix are equivalent, likewise for the suffix. When specified in a
  pattern, the code point immediately following the pad escape is the pad
  character. This may be any character, including a special pattern character.
  That is, the pad escape escapes the following character. If there is no
  character after the pad escape, then the pattern is illegal.

  This function determines the length of the pattern against which we pad if
  required.  Although the padding length is considered to be the sum of the
  prefix, format and suffix the reality is that prefix and suffix also fill
  part of the format so the padding length is really only the length of the
  format itself, not including any quote marks that escape characters. Then
  we need to consider any padding applicable to the currency format.

  The currency placeholder is between 1 and 5 characters.  The substitution can
  be between 1 and an arbitrarily sized string.  Worse, we don't know the
  substitution until runtime so we can't precalculate it.
  """
  defp padding_length(nil, _format) do
    0
  end

  defp padding_length(_pad, format) do
    String.length(format[:positive][:format])
    # Enum.reduce format[:positive], 0, fn (element, len) ->
    #   len + case element do
    #     {:quote, _}         -> 1  # Since its '' in the format
    #     {:quoted_char, _}   -> 2  # Since its 'x' in the format
    #     {:format, format}   -> String.length(format)
    #     _                   -> 0
    #   end
    # end
  end

  docp """
  The pad character to be applied if padding is in effect.
  """
  def padding_char(format) do
    format[:positive][:pad] || @default_pad_char
  end

  docp """
  Return a scale factor depending on the format mask.

  We multiply the number by a scale factor if the format
  has a percent or permille symbol.
  """
  defp multiplier(format) do
    cond do
      percent_format?(format)   -> 100
      permille_format?(format)  -> 1000
      true                      -> 1
    end
  end

  docp """
  Return the size of the groupings (first and rest) for the format.

  An integer format may have zero, one or two groupings - any others
  are ignored. A fraction format may have one group only.
  """
  defp grouping(%{"integer" => integer_format, "fraction" => fraction_format}) do
    %{integer: integer_grouping(integer_format),
      fraction: fraction_grouping(fraction_format)}
  end
  defp grouping(_) do
    %{integer: %{first: @max_integer_digits, rest: @max_integer_digits},
      fraction: %{first: @max_integer_digits, rest: @max_integer_digits}}
  end

  docp """
  Extract the integer grouping
  """
  defp integer_grouping(format) do
    [_drop | groups] = String.split(format, @grouping_separator)

    grouping = groups
    |> Enum.reverse
    |> Enum.slice(0..1)
    |> Enum.map(&String.length/1)

    case grouping do
      [first, rest] ->
        %{first: first, rest: rest}
      [first] ->
        %{first: first, rest: first}
      _ ->
        %{first: @max_integer_digits, rest: @max_integer_digits}
    end
  end

  docp """
  Extract the fraction grouping
  """
  defp fraction_grouping(format) do
    [group | _drop] = String.split(format, @grouping_separator)
    group_size = String.length(group)
    if group_size == 1 do
      %{first: @max_integer_digits, rest: @max_integer_digits}
    else
      %{first: group_size, rest: group_size}
    end
  end


  docp """
  Extracts the significant digit metrics from the format.

  There are two ways of controlling how many digits are shows: (a) significant
  digits counts, or (b) integer and fraction digit counts. Integer and fraction
  digit counts are described above. When a formatter is using significant
  digits counts, it uses however many integer and fraction digits are required
  to display the specified number of significant digits. It may ignore min/max
  integer/fraction digits, or it may use them to the extent possible.

  Significant Digits Examples

  Pattern	| Min sign. digits  | Max sign. digits  | Number	  | Output
  ------- | ----------------- | ----------------- | --------- | ------
  @@@	    | 3	                | 3	                | 12345	    | 12300
  @@@	    | 3	                | 3	                | 0.12345	  | 0.123
  @@##	  | 2	                | 4	                | 3.14159	  | 3.142
  @@##	  | 2	                | 4	                | 1.23004	  | 1.23

  * In order to enable significant digits formatting, use a pattern containing
    the '@' pattern character.

  * In order to disable significant digits formatting, use a pattern that
    does not contain the '@' pattern character.

  * Significant digit counts may be expressed using patterns that specify a
    minimum and maximum number of significant digits. These are indicated by
    the '@' and '#' characters. The minimum number of significant digits is the
    number of '@' characters. The maximum number of significant digits is the
    number of '@' characters plus the number of '#' characters following on the
    right. For example, the pattern "@@@" indicates exactly 3 significant
    digits. The pattern "@##" indicates from 1 to 3 significant digits.
    Trailing zero digits to the right of the decimal separator are suppressed
    after the minimum number of significant digits have been shown. For
    example, the pattern "@##" formats the number 0.1203 as "0.12".

  * Implementations may forbid the use of significant digits in combination
    with min/max integer/fraction digits. In such a case, if a pattern uses
    significant digits, it may not contain a decimal separator, nor the '0'
    pattern character. Patterns such as "@00" or "@.###" would be disallowed.

    -> This implementation takes no special care with regard to mixing
       significant digits and other formats.  Mixing formats
       results in unspecified output.

  * Any number of '#' characters may be prepended to the left of the
    leftmost '@' character. These have no effect on the minimum and maximum
    significant digits counts, but may be used to position grouping separators.
    For example, "#,#@#" indicates a minimum of one significant digits, a
    maximum of two significant digits, and a grouping size of three.

  * The number of significant digits has no effect on parsing.

  * Significant digits may be used together with exponential notation. Such
    patterns are equivalent to a normal exponential pattern with a minimum and
    maximum integer digit count of one, a minimum fraction digit count of
    Minimum Significant Digits - 1, and a maximum fraction digit count of
    Maximum Significant Digits - 1. For example, the pattern "@@###E0" is
    equivalent to "0.0###E0".
  """
  # Build up the regex to extract the '@' and following '#' from the pattern
  @min_significant_digits   "(?<ats>" <> @significant_digit <> "+)"
  @max_significant_digits   "(?<hashes>" <> @digit_omit_zeroes <> "*)?"
  @leading_digits "([" <> @digit_omit_zeroes
      <> @grouping_separator <> "]" <> "*)?"
  @significant_digits_match Regex.compile!(@leading_digits
      <> @min_significant_digits <> @max_significant_digits)

  defp significant_digits(%{"compact_integer" => integer_format,
                            "compact_fraction" => fraction_format}) do
    format = integer_format <> fraction_format
    if captures = Regex.named_captures(@significant_digits_match, format) do
      minimum = String.length(captures["ats"])
      maximim = minimum + String.length(captures["hashes"])
      %{min: minimum, max: maximim}
    else
      %{min: 0, max: 0}
    end
  end
  defp significant_digits(_), do: %{min: 0, max: 0}

  docp """
  Extract the rounding value from a format.

  Patterns support rounding to a specific increment. For example, 1230 rounded
  to the nearest 50 is 1250. Mathematically, rounding to specific increments is
  performed by dividing by the increment, rounding to an integer, then
  multiplying by the increment. To take a more bizarre example, 1.234 rounded
  to the nearest 0.65 is 1.3, as follows:

  | Original:                       | 1.234     |
  | Divide by increment (0.65):     | 1.89846…  |
  | Round:                          | 2         |
  | Multiply by increment (0.65):   | 1.3       |

  To specify a rounding increment in a pattern, include the increment in the
  pattern itself. "#,#50" specifies a rounding increment of 50. "#,##0.05"
  specifies a rounding increment of 0.05.

  * Rounding only affects the string produced by formatting. It does not affect
    parsing or change any numerical values.

  * An implementation may allow the specification of a rounding mode to
    determine how values are rounded. In the absence of such choices, the
    default is to round "half-even", as described in IEEE arithmetic. That is,
    it rounds towards the "nearest neighbor" unless both neighbors are
    equidistant, in which case, it rounds towards the even neighbor. Behaves as
    for round "half-up" if the digit to the left of the discarded fraction is
    odd; behaves as for round "half-down" if it's even. Note that this is the
    rounding mode that minimizes cumulative error when applied repeatedly over
    a sequence of calculations.

  * Some locales use rounding in their currency formats to reflect the smallest
    currency denomination.

  * In a pattern, digits '1' through '9' specify rounding, but otherwise
    behave identically to digit '0'.
  """
  defp rounding(%{"integer" => integer_format, "fraction" => fraction_format}) do
    format = integer_format <> @decimal_separator <> fraction_format
    |> String.replace(@rounding_pattern, "")
    |> String.trim_trailing(@decimal_separator)

    case Float.parse(format) do
      :error         -> @default_rounding
      {rounding, ""} -> rounding
    end
  end
  defp rounding(_), do: @default_rounding

  @doc """
  A regular expression that can be used to split either a number format
  or a number itself.

  Since it accepts characters that are not digits (like '#', '@' and
  ',') it cannot be used to validate a number.  Its only use is to split
  a number or a format into parts for later processing.
  """

  @integer_digits  "(?<integer>[@#0-9,]+)"
  @fraction_digits "([.](?<fraction>[#0-9,]+))?"
  @exponent        "(E(?<exponent_sign>[+-])?(?<exponent_digits>[0-9]))?"
  @format Regex.compile!(@integer_digits <> @fraction_digits <> @exponent)
  def number_match_regex do
    @format
  end

  docp """
  Separate the format into the integer, fraction and exponent parts.
  """
  defp split_format(nil) do
    %{}
  end

  defp split_format(format) do
    parts = Regex.named_captures(@format, format)

    parts
    |> Map.put("compact_integer",
        String.replace(parts["integer"], @grouping_separator, ""))
    |> Map.put("compact_fraction",
        String.replace(parts["fraction"], @grouping_separator, ""))
  end

  defp percent_format?(format) do
    Keyword.has_key? format[:positive], :percent
  end

  defp permille_format?(format) do
    Keyword.has_key? format[:positive], :permille
  end

  # defp currency_format?(format) do
  #   Keyword.has_key? format[:positive], :currency
  # end

  # defp scientific_format?(format) do
  #   Keyword.has_key? format[:positive], :exponent
  # end
end
