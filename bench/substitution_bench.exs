defmodule Number.Substitute.Test do
  use Benchfella

  @pattern_string "{0} is also with {1}"
  @compiled Cldr.Substitution.parse(@pattern_string)

  @first "a"
  @last "b"

  bench "Format via list" do
    Cldr.Substitution.substitute([@first, @last], @compiled)
    |> :erlang.iolist_to_binary
  end

  bench "Format via string" do
    @pattern_string
    |> String.replace("{0}", Kernel.to_string(@first))
    |> String.replace("{1}", Kernel.to_string(@last))
  end

end