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
      
      # Padding
      {123,  "$xx123.00",        [format: "$*x#,##0.00"]},
      {1234, "$1,234.00",        [format: "$*x#,##0.00"]},
      
      # Rounding
      {1234.21, "1,234.20",      [format: "#,##0.05"]},
      {1234.22, "1,234.20",      [format: "#,##0.05"]},
      {1234.23, "1,234.25",      [format: "#,##0.05"]},
      {1234, "1,250",            [format: "#,#50"]},
      
      # Percentage
      {0.1234, "12.34%",         [format: "#0.0#%"]}
    ]
  end
  
  def sanitize(string) do
    String.replace(string, "€", "<<e>>")
    |> String.replace("¥", "<<y>>")
  end
end