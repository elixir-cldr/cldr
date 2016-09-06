# Number & Currency formatting

CLDR defines many different ways to format a number for different uses and defines a set of formats categorised by common pupose to make it easier to express the same intent across many different locales that represent many different territories, cultures, number systems and scripts.

See `Cldr.Number` and `Cldr.Number.to_string/2`

## Formatting Styles

`Cldr` supports the styles of formatting defined by CLDR being:

*  `standard` which formats a number if a decimal format commonly used in many locales.

*  `currency` which formats a number according to the format or a particular currency adjusted for rounding, number of decimal digits after the fraction, whether the currency is accounting or cash rounded and using the appropriate locale-specific currency symbol.

*  `accounting` which formats a positive number like `standard` but which usually wraps a negative number in `()`.

*  `percent` which multiplies a number by 100 and includes a locale-specific percent symbol.  Usually `%`.

*  `permille` which multiples a number by 1,000 and includes a locale specific permille symbol.  Usually `‰`.

*  `scientific` which formats a number as a mantissa and base-10 exponent.

See `Cldr.Number.Formatter.Decimal`

## Short & Long Formats

`Cldr` also supports formats that minimise publishing space or which attempt to make large number more human-readable.

* `decimal_short` which presents number is a narrow space.  For example, `1,000` would be formatted as `1k`.

* `decimal_long` which presents numbers in a sentence form adjusted for plurality and locale.  For example, `1,0000` would be formatted as `1 thousand`.  This is not the same as spelling out the number which is part of the Unicode CLDR Rules-Based Number Formatting.  This capability is not yet available in `Cldr`

*  `currency_short` which formats a number in a manner similar to `decimal_short` but includes the symbol currency.

*  `currency_long` which formats a number in a manner similar to `decimal_long` but incudes the localised name of the current.

See `Cldr.Number.Formatter.Short` and `Cldr.Number.Formatter.Currency`.

## User-Specified Decimal Formats

User-defined decimal formats are also supported using the formats described by
[Unicode technical report TR35](http://unicode.org/reports/tr35/tr35-numbers.html#Number_Format_Patterns).

The formats described therein are supported by `Cldr` with some minor omissions and variations.  Some examples of number formats are:

  | Pattern       | Currency        | Text        |
  | ------------- | :-------------: | ----------: |
  | #,##0.##      | n/a	           | 1 234,57    |
  | #,##0.###     | n/a	           | 1 234,567   |
  | ###0.#####    | n/a	           | 1234,567    |
  | ###0.0000#    | n/a	           | 1234,5670   |
  | 00000.0000    | n/a	           | 01234,5670  |
  | 00            | n/a             | 12          |
  | #,##0.00 ¤    | EUR	           | 1 234,57 €  |

 See `Cldr.Number` and `Cldr.Number.Formatter.Decimal`.

