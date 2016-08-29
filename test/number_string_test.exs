defmodule Number.String.Test do
  use ExUnit.Case

  test "that the regexp for latin1 is correct" do
    assert Cldr.Number.String.latin1 == ~r/([\x00-\x7F])/
  end

  test "that the regexp for not latin1 is correct" do
    assert Cldr.Number.String.not_latin1 == ~r/([^\x00-\x7F])/
  end

  test "that we transliterate a non latin1 character" do
    s = Cldr.Number.String.hex_string("¤")
    assert s == "\\x164"
  end
end