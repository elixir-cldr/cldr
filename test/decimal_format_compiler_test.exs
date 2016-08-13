defmodule DecimalFormatCompiler.Test do
  use ExUnit.Case
  alias Cldr.Number.Format

  # We need to replace the Unicode "left to right" marker (U+200E) in the test
  # name since otherwise `:erlang.binary_to_atom/2` fails with `argument error`.
  Enum.each Format.decimal_format_list, fn (format) ->
    test "Compile decimal format #{String.replace(format, <<226, 128, 142>>, "<ltr>")}" do
      {code, _result} = Format.Compiler.parse(unquote(format))
      assert code == :ok
    end
  end
end

    