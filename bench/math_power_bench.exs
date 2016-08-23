defmodule Math.Power.Test do
  use Benchfella

  @docp """
  We have two algorithms for implementing `power/2` in the
  Cldr.Number.Math module.  One is the niave looping version
  and the other is the binary method which should be faster.

  But it isn't. At least for these tests.

  Nevertheless they are all 2 orders of magnitude slower than
  the built-in function `:math.pow/2`.
  """

  bench "Builtin :math.pow" do
    :math.pow(12, 10)
  end

  bench "Elixir version of binary method (integer)" do
    Cldr.Number.Math.power(12, 10)
  end

  @twelve Decimal.new(12)
  @five Decimal.new(5)
  @ten Decimal.new(10)


  bench "Iterative loop (integer)" do
    Cldr.Number.Math.power2(12, 10)
  end

  bench "Iterative loop (Decimal)" do
    Cldr.Number.Math.power2(@twelve, @ten)
  end

  bench "Elixir version of binary method (Decimal)" do
    Cldr.Number.Math.power(@twelve, @ten)
  end

  bench "Elixir version of binary method (Decimal with integer n)" do
    Cldr.Number.Math.power(@twelve, 10)
  end

end