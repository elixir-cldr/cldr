defmodule Number.Format.Test do
  use ExUnit.Case
  alias Cldr.Number.Format

  Enum.each Cldr.Test.Number.Format.test_data(), fn {value, result, args} ->
    test "formatted #{inspect value} == #{inspect result} with args: #{inspect args}" do
      assert {:ok, unquote(result)} = Cldr.Number.to_string(unquote(value), unquote(args))
    end
  end

  test "literal-only format returns the literal" do
    assert {:ok, "xxx"} = Cldr.Number.to_string(1234, format: "xxx")
  end

  test "a currency format with no currency returns an error" do
    assert {:error, _message} = Cldr.Number.to_string(1234, format: :currency)
  end

  test "minimum_grouping digits delegates to Cldr.Number.Symbol" do
    assert Format.minimum_grouping_digits_for("en") == 1
  end

  test "that there are decimal formats for a locale" do
    assert Map.keys(Cldr.Number.Format.all_formats_for("en")) == [:latn]
  end

  test "that there is an exception if we get formats for an unknown locale" do
    assert_raise Cldr.UnknownLocaleError, ~r/The locale .* is not known/, fn ->
      Format.formats_for!("zzz")
    end
  end

  test "that there is an exception if we get formats for an number system" do
    assert_raise Cldr.UnknownNumberSystemError, ~r/The number system \"zulu\" is not known/, fn ->
      Format.formats_for!("en", "zulu")
    end
  end

  test "that an rbnf format request fails if the locale doesn't define the ruleset" do
    assert Cldr.Number.to_string(123, format: :spellout_ordinal_verbose, locale: "zh") ==
      {:error, {Cldr.NoRbnf, "Locale \"zh\" does not define an rbnf ruleset :spellout_ordinal_verbose"}}
  end

  test "that we get default formats_for" do
    assert Format.formats_for!.__struct__ == Cldr.Number.Format
  end

  test "that when there is no format defined for a number system we get an error return" do
    assert Cldr.Number.to_string(1234, locale: "he", number_system: :hebr) ==
      {:error, {Cldr.UnknownFormatError,
      "The locale \"he\" with number system :hebr does not define a format :standard."}}
  end

  test "that when there is no format defined for a number system raises" do
    assert_raise Cldr.UnknownFormatError, ~r/The locale .* does not define/, fn ->
      Cldr.Number.to_string!(1234, locale: "he", number_system: :hebr)
    end
  end
end
