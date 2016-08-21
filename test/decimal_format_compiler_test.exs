defmodule DecimalFormatCompiler.Test do
  use ExUnit.Case
  alias Cldr.Number.Format
  
  @ltr_marker <<226, 128, 142>>

  # We need to replace the Unicode "left to right" marker (U+200E, UTF-16 8206) in the test
  # name since otherwise `:erlang.binary_to_atom/2` fails with `argument error`.
  Enum.each Format.decimal_format_list, fn (format) ->
    test "Compile decimal format #{String.replace(format, @ltr_marker, "<ltr>")}" do
      assert {:ok, _result} = Format.Compiler.parse(unquote(format))
    end
  end
  
  test "compile fails on bad format" do
    assert {:error, _result} = Format.Compiler.parse("xxx")
  end
  
  test "compile fails on empty format" do
    assert {:error, _result} = Format.Compiler.parse("")
  end
  
  test "compile fails on nil format" do
    assert {:error, _result} = Format.Compiler.parse(nil)
  end
end

    