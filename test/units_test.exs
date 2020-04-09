defmodule CldrUnitsTest do
  use ExUnit.Case, async: true

  test "parse unit expression with power" do
    assert Cldr.Unit.Parser.parse("ft2m^3 * 43560") == ["*", ["^", "ft2m", 3], 43560]
  end

  test "parse unit expression" do
    assert Cldr.Unit.Parser.parse("ft2m^3 * 43560 / 3676 * 467") ==
             ["*", ["^", "ft2m", 3], ["/", 43560, ["*", 3676, 467]]]
  end
end
