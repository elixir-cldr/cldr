defmodule Cldr.Substitution.Test do
  use ExUnit.Case

  test "A substitution when there are no parameters" do
    string = "A template with no params"
    template = Cldr.Substitution.parse(string)

    assert Cldr.Substitution.substitute("1", template) == [string]
  end

  test "A substitution with one parameter" do
    assert Cldr.Substitution.substitute("M", [0]) == ["M"]
  end
end
