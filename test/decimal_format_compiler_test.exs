defmodule DecimalFormatCompiler.Test do
  use ExUnit.Case, async: false
  alias Cldr.Number.Format
  alias Cldr.Number

  @ltr_marker <<226, 128, 142>>

  Enum.each Format.decimal_format_list, fn (format) ->
    test "Compile decimal format #{Number.String.clean(format)}" do
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
