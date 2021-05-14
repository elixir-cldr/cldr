defmodule Cldr.IdentityPluralRule.Test do
  use ExUnit.Case

  test "integer identity plural selection" do
    substitutions = %{42 => "This is 42", :other => "This is not"}
    assert TestBackend.Cldr.Number.Cardinal.pluralize(42, "en", substitutions) == "This is 42"
    assert TestBackend.Cldr.Number.Ordinal.pluralize(42, "en", substitutions) == "This is 42"
  end

  test "float identity pluralization" do
    substitutions = %{42 => "This is 42", :other => "This is not"}
    assert TestBackend.Cldr.Number.Cardinal.pluralize(42.0, "en", substitutions) == "This is 42"
  end

end