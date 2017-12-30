defmodule Math.Sqrt.Test do
  use ExUnit.Case

  # Each of these is validated to return the original number
  # when squared
  @roots [
    {9, 3},
    {11, "3.316624790355399849114932737"},
    {465, "21.56385865284782467473394180"},
    {11.321, "3.364669374544845230862071572"},
    {0.1, "0.3162277660168379331998893544"}
  ]

  Enum.each(@roots, fn {value, root} ->
    test "square root of #{inspect(value)} should be #{root}" do
      assert Decimal.cmp(Cldr.Math.sqrt(Decimal.new(unquote(value))), Decimal.new(unquote(root))) ==
               :eq
    end
  end)

  test "sqrt of a negative number raises" do
    assert_raise ArgumentError, ~r/bad argument in arithmetic expression/, fn ->
      Cldr.Math.sqrt(Decimal.new(-5))
    end
  end
end
