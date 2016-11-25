defmodule Cldr.Rbnf.Compiler.Test do
  use ExUnit.Case

  @tag timeout: 12000000
  test "that rbnf rules can tokenize" do
    Enum.each Cldr.Rbnf.all_rule_definitions, fn (rule) ->
      IO.puts "Rule definition: #{inspect rule}"
      assert {:ok, _tokens} = Cldr.Rbnf.Rule.tokenize(rule)
    end
  end
end
