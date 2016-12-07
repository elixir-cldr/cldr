defmodule Cldr.List.Test do
  use ExUnit.Case
  alias Cldr.List

  test "that three element lists format correctly" do
    assert List.to_string([1,2,3]) == "1, 2, and 3"
  end

  test "that two element lists format correctly" do
    assert List.to_string([1,2]) == "1 and 2"
  end

  test "that one element lists format correctly" do
    assert List.to_string([1]) == "1"
  end

  test "that empty lists format correctly" do
    assert List.to_string([]) == ""
  end

  test "a bad format returns an error" do
    assert List.to_string([1,2,3], format: :jabberwocky) == {:error,
      {Cldr.UnknownFormatError, "The list format style :jabberwocky is not known."}}
  end

  test "a bad locale returns an error" do
    assert List.to_string([1,2,3], locale: "nothing") == {:error,
      {Cldr.UnknownLocaleError, "The locale \"nothing\" is not known."}}
  end

  test "that an invalid format raises" do
    assert_raise Cldr.UnknownFormatError, fn ->
      List.to_string!([1,2,3], format: :jabberwocky)
    end
  end
end