defmodule Cldr.Test.Number.Split.Format do
  def test_data do
    [
      {"#",         %{"exponent_digits" => "", "exponent_sign" => "", "fraction" => "", "integer" => "#"}},
      {"###",       %{"exponent_digits" => "", "exponent_sign" => "", "fraction" => "", "integer" => "###"}},
      {"###.0",     %{"exponent_digits" => "", "exponent_sign" => "", "fraction" => "0", "integer" => "###"}},
      {"#00.0",     %{"exponent_digits" => "", "exponent_sign" => "", "fraction" => "0", "integer" => "#00"}},
      {"#00.0E0",   %{"exponent_digits" => "0", "exponent_sign" => "", "fraction" => "0", "integer" => "#00"}},
      {"#00.0E+0",  %{"exponent_digits" => "0", "exponent_sign" => "+", "fraction" => "0", "integer" => "#00"}},
      {"#00.0E-0",  %{"exponent_digits" => "0", "exponent_sign" => "-", "fraction" => "0", "integer" => "#00"}},
      {"#00E-0",    %{"exponent_digits" => "0", "exponent_sign" => "-", "fraction" => "", "integer" => "#00"}},
    ]
  end
end
