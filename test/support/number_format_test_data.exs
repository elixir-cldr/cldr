defmodule Cldr.Test.Number.Format do
  def test_data do
    [
      {1234, "1,234", []},
      {1234, "1 234", [locale: "fr"]},
      {0.000123456, "0", []},
      {-0.000123456, "0", []},

      # Data from http://unicode.org/reports/tr35/tr35-numbers.html

      # Number_Patterns
      {1234.567, "1 234,57",     [format: "#,##0.##",     locale: "fr"]},
      {1234.567, "1 234,567",    [format: "#,##0.###",    locale: "fr"]},
      {1234.567, "1234,567",     [format: "###0.#####",   locale: "fr"]},
      {1234.567, "1234,5670",    [format: "###0.0000#",   locale: "fr"]},
      {1234.567, "01234,5670",   [format: "00000.0000",   locale: "fr"]},
      {1234.567, "1 234,57 €",   [format: "#,##0.00 ¤",   locale: "fr", currency: :EUR]},
      {1234.567, "1 235 JPY",    [format: "#,##0.00 ¤",   locale: "fr", currency: "JPY"]},

      # Fraction grouping
      {1234.4353244565, "1234,435 324 456 5", [format: "#,###.###,#########", locale: "pl"]},

      # Special_Pattern_Characters
      {3.1415, "3,14",           [format: "0.00;-0.00",   locale: "fr"]},
      {-3.1415, "-3,14",         [format: "0.00;-0.00",   locale: "fr"]},

      {3.1415, "3,14",           [format: "0.00;0.00-",   locale: "fr"]},
      {-3.1415, "3,14-",         [format: "0.00;0.00-",   locale: "fr"]},

      {3.1415, "3,14+",          [format: "0.00+;0.00-",  locale: "fr"]},
      {-3.1415, "3,14-",         [format: "0.00+;0.00-",  locale: "fr"]},

      # Minimum grouping digits
      {1000, "1000",             [format: "#,##0.##",     locale: "pl"]},
      {10000, "10 000",          [format: "#,##0.##",     locale: "pl"]},

      # Secondary grouping
      {1234567, "12,34,567",     [format: "#,##,###"]},

      # Padding
      {123,  "$xx123.00",        [format: "$*x#,##0.00"]},
      {123,  "xx$123.00",        [format: "*x$#,##0.00"]},
      {123,  "$123.00xx",        [format: "$#,##0.00*x"]},
      {1234, "$1,234.00",        [format: "$*x#,##0.00"]},
      {123,  "! $xx123.00",      [format: "'!' $*x#,##0.00"]},
      {123,  "' $xx123.00",      [format: "'' $*x#,##0.00"]},

      # Currency
      {123.4, "123.40 A$",       [format: "#,##0.00 ¤", currency: :AUD]},
      {123.4, "123.40 AUD",      [format: "#,##0.00 ¤¤", currency: :AUD]},
      {123.4, "123.40 Australian dollars", [format: "#,##0.00 ¤¤¤", currency: :AUD]},
      {123.4, "123.40 $",        [format: "#,##0.00 ¤¤¤¤", currency: :AUD]},
      {1234,  "A$1,234.00",      [currency: :AUD]},

      # Rounding
      {1234.21, "1,234.20",      [format: "#,##0.05"]},
      {1234.22, "1,234.20",      [format: "#,##0.05"]},
      {1234.23, "1,234.25",      [format: "#,##0.05"]},
      {1234, "1,250",            [format: "#,#50"]},

      # Percentage
      {0.1234, "12.34%",         [format: "#0.0#%"]},

      # Permille
      {0.1234, "123.4‰",         [format: "#0.0#‰"]},

      # Negative number format
      {-1234, "(1234.00)",       [format: "#.00;(#.00)"]},

      # Significant digits format
      {12345, "12300",           [format: "@@#"]},
      {0.12345, "0.123",         [format: "@@#"]},
      {3.14159, "3.142",         [format: "@@##"]},
      {1.23004, "1.23",          [format: "@@##"]},
      {-1.23004, "-1.23",        [format: "@@##"]},

      # Test for when padding specified but there is no padding possible
      {123456789, "123456789",   [format: "*x#"]},

      # Scientific formats
      {0.1234, "1.234E-1",       [format: "#E0"]},
      {1.234, "1.234E0",         [format: "#E0"]},
      {12.34, "1.234E1",         [format: "#E0"]},
      {123.4, "1.234E2",         [format: "#E0"]},
      {1234, "1.234E3",          [format: "#E0"]},

      # Scientific with exponent sign
      {1234, "1.234E+3",          [format: "#E+0"]},
      {0.000012456, "1.2456E-5",  [format: "#E+0"]},

      # Maximum digits
      {1234, "34",               [format: "00"]},
      {1, "01.00",               [format: "00.00"]},

      # Scientific formats with grouping
      # {1234, "1.234E3",          [format: "#,###E0"]},
      # {12.34, "0.012E3",         [format: "#,###E0"]}

      # Short formats
      {123, "123",               [format: :short]},
      {1234, "1K",               [format: :short]},
      {12345, "12K",             [format: :short]},
      {1234.5, "1K",             [format: :short]},
      {12345678, "12M",          [format: :short]},
      {1234567890, "1B",         [format: :short]},
      {1234567890000, "1T",      [format: :short]},
      {1234, "1 thousand",       [format: :long]},
      {1234567890, "1 billion",  [format: :long]},

      {1234, "$1K",              [format: :short, currency: :USD]},
      {12345, "12,345 US dollars", [format: :long, currency: :USD]},
      {123,  "A$123",            [format: :short, currency: :AUD]},

      {12, "12 Thai baht",       [format: :long, currency: :THB]},
      {12, "12 bahts thaïlandais", [format: :long, currency: :THB, locale: "fr"]},

      {2134, "A$2K",             [format: :currency_short, currency: :AUD]},
      {2134, "2,134 Australian dollars", [format: :currency_long, currency: :AUD]}
    ]
  end
end
