defmodule Math.Log.Test do
  use ExUnit.Case

  @round 8
  @samples [
    {1,  0},
    {10, 2.30258509299}
  ]

  Enum.each @samples, fn {sample, result} ->
    test "that decimal log(e) is same as bif log(e) for #{inspect sample}" do
      calc = Cldr.Number.Math.log(Decimal.new(unquote(sample))) |> Decimal.round(@round)
      sample = Decimal.new(unquote(result)) |> Decimal.round(@round)
      assert Decimal.cmp(calc, sample) == :eq
    end
  end
end