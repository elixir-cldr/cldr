defmodule Cldr.CanonicalLocaleTest do
  use ExUnit.Case, async: true

  # Explicit locales: 26..41
  # From aliases 45..777
  # Decanonicalized 781..838
  # With irrelevants 842..1647

  for [line, from, to] <- Cldr.CanonicalLocaleGenerator.data() do
    test "##{line} Locale #{inspect(from)} becomes #{inspect(to)}" do
      assert Cldr.Locale.new!(unquote(from), TestBackend.Cldr).canonical_locale_name ==
               unquote(to)
    end
  end

  test "Compound calendar names" do
    assert {:ok, language_tag} = Cldr.Locale.new("en-u-ca-islamic-rgsa", TestBackend.Cldr)
    assert language_tag.locale.calendar == :islamic_rgsa

    assert {:ok, language_tag} = Cldr.Locale.new("en-u-ca-islamic-civil", TestBackend.Cldr)
    assert language_tag.locale.calendar == :islamic_civil

    assert {:ok, language_tag} = Cldr.Locale.new("en-u-ca-islamic-tbla", TestBackend.Cldr)
    assert language_tag.locale.calendar == :islamic_tbla

    assert {:ok, language_tag} = Cldr.Locale.new("en-u-ca-islamic-umalqura", TestBackend.Cldr)
    assert language_tag.locale.calendar == :islamic_umalqura
  end
end
