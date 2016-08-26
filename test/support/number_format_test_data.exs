defmodule Cldr.Number.Format.Test do
  def test_data do
    [
      {1234, "1,234", []},
      {1234, "1 234", [locale: "fr"]},

      # Data from http://unicode.org/reports/tr35/tr35-numbers.html

      # #Number_Patterns
      {1234.567, "1 234,57",     [format: "#,##0.##",     locale: "fr"]},
      {1234.567, "1 234,567",    [format: "#,##0.###",    locale: "fr"]},
      {1234.567, "1234,567",     [format: "###0.#####",   locale: "fr"]},
      {1234.567, "1234,5670",    [format: "###0.0000#",   locale: "fr"]},
      {1234.567, "01234,5670",   [format: "00000.0000",   locale: "fr"]},
      {1234.567, "1 234,57 €",   [format: "#,##0.00 ¤",   locale: "fr", currency: "EUR"]},
      {1234.567, "1 235 JPY",    [format: "#,##0.00 ¤",   locale: "fr", currency: "JPY"]},

      # #Special_Pattern_Characters
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
      {123.4, "123.40 A$",        [format: "#,##0.00 ¤", currency: "AUD"]},
      {123.4, "123.40 AUD",      [format: "#,##0.00 ¤¤", currency: "AUD"]},
      {123.4, "123.40 Australian dollars", [format: "#,##0.00 ¤¤¤", currency: "AUD"]},
      {123.4, "123.40 $",        [format: "#,##0.00 ¤¤¤¤", currency: "AUD"]},

      # Rounding
      {1234.21, "1,234.20",      [format: "#,##0.05"]},
      {1234.22, "1,234.20",      [format: "#,##0.05"]},
      {1234.23, "1,234.25",      [format: "#,##0.05"]},
      {1234, "1,250",            [format: "#,#50"]},

      # Percentage
      {0.1234, "12.34%",         [format: "#0.0#%"]},

      # Negative number format
      {-1234, "(1234.00)",       [format: "0.00;(0.00)"]},

      # Significant digits format
      {12345, "12300",           [format: "@@#"]},
      {0.12345, "0.123",         [format: "@@#"]},
      {3.14159, "3.142",         [format: "@@##"]},
      {1.23004, "1.23",          [format: "@@##"]},
      {-1.23004, "-1.23",        [format: "@@##"]},

      # Test for when padding specified but there is no padding possible
      {123456789, "123456789",   [format: "*x#"]}
    ]
  end

  def sanitize(string) do
    String.replace(string, "€", "<<e>>")
    |> String.replace("¥", "<<y>>")
  end
end
