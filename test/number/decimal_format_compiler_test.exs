defmodule DecimalFormatCompiler.Test do
  use ExUnit.Case, async: false
  alias Cldr.Number.Format

  Enum.each Format.decimal_format_list, fn (format) ->
    test "Compile decimal format #{inspect format}" do
      assert {:ok, _result} = Format.Compiler.parse(unquote(format))
    end
  end

  test "compile fails on empty format" do
    assert {:error, _result} = Format.Compiler.parse("")
  end

  test "compile fails on nil format" do
    assert {:error, _result} = Format.Compiler.parse(nil)
  end

  test "that we can parse a token list" do
    {:ok, tokens, _} = Format.Compiler.tokenize("#")
    assert {:ok, _parse_tree} = Format.Compiler.parse(tokens)
  end
end
