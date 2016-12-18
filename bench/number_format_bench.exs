defmodule Number.Format.Test do
  use Benchfella
  Code.require_file "test/support/number_format_test_data.exs"

  bench "Format compiled standard format: integer" do
    Cldr.Number.to_string 12345
  end

  bench "Format Integer.to_string" do
    Integer.to_string 12345
  end

  bench "Format compiled number standard format: float" do
    Cldr.Number.to_string 12345.6789
  end

  bench "Format uncompiled format: float" do
    Cldr.Number.to_string 12345.6789, format: "#,##0.####"
  end

  bench "Format compiled currency {en, latn}" do
    Cldr.Number.to_string 12345.6789, format: "#,##0.00 ¤", currency: :AUD
  end

  bench "Format compiled number {fr, latn}: float" do
    Cldr.Number.to_string 12345.6789, locale: "fr"
  end

  bench "Format compiled number {fr, latn}: integer" do
    Cldr.Number.to_string 12345, locale: "fr"
  end

  @decimal Decimal.new(12345.6789)
  bench "Decimal.to_string" do
    Decimal.to_string(@decimal, :normal)
  end

  bench "Significant digits format" do
    Cldr.Number.to_string 12345.6789, format: "@@###"
  end

  # bench "Format the test data" do
  #   Enum.each Cldr.Test.Number.Format.test_data(), fn {value, _result, args} ->
  #     Cldr.Number.to_string(value, args)
  #   end
  # end
end
