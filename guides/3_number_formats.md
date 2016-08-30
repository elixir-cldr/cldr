# Number & Currency formatting

How to read and write formats
*  Decimal
*  Rounding
*  Significant digits
*  Padding
*  Currency
*  Percent & Permille
*  Scientific

How formats are organized in a locale
Number Systems and how to interpret them
Digit and placeholder transliteration
Format compilation
Adding user defined formats for compilation
Differences between decimal formatting and currency formatting

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

  Number patterns affect how numbers are interpreted in a localized context.
  Here are some examples, based on the French locale. The "." shows where the
  decimal point should go. The "," shows where the thousands separator should
  go. A "0" indicates zero-padding: if the number is too short, a zero (in the
  locale's numeric set) will go there. A "#" indicates no padding: if the
  number is too short, nothing goes there. A "¤" shows where the currency sign
  will go. The following illustrates the effects of different patterns for the
  French locale, with the number "1234.567". Notice how the pattern characters
  ',' and '.' are replaced by the characters appropriate for the locale.

  ## Number Pattern Examples

  | Pattern	      | Currency	      | Text        |
  | ------------- | :-------------: | ----------: |
  | #,##0.##	    | n/a	            | 1 234,57    |
  | #,##0.###	    | n/a	            | 1 234,567   |
  | ###0.#####	  | n/a	            | 1234,567    |
  | ###0.0000#	  | n/a	            | 1234,5670   |
  | 00000.0000	  | n/a	            | 01234,5670  |
  | 00            | n/a             | 12
  | #,##0.00 ¤	  | EUR	            | 1 234,57 €  |

  The number of # placeholder characters before the decimal do not matter,
  since no limit is placed on the maximum number of digits. There should,
  however, be at least one zero some place in the pattern. In currency formats,
  the number of digits after the decimal also do not matter, since the
  information in the supplemental data (see Supplemental Currency Data) is used
  to override the number of decimal places — and the rounding — according to
  the currency that is being formatted. That can be seen in the above chart,
  with the difference between Yen and Euro formatting.

  Details of the number formats are described in the
  [Unicode documentation](http://unicode.org/reports/tr35/tr35-numbers.html#Number_Format_Patterns)
  """