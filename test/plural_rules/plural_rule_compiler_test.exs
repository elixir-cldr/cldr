defmodule Plural.Rule.Compiler.Test do
  use ExUnit.Case

  test "that a set of tokens can be compiled" do
    plural_rule = "i = 0 or n = 1 @integer 0, 1 @decimal 0.0~1.0, 0.00~0.04"
    {:ok, tokens, _} = Cldr.Number.PluralRule.Compiler.tokenize(plural_rule)
    assert {:ok, _} = Cldr.Number.PluralRule.Compiler.parse(tokens)
  end
end