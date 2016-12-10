defmodule Significant.Digits.Test do
  use ExUnit.Case

  test "round 1,239,451 to 3 significant digits and return 1,240,000" do
    assert 1_240_000 == Cldr.Math.round_significant(1239451, 3)
  end

  test "round 12.1257 to 3 significant digits and return 12.1" do
    assert 12.1 == Cldr.Math.round_significant(12.1257, 3)
  end

  test "round .0681 to 3 significant digits and return .0681" do
    assert 0.0681 == Cldr.Math.round_significant(0.0681, 3)
  end

  test "round 5 to 3 significant digits and return 5" do
    assert 5 == Cldr.Math.round_significant(5, 3)
  end

  # From TR35 Section 3.5
  test "round 12345 to 3 significant digits and return 12300" do
    assert 12300 == Cldr.Math.round_significant(12345, 3)
  end

  test "round 0.12345 to 3 significant digits and return 0.123" do
    assert 0.123 == Cldr.Math.round_significant(0.12345, 3)
  end

  test "round 3.14159 to 4 significant digits and return 3.142" do
    assert 3.142 == Cldr.Math.round_significant(3.14159, 4)
  end

  test "round 1.23004 to 4 significant digits and return 1.23" do
    assert 1.23 == Cldr.Math.round_significant(1.23004, 4)
  end

  # Decimal tests
  test "round decimal 12345 to 3 significant digits and return 12300" do
    assert Decimal.reduce(Decimal.new(12300)) ==
      Cldr.Math.round_significant(Decimal.new(12345), 3)
  end

  test "round decimal 0.12345 to 3 significant digits and return 0.123" do
    assert Decimal.new(0.123) ==
      Cldr.Math.round_significant(Decimal.new(0.12345), 3)
  end

  test "round decimal 3.14159 to 4 significant digits and return 3.142" do
    assert Decimal.new(3.142) ==
      Cldr.Math.round_significant(Decimal.new(3.14159), 4)
  end

  test "round decimal 1.23004 to 4 significant digits and return 1.23" do
    assert Decimal.new(1.23) ==
      Cldr.Math.round_significant(Decimal.new(1.23004), 4)
  end

  test "round negative decimal -1.23004 to 4 significant digits and return 1.23" do
    assert Decimal.new(-1.23) ==
      Cldr.Math.round_significant(Decimal.new(-1.23004), 4)
  end
end
