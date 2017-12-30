defmodule Math.Test do
  use ExUnit.Case
  alias Cldr.Math
  alias Cldr.Digits

  test "integer number of digits for a decimal integer" do
    decimal = Decimal.new(1234)
    assert Digits.number_of_integer_digits(decimal) == 4
  end

  test "integer number of digits for a decimal fixnum" do
    decimal = Decimal.new(1234.5678)
    assert Digits.number_of_integer_digits(decimal) == 4
  end

  test "round significant digits for a decimal integer" do
    decimal = Decimal.new(1234)
    assert Math.round_significant(decimal, 2) == Decimal.reduce(Decimal.new(1200))
  end

  test "round significant digits for a decimal" do
    decimal = Decimal.new(1234.45)
    assert Math.round_significant(decimal, 4) == Decimal.reduce(Decimal.new(1234))
  end

  test "round significant digits for a decimal to 5 digits" do
    decimal = Decimal.new(1234.45)
    assert Math.round_significant(decimal, 5) == Decimal.reduce(Decimal.new(1234.5))
  end

  test "power of 0 == 1" do
    assert Math.power(Decimal.new(123), 0) == Decimal.new(1)
  end

  test "power of decimal where n > 1" do
    assert Math.power(Decimal.new(12), 3) == Decimal.new(1728)
  end

  test "power of decimal where n < 0" do
    assert Math.power(Decimal.new(4), -2) == Decimal.new(0.0625)
  end

  test "power of decimal where number < 0" do
    assert Math.power(Decimal.new(-4), 2) == Decimal.new(16)
  end

  test "power of integer when n = 0" do
    assert Math.power(3, 0) === 1
  end

  test "power of float when n == 0" do
    assert Math.power(3.0, 0) === 1.0
  end

  test "power of integer when n < 1" do
    assert Math.power(4, -2) == 0.0625
  end
end
