defmodule Number.Format.Test do
  use Benchfella

  bench "Format uncompiled number" do
    Cldr.Number.to_string 12345.6789, format: "#,##0.####"
  end

  bench "Format compiled number {en, latn}" do
    Cldr.Number.to_string 12345.6789, format: "#,##0.###"
  end

  bench "Format compiled currency {en, latn}" do
    Cldr.Number.to_string 12345.6789, format: "#,##0.00 ¤", currency: :AUD
  end

  bench "Format compiled number {fr, latn}" do
    Cldr.Number.to_string 12345.6789, format: "#,##0.###", locale: "fr"
  end

  @decimal Decimal.new(12345.6789)
  bench "Decimal.to_string" do
    Decimal.to_string(@decimal, :normal)
  end

  bench "Significant digits format" do
    Cldr.Number.to_string 12345.6789, format: "@@###"
  end
end
