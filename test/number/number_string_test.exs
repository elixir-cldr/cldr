defmodule Number.String.Test do
  use ExUnit.Case
  alias Cldr.Number

  test "that the regexp for latin1 is correct" do
    assert Number.String.latin1 == ~r/([\x00-\x7F])/
  end

  test "that the regexp for not latin1 is correct" do
    assert Number.String.not_latin1 == ~r/([^\x00-\x7F])/
  end

  test "that we transliterate a non latin1 character" do
    s = Number.String.hex_string("¤")
    assert s == "\\x164"
  end

  test "that padding a string with a negative count returns the string" do
    assert Number.String.pad_leading_zeros("1234", -5) == "1234"
  end
end