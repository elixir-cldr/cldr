# Number and Currency Localization and Formatting

CLDR defines many different ways to format a number for different uses and defines a set of formats categorised by common pupose to make it easier to express the same intent across many different locales that represent many different territories, cultures, number systems and scripts.

See `Cldr.Number` and `Cldr.Number.to_string/2`

## Public API

The primary api for number formatting is `Cldr.Number.to_string/2`.  It provides the ability to format numbers in a standard way for configured locales.  It also provides the means for format numbers as a currency, as a short form (like 1k instead of 1,000).  Additionally it provides formats to spell a number in works, format it as roman numerals and output an ordinal number.  Some examples illustrate:

```elixir
      iex> Cldr.Number.to_string 12345
      {:ok, "12,345"}

      iex> Cldr.Number.to_string 12345, locale: "fr"
      {:ok, "12 345"}

      iex> Cldr.Number.to_string 12345, locale: "fr", currency: "USD"
      {:ok, "12 345,00 $US"}

      iex(4)> Cldr.Number.to_string 12345, format: "#E0"
      {:ok, "1.2345E4"}

      iex> Cldr.Number.to_string 12345, format: :accounting, currency: "THB"
      {:ok, "THB12,345.00"}

      iex> Cldr.Number.to_string -12345, format: :accounting, currency: "THB"
      {:ok, "(THB12,345.00)"}

      iex> Cldr.Number.to_string 12345, format: :accounting, currency: "THB", locale: "th"
      {:ok, "THB12,345.00"}

      iex> Cldr.Number.to_string 12345, format: :accounting, currency: "THB", locale: "th", number_system: :native
      {:ok, "THB๑๒,๓๔๕.๐๐"}

      iex> Cldr.Number.to_string 1244.30, format: :long
      {:ok, "1 thousand"}

      iex> Cldr.Number.to_string 1244.30, format: :long, currency: "USD"
      {:ok, "1,244.30 US dollars"}

      iex> Cldr.Number.to_string 1244.30, format: :short
      {:ok, "1K"}

      iex> Cldr.Number.to_string 1244.30, format: :short, currency: "EUR"
      {:ok, "€1.24K"}

      iex> Cldr.Number.to_string 1234, format: :spellout
      {:ok, "one thousand two hundred thirty-four"}

      iex> Cldr.Number.to_string 1234, format: :spellout_verbose
      {:ok, "one thousand two hundred and thirty-four"}

      iex> Cldr.Number.to_string 123, format: :ordinal
      {:ok, "123rd"}

      iex(4)> Cldr.Number.to_string 123, format: :roman
      {:ok, "CXXIII"}
```

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

## Rule Based Number Formats

CLDR provides an additional mechanism for the formatting of numbers.  The two primary purposes of such rules are to support formatting numbers:

* As words.  For example, formatting 123 into "one hundred and twenty-three" for the "en" locale.  The applicable format is `:spellout`

* As a year. In many languages the written form of a year is different to that used for an arbitrary number.  For example, formatting 1989 would result in "nineteen eighty-nine".  The applicable format is :spellout_year

* As an ordinal.  For example, formatting 123 into "123rd".  The applicable format type is `:ordinal`

* As Roman numerals. For example, formatting 123 into "CXXIII".  The applicable formats are `:roman` or `:roman_lower`

There are also many additional methods more specialised to a specific locale that cater for languages with more complex gender and grammar requirements.  Since these rules are specialised to a locale it is not possible to standarise the public API more than described in this section.

The full set of RBNF formats is accessable through the modules `Cldr.Rbnf.Ordinal`, `Cldr.Rbnf.Spellout` and `Cldr.Rbnf.NumberSystems`.

Each of these modules has a set of functions that are generated at compile time that implement the relevant RBNF rules.  The available rules for a given locale can be retrieved by calling `Cldr.Rbnf.Spellout.rule_set(locale)` or the same function on the other modules.  For example:

    iex> Cldr.Rbnf.Ordinal.rule_sets "en"
    [:digits_ordinal]

    iex> Cldr.Rbnf.Spellout.rule_sets "fr"
    [:spellout_ordinal_masculine_plural, :spellout_ordinal_masculine,
     :spellout_ordinal_feminine_plural, :spellout_ordinal_feminine,
     :spellout_numbering_year, :spellout_numbering, :spellout_cardinal_masculine,
     :spellout_cardinal_feminine]

These rule-based formats are invoked directly on the required module passing the number and locale.  For example:

    iex> Cldr.Rbnf.Spellout.spellout_numbering_year 1989, "fr"
    "dix-neuf-cent quatre-vingt-neuf"

    iex> Cldr.Rbnf.Spellout.spellout_numbering_year 1989, "en"
    "nineteen eighty-nine"

    iex> Cldr.Rbnf.Ordinal.digits_ordinal 1989, "en"
    "1,989th"

### RBNF Rules with Float numbers

RBNF is primarily oriented towards positive integral numbers.  Whilst the standard caters for negative numbers and fractional numbers the implementation of the rules is incomplete.  Use with care.


