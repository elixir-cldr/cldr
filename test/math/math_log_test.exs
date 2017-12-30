defmodule Math.Log.Test do
  use ExUnit.Case

  @round 2
  @samples [
    {1, 0},
    {10, 2.30258509299},
    {1.23004, 0.20704668918075508}
  ]

  Enum.each(@samples, fn {sample, result} ->
    test "that decimal log(e) is correct for #{inspect(sample)}" do
      calc = Cldr.Math.log(Decimal.new(unquote(sample))) |> Decimal.round(@round)
      sample = Decimal.new(unquote(result)) |> Decimal.round(@round)
      assert Decimal.cmp(calc, sample) == :eq
    end
  end)

  random =
    for _i <- 1..500 do
      :rand.uniform(10000) / 10
    end
    |> Enum.uniq()

  @diff 0.005
  Enum.each(random, fn x ->
    test "that decimal log(e) is more or less the same as bif log(e) for #{inspect(x)}" do
      assert :math.log(unquote(x)) - Cldr.Math.to_float(Cldr.Math.log(Decimal.new(unquote(x)))) <
               @diff
    end
  end)

  # Testing large decimals that are beyond the precision of a float
  test "log Decimal.new(\"1.33333333333333333333333333333333\")" do
    assert Decimal.cmp(
             Cldr.Math.log(Decimal.new("1.33333333333333333333333333333333")),
             Decimal.new("0.2876820724291554672132526174")
           ) == :eq
  end
end
