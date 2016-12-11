defmodule Number.Format.Test do
  use Benchfella

  bench "Format compiled number {en, latn}" do
    Cldr.Number.to_string 12345.6789
  end

end
