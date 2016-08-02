# http://icu-project.org/apiref/icu4c/classRuleBasedNumberFormat.html
defmodule Cldr.Number do
  @default_rounding 2
  
  @type format :: :standard | :short | :long | :percent | :scientific
  
  @spec to_string(number, Cldr.locale, format) :: String.t
  # Use the format from Percent format with the text expansion
  def to_string(number, locale, :percent) do
    IO.puts inspect(number)
  end
  
  # Use the format from Scientific format with the text expansion
  def to_string(number, locale, :scientific) do
    IO.puts inspect(number)
  end
end 