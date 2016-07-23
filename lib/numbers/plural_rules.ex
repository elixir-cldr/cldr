# http://unicode.org/reports/tr35/tr35-numbers.html#Language_Plural_Rules
defmodule Cldr.Numbers.PluralRules do
  def test when rem(3,1) == 0 do
    IO.puts "Testing"
  end
end