# http://unicode.org/reports/tr35/tr35-numbers.html#Language_Plural_Rules
defmodule Cldr.Number.Format.Compiler do
  import Kernel, except: [length: 1]
  
  @decimal_separator    "."
  @grouping_separator   ","
  @exponent_separator   "E"
  @currency_placeholder "¤"
  @plus_placeholder     "+"
  @minus_placeholder    "-"
  @digit_omit_zeroes    "#"
  @digits               ~r/[0-9]/
  @significant_digit    "@"
  
  {:ok, rounding_pattern}  = 
    Regex.compile("[" <> @digit_omit_zeroes <> @significant_digit <> @grouping_separator <> "]")
    
  @rounding_pattern     rounding_pattern
  @max_integer_digits   trunc(:math.pow(2, 32))
  @min_integer_digits   0
  
  @max_fraction_digits  @max_integer_digits
  @min_fraction_digits  @min_integer_digits
  
  @doc """
  Returns a map of the number placeholder symbols.
  
  These symbols are used in decimal number format
  and are replaced with locale-specific characters
  during number formatting.
  
  ## Example
  
  """
  @spec placeholders :: %{}
  def placeholders do
    %{
      decimal:              @decimal_separator,
      group:                @grouping_separator,
      exponent:             @exponent_separator,
      plus:                 @plus_placeholder,
      minus:                @minus_placeholder
    }
  end
  
  @doc """
  Scan a number format definition
  
  Using a leex lexer, tokenize a rule definition
  """
  def tokenize(definition) when is_binary(definition) do
    String.to_charlist(definition) |> :decimal_formats_lexer.string
  end
  
  @doc """
  Parse a number format definition

  Using a yexx lexer, parse a nunber format definition into an Elixir
  AST that can then be `unquoted` into a function definition.
  """
  def parse(tokens) when is_list(tokens) do
    :decimal_formats_parser.parse tokens
  end

  def parse(definition) when is_binary(definition) do
    {:ok, tokens, _end_line} = tokenize(definition)
    tokens |> :decimal_formats_parser.parse
  end
  
  def decode(definition) do
    case parse(definition) do
    {:ok, format} ->
      analyze(format)
    {:error, {_line, _parser, [message, [context]]}} ->
      {:error, "Decimal format compiler: #{message}#{context}"}
    end
  end
    
  defp analyze(format) do
    %{
      currency?:          currency_format?(format),
      length:             length(format),
      multiplier:         multiplier(format),
      grouping:           grouping(format),
      significant_digits: significant_digits(format),
      rounding:           rounding(format),
      format:             format
    }
  end
  
  @docp """
  *Padding*

  Patterns support padding the result to a specific width. In a pattern the pad escape character, 
  followed by a single pad character, causes padding to be parsed and formatted. The pad escape 
  character is '*'. For example, "$*x#,##0.00" formats 123 to "$xx123.00" , and 1234 to "$1,234.00" .

  When padding is in effect, the width of the positive subpattern, including prefix and 
  suffix, determines the format width. For example, in the pattern "* #0 o''clock", the format 
  width is 10.
  
  Some parameters which usually do not matter have meaning when padding is used, because the 
  pattern width is significant with padding. In the pattern "* ##,##,#,##0.##", the format width 
  is 14. The initial characters "##,##," do not affect the grouping size or maximum integer digits, 
  but they do affect the format width.
  
  Padding may be inserted at one of four locations: before the prefix, after the prefix, 
  before the suffix, or after the suffix. No padding can be specified in any other location. 
  If there is no prefix, before the prefix and after the prefix are equivalent, likewise for the suffix.
  When specified in a pattern, the code point immediately following the pad escape is the pad 
  character. This may be any character, including a special pattern character. That is, the pad 
  escape escapes the following character. If there is no character after the pad escape, then 
  the pattern is illegal.
  
  This function determines the length of the pattern against which we pad if required.
  """
  defp length(format) do
    Enum.reduce format[:positive], 0, fn (element, len) ->
      len + case element do
        {:currency, size}   -> size
        {:percent, _}       -> 1
        {:permille, _}      -> 1
        {:plus, _}          -> 1
        {:minus, _}         -> 1
        {:literal, literal} -> String.length(literal)
        {:format, format}   -> String.length(format)
      end
    end
  end 
  
  defp multiplier(format) do
    cond do
      percent_format?(format)   -> 100
      permille_format?(format)  -> 1000
      true                      -> 1
    end
  end
  
  defp grouping(format) do
    [integer_format | _fraction_format] = String.split(format[:positive][:format], @decimal_separator)
    [_drop | groups] = String.split(integer_format, @grouping_separator)
    
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
        %{first: 0, rest: 0}
    end
  end
  
  @docp """
  *Significant Digits*

  There are two ways of controlling how many digits are shows: (a) significant digits counts, or 
  (b) integer and fraction digit counts. Integer and fraction digit counts are described above. 
  When a formatter is using significant digits counts, it uses however many integer and fraction 
  digits are required to display the specified number of significant digits. It may ignore min/max 
  integer/fraction digits, or it may use them to the extent possible.

  Significant Digits Examples
  
  | Pattern	| Minimum significant digits  | Maximum significant digits  | Number	  | Output |
  |---------|-----------------------------|-----------------------------|-----------|--------|
  | @@@	    | 3	                          | 3	                          | 12345	    | 12300  |
  | @@@	    | 3	                          | 3	                          | 0.12345	  | 0.123  |
  | @@##	  | 2	                          | 4	                          | 3.14159	  | 3.142  |
  | @@##	  | 2	                          | 4	                          | 1.23004	  | 1.23   |

  * In order to enable significant digits formatting, use a pattern containing the '@' pattern character.
  
  * In order to disable significant digits formatting, use a pattern that does not contain the '@' 
  pattern character.
  
  * Significant digit counts may be expressed using patterns that specify a minimum and maximum 
  number of significant digits. These are indicated by the '@' and '#' characters. The minimum number 
  of significant digits is the number of '@' characters. The maximum number of significant digits 
  is the number of '@' characters plus the number of '#' characters following on the right. 
  For example, the pattern "@@@" indicates exactly 3 significant digits. The pattern "@##" indicates 
  from 1 to 3 significant digits. Trailing zero digits to the right of the decimal separator are 
  suppressed after the minimum number of significant digits have been shown. For example, the 
  pattern "@##" formats the number 0.1203 as "0.12".
  
  * Implementations may forbid the use of significant digits in combination with min/max 
  integer/fraction digits. In such a case, if a pattern uses significant digits, it may 
  not contain a decimal separator, nor the '0' pattern character. Patterns such as "@00" or 
  "@.###" would be disallowed.
  
  * Any number of '#' characters may be prepended to the left of the leftmost '@' character. 
  These have no effect on the minimum and maximum significant digits counts, but may be used to 
  position grouping separators. For example, "#,#@#" indicates a minimum of one significant digits, 
  a maximum of two significant digits, and a grouping size of three.
  
  * The number of significant digits has no effect on parsing.
  
  * Significant digits may be used together with exponential notation. Such patterns are 
  equivalent to a normal exponential pattern with a minimum and maximum integer digit count 
  of one, a minimum fraction digit count of Minimum Significant Digits - 1, and a maximum 
  fraction digit count of Maximum Significant Digits - 1. For example, the pattern "@@###E0" 
  is equivalent to "0.0###E0".
  """
  
  # Build up the regex to extract the '@' and following '#' from the pattern
  @leading_digits           "([" <> @digit_omit_zeroes <> @grouping_separator <> "]" <> "*)?"
  @min_significant_digits   "(?<ats>" <> @significant_digit <> "+)"
  @max_significant_digits   "(?<hashes>" <> @digit_omit_zeroes <> "*)?"
  {:ok, regex} = Regex.compile(@leading_digits <> @min_significant_digits <> @max_significant_digits)
  @significant_digits_match regex
  
  defp significant_digits(format) do
    compacted_format = String.replace(format[:positive][:format], @grouping_separator, "")
    if captures = Regex.named_captures(@significant_digits_match, compacted_format) do
      minimum_significant_digits = String.length(captures["ats"])
      maximim_significant_digits = minimum_significant_digits + String.length(captures["hashes"])
      %{minimum_significant_digits: minimum_significant_digits, maximum_significant_digits: maximim_significant_digits}
    else
      %{minimum_significant_digits: 0, maximum_significant_digits: 0}
    end
  end
  
  @docp """
  *Rounding*

  Patterns support rounding to a specific increment. For example, 1230 rounded to
  the nearest 50 is 1250. Mathematically, rounding to specific increments is
  performed by dividing by the increment, rounding to an integer, then multiplying
  by the increment. To take a more bizarre example, 1.234 rounded to the nearest
  0.65 is 1.3, as follows:

  | Original:                       | 1.234     |
  | Divide by increment (0.65):     | 1.89846…  |
  | Round:                          | 2         |
  | Multiply by increment (0.65):   | 1.3       |

  To specify a rounding increment in a pattern, include the increment in the pattern itself.
  "#,#50" specifies a rounding increment of 50. "#,##0.05" specifies a rounding increment of 0.05.

  * Rounding only affects the string produced by formatting. It does not affect parsing or change any numerical values.
  
  * An implementation may allow the specification of a rounding mode to determine how values are
  rounded. In the absence of such choices, the default is to round "half-even", as described
  in IEEE arithmetic. That is, it rounds towards the "nearest neighbor" unless both neighbors
  are equidistant, in which case, it rounds towards the even neighbor. Behaves as for round
  "half-up" if the digit to the left of the discarded fraction is odd; behaves as for round
  "half-down" if it's even. Note that this is the rounding mode that minimizes cumulative error
  when applied repeatedly over a sequence of calculations.

  * Some locales use rounding in their currency formats to reflect the smallest currency denomination.
  
  * In a pattern, digits '1' through '9' specify rounding, but otherwise behave identically to digit '0'.
  """
  defp rounding(format) do
    String.replace(format[:positive][:format], @rounding_pattern, "")
    |> Decimal.new
  end
  
  defp percent_format?(format) do
    Keyword.has_key? format[:positive], :percent
  end
  
  defp permille_format?(format) do
    Keyword.has_key? format[:positive], :permille
  end
  
  defp currency_format?(format) do
    Keyword.has_key? format[:positive], :currency
  end
end      
         