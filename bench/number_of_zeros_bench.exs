defmodule Number.Zeros.Test do
  use Benchfella

  @zeros Regex.compile!("(?<zeros>0+)")
  @format "¤000T"

  bench "Number via regex" do
    Regex.named_captures(@zeros, @format)["zeros"] |> String.length
  end

  bench "Number via charlist" do
    @format
    |> String.to_char_list
    |> Enum.reduce(0, fn c, acc ->
      if c == ?0 do
        acc + 1
      else
        acc
      end
    end)
  end

end
