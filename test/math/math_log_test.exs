defmodule Math.Log.Test do
  use ExUnit.Case

  @round 8
  @samples [
    {1,  0},
    {10, 2.30258509299},
    {1.23004, 0.20704668918075508}
  ]

  Enum.each @samples, fn {sample, result} ->
    test "that decimal log(e) is same as bif log(e) for #{inspect sample}" do
      calc = Cldr.Math.log(Decimal.new(unquote(sample))) |> Decimal.round(@round)
      sample = Decimal.new(unquote(result)) |> Decimal.round(@round)
      assert Decimal.cmp(calc, sample) == :eq
    end
  end

  # Testing large decimals that are beyond the precision of a float
  test "log Decimal.new(\"1.33333333333333333333333333333333\")" do
    assert Decimal.cmp(
            Cldr.Math.log(Decimal.new("1.33333333333333333333333333333333")),
            Decimal.new("0.2876820724291554672132526174")) == :eq
  end
end
