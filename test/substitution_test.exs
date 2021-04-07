defmodule Cldr.Substitution.Test do
  use ExUnit.Case

  test "A substitution when there are no parameters" do
    string = "A template with no params"
    template = Cldr.Substitution.parse(string)

    assert Cldr.Substitution.substitute("1", template) == [string]
  end
end

