defmodule Math.Mantissa.Exponent.Test do
  use ExUnit.Case

  @test [0.00345, 0.0123, 0.1, -0.1, -1, 0.3, 0.99, 0, 0.0, 1, 5, 10, 17,
    47, 107, 507, 1000, 1007, 2345, 40000]

  @ten Decimal.new(10)

  Enum.each @test, fn value ->
    test "Validate that mantinssa * 10**exponent == original number for #{value}" do
      test_value = Decimal.new(unquote(Macro.escape(value)))

      # Calculate the mantissa and exponent
      {mantissa, exponent} = Cldr.Number.Math.mantissa_exponent(test_value)

      # And then recalculate the decimal value
      calculated_value = @ten
      |> Cldr.Number.Math.power(exponent)
      |> Decimal.mult(mantissa)
      |> Decimal.reduce

      # And confirm we made the round trip
      assert Decimal.cmp(calculated_value, test_value) == :eq
    end
  end
end