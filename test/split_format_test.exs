defmodule Split.Format.Test do
  use ExUnit.Case

  Enum.each Cldr.Test.Number.Split.Format.test_data(), fn {format, result} ->
    test "that a format splits correctly for #{inspect format}" do
      regex = Cldr.Number.Format.Compiler.number_match_regex
      assert Regex.named_captures(regex, unquote(format)) == unquote(Macro.escape(result))
    end
  end
end
