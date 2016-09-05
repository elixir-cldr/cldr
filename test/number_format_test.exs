defmodule Number.Format.Test do
  use ExUnit.Case
  import Cldr.Test.Number.Format, only: [sanitize: 1]
  alias Cldr.Number.Format

  Enum.each Cldr.Test.Number.Format.test_data(), fn {value, result, args} ->
    test "formatted #{inspect value} == #{inspect sanitize(result)} with args: #{inspect args}" do
      assert Cldr.Number.to_string(unquote(value), unquote(args)) == unquote(result)
    end
  end

  test "invalid format returns an error" do
    assert {:error, _message} = Cldr.Number.to_string(1234, format: "xxx")
  end

  test "a currency format with no currency returns an error" do
    assert {:error, _message} = Cldr.Number.to_string(1234, format: :currency)
  end

  test "minimum_grouping digits delegates to Cldr.Number.Symbol" do
    assert Format.minimum_grouping_digits_for("en") == 1
  end

  test "that we have decimal formats as a map" do
    assert is_map(Format.decimal_formats())
  end

  test "that there are many decimal formats" do
    assert Enum.count(Format.decimal_formats()) > 10
  end

  test "that there are decimal formats for a locale" do
    assert Map.keys(Format.decimal_formats_for("en")) == [:latn]
  end

  test "that there is an exception if we get formats for an unknown locale" do
    assert_raise Cldr.UnknownLocaleError, ~r/The locale \"zzz\" is not known./, fn ->
      Format.decimal_formats_for("zzz")
    end
  end

  test "that there is an exception if we get formats for an unknown locale and number system" do
    assert_raise Cldr.UnknownLocaleError, ~r/Unknown locale.*number system/, fn ->
      Format.decimal_formats_for("zzz", "zulu")
    end
  end

  test "that we get default formats_for" do
    assert Format.formats_for.__struct__ == Cldr.Number.Format
  end

  test "that when there is no format defined for a number system we get an error return" do
    assert Cldr.Number.to_string(1234, locale: "he", number_system: "hebr") ==
    {:error,
      "The locale \"he\" with number system \"hebr\" does not define a format :standard."}
  end
end
