defmodule Number.Symbol.Test do
  use ExUnit.Case

  test "that we can get number symbols for a known locale" do
    {:ok, symbols} = Cldr.Number.Symbol.number_symbols_for("en", "latn")
    assert symbols ==
          %Cldr.Number.Symbol{decimal: ".", exponential: "E", group: ",",
                infinity: "∞", list: ";", minus_sign: "-", nan: "NaN",
                per_mille: "‰", percent_sign: "%", plus_sign: "+",
                superscripting_exponent: "×", time_separator: ":"}

  end

  test "that we raise an error if we get minimum digits for an invalid locale" do
    assert_raise Cldr.UnknownLocaleError, "The locale \"zzzzz\" is not known.", fn ->
      Cldr.Number.Format.minimum_grouping_digits_for!("zzzzz")
    end
  end
end