defmodule Cldr.Locale.Parent.Test do
  use ExUnit.Case, async: true

  test "parent locales" do
    assert Cldr.Locale.parent("en-US") ==
             {:error, {Cldr.NoParentError, "The locale \"en-US\" has no parent locale"}}

    assert Cldr.Locale.parent("en-001") == TestBackend.Cldr.Locale.new("en")
    assert Cldr.Locale.parent("en-AU") == TestBackend.Cldr.Locale.new("en-001")

    # FIXME
    # assert Cldr.Locale.parent("en-US-u-va-POSIX") == TestBackend.Cldr.Locale.new("en-u-va-posix")
    # assert Cldr.Locale.parent("ca-ES-VALENCIA") == TestBackend.Cldr.Locale.new("ca")

    assert Cldr.Locale.parent("ca") == TestBackend.Cldr.Locale.new("en-001")
  end

  test "parent locales from Cldr.Locale.parent_locales/0" do
    assert Cldr.Locale.parent("nb") == TestBackend.Cldr.Locale.new("no")
  end
end
