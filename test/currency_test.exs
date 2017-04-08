defmodule Cldr.Currency.Test do
  use ExUnit.Case

  test "that we can confirm known currencies" do
    assert Cldr.Currency.known_currency?("USD") == true
  end

  test "that we reject unknown currencies" do
    assert Cldr.Currency.known_currency?("ABCD") == false
  end

  test "that normalizing a binary currency code returns an atom" do
    assert Cldr.Currency.normalize_currency_code("USD") == :USD
  end

  test "that normalizing an atom currency code returns an atom" do
    assert Cldr.Currency.normalize_currency_code(:USD) == :USD
  end

  test "that normalizing a lower case atom currency code returns an atom" do
    assert Cldr.Currency.normalize_currency_code(:usd) == :USD
  end

  test "that normalizing a currency code returns an error if the code is invalid" do
    assert Cldr.Currency.normalize_currency_code("ABCD") == {:error, {Cldr.UnknownCurrencyError, "Currency \"ABCD\" is not known"}}
  end

  test "that invalid currency code raises in bang version of normalize_currency for a binary" do
    assert_raise Cldr.UnknownCurrencyError, "Currency \"ABCD\" is not known", fn ->
      Cldr.Currency.normalize_currency_code!("ABCD")
    end
  end
end