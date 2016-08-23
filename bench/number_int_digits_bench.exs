defmodule Number.Int.Digits.Test do
  use Benchfella

  @int 1_000_000_000
  @decimal Decimal.new(@int)

  bench "Divide by 10" do
    Cldr.Number.Math.number_of_integer_digits(@int)
  end

  bench "floor(log10(number)) + 1" do
    Cldr.Number.Math.number_of_integer_digits2(@int)
  end

  bench "successive division" do
    Cldr.Number.Math.number_of_integer_digits3(@int)
  end

  bench "Decimal Divide by 10" do
    Cldr.Number.Math.number_of_integer_digits(@decimal)
  end

  bench "Decimal Divide by 10 (version 2)" do
    Cldr.Number.Math.number_of_integer_digits2(@decimal)
  end

  bench "Decimal floor(log10(number)) + 1 (version 2)" do
    Cldr.Number.Math.number_of_integer_digits2(@decimal)
  end

  bench "Decimal successive division (version 2)" do
    Cldr.Number.Math.number_of_integer_digits3(@decimal)
  end
end