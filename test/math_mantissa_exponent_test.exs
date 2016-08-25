defmodule Math.Mantissa.Exponent.Test do
  use ExUnit.Case

  @test [0.00345, 0.0123, 0.1, -0.1, 0.99, 0, 1, 5, 10, 17, 47, 107, 507, 1000, 1007, 2345]

  Enum.each @test, fn value ->
    test "Validate that mantinssa * 10**exponent == original number for #{value}" do
      {mantissa, exponent} = Cldr.Number.Math.mantissa_exponent(Decimal.new(unquote(Macro.escape(value))))
      calc = Decimal.mult(mantissa, Decimal.new(Cldr.Number.Math.power(10, exponent))) |> Decimal.reduce
      assert Decimal.to_string(calc, :normal) == Decimal.to_string(Decimal.new(unquote(Macro.escape(value))), :normal)
    end
  end
end