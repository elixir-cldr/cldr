defmodule Cldr.Locale.Fallback.Test do
  use ExUnit.Case, async: true

  test "fallback chain calculation" do
    assert {:ok, [:en, :und]} =  Cldr.Locale.fallback_locale_names(:"en-US")
    assert {:ok, [:"hi-Latn", :"en-IN", :"en-001", :en, :und]} = Cldr.Locale.fallback_locale_names(:"hi-Latn")
    assert {:ok, [:"en-AU", :"en-001", :en, :und]} = Cldr.Locale.fallback_locale_names(:"en-AU")
    assert {:ok, [:nb, :no, :und]} = Cldr.Locale.fallback_locale_names(:nb)

  end

end