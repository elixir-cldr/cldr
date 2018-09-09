defmodule LanguageTag.Parse.Test do
  use Benchfella

  bench "ABNF method" do
    Cldr.Rfc5646.parse "en-SDF-123-1ABC-u-ddd-df-aaa-xx-t-dd-asd-s-ss-fff-x-fff"
  end

  bench "Nimble_parsec method" do
    Cldr.Rfc5646a.parse "en-SDF-123-1ABC-u-ddd-df-aaa-xx-t-dd-asd-s-ss-fff-x-fff"
  end
end