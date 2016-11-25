defmodule Cldr.Rbnf.Compiler.Test do
  use ExUnit.Case

  @tag timeout: 12000000
  test "that rbnf rules can tokenize" do
    Enum.each Cldr.Rbnf.all_rule_definitions, fn (rule) ->
      assert {:ok, _tokens, _} = Cldr.Rbnf.Rule.tokenize(rule)
    end
  end
end
