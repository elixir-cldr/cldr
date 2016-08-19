defmodule Number.Format.Test do
  use Benchfella
  
  bench "Format uncompiled number" do
    Cldr.Number.to_string 12345.6789, format: "##"
  end
  
  bench "Format compiled number" do
    Cldr.Number.to_string 12345.6789, format: "#"
  end
end
