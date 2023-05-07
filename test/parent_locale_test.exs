defmodule Cldr.Locale.Parent.Test do
  use ExUnit.Case, async: true

  test "parent locales" do
    assert Cldr.Locale.parent("und") ==
             {:error, {Cldr.NoParentError, "The locale :und has no parent locale"}}

    assert Cldr.Locale.parent("en-AU") == TestBackend.Cldr.Locale.new("en-001")
  end

  test "parent is :und" do
    assert Cldr.Locale.parent("en-US") == TestBackend.Cldr.Locale.new("und")
    assert Cldr.Locale.parent("ca") == TestBackend.Cldr.Locale.new("und")
    assert Cldr.Locale.parent("en-US-u-va-POSIX") == TestBackend.Cldr.Locale.new("und-u-va-posix")
  end

  test "parent locale of en-001" do
    assert Cldr.Locale.parent("en-001") == TestBackend.Cldr.Locale.new("en")
  end

  test "parent locale of ca-ES-VALENCIA" do
    assert Cldr.Locale.parent("ca-ES-VALENCIA") == TestBackend.Cldr.Locale.new("ca")
  end

  test "parent locales from Cldr.Locale.parent_locales/0" do
    assert Cldr.Locale.parent("nb") == TestBackend.Cldr.Locale.new("no")
  end
end
