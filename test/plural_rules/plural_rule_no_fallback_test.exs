defmodule Cldr.PluralRuleNoFallbackTest do
  use ExUnit.Case, async: true

  test "Pluralizing with a locale with no fallback plural rules" do
    assert {:ok, NoFallback.Cldr.Locale.new!("es-US")} ==
      Cldr.Locale.canonical_language_tag("es-US", NoFallback.Cldr)
  end

  test "No plural rules for es-US (and no fallback locale configured)" do
    {:ok, locale} = Cldr.Locale.canonical_language_tag("es-US", NoFallback.Cldr)

    assert NoFallback.Cldr.Number.Cardinal.plural_rule(42, locale) ==
      {:error,
       {Cldr.UnknownPluralRules,
        "No Cardinal plural rules available for NoFallback.Cldr.Locale.new!(\"es-US\")"}}
  end

end