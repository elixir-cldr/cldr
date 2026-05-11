defmodule Cldr.AcceptLanguageTest do
  use ExUnit.Case, async: true

  doctest Cldr.AcceptLanguage

  test "Confirm that order is unchanged for tags with the same quality" do
    tags = [{1.0, "en-us"}, {1.0, "en"}, {1.0, "es-es"}, {1.0, "es"}]

    assert Cldr.AcceptLanguage.sort_by_quality(tags) == tags
  end

  test "Confirm that order is unchanged for tags with the same quality part deux" do
    before_tags = [{1.0, "en-us"}, {1.0, "en"}, {2.0, "fr"}, {1.0, "es-es"}, {1.0, "es"}]
    after_tags = [{2.0, "fr"}, {1.0, "en-us"}, {1.0, "en"}, {1.0, "es-es"}, {1.0, "es"}]
    assert Cldr.AcceptLanguage.sort_by_quality(before_tags) == after_tags
  end

  describe "regression: gettext-derived supported list with no bare language fallback (#263)" do
    # Reproduces the user's setup in
    # https://github.com/elixir-cldr/cldr/issues/263 — a Gettext backend with
    # regional locales only (e.g. "en_US", "en_GB", "en_CA") and no bare
    # "en". Pre-2.47.4 the matcher returned `nil` for inputs like "es-US"
    # and "zh-Hant" and collapsed "en-US" to bare "en" even though "en"
    # was not in the list. Tests use Cldr.Locale.Match.best_match/2
    # directly because that is the function Cldr.AcceptLanguage.best_match/2
    # uses internally for both cldr_locale_name and gettext_locale_name
    # resolution.

    @gettext_locales ~w(ar bg_BG cs_CZ da_DK de_DE el_GR en_CA en_GB en_US
                        es_ES fi_FI fr_CA fr_FR hr_HR hu_HU id_ID it_IT
                        ja_JP lt_LT ms_MY nb_NO nl_NL pl_PL pt pt_BR pt_PT
                        ro_RO ru_RU sl_SI sv_SE th_TH uk_UA vi_VN zh_CN zh_HK)

    test "exact regional match wins over language collapse" do
      assert {:ok, "en_US", 0} =
               Cldr.Locale.Match.best_match("en-US",
                 supported: @gettext_locales,
                 backend: TestBackend.Cldr
               )
    end

    test "bare language with no exact supported entry resolves to the paradigm regional" do
      # "en" maximises to "en-Latn-US"; en_US is therefore the closest match.
      assert {:ok, "en_US", 0} =
               Cldr.Locale.Match.best_match("en",
                 supported: @gettext_locales,
                 backend: TestBackend.Cldr
               )
    end

    test "regional locale not in supported list falls back to a configured regional, not nil" do
      # "es-US" used to return nil; should now resolve to a Spanish regional.
      assert {:ok, "es_ES", _distance} =
               Cldr.Locale.Match.best_match("es-US",
                 supported: @gettext_locales,
                 backend: TestBackend.Cldr
               )
    end

    test "regional locale outside paradigm group falls back to the nearest configured regional" do
      # "en-AU" used to collapse to bare "en"; per CLDR it should match
      # "en_GB" (en-AU shares the en-001 region group with en-GB).
      assert {:ok, "en_GB", _distance} =
               Cldr.Locale.Match.best_match("en-AU",
                 supported: @gettext_locales,
                 backend: TestBackend.Cldr
               )
    end

    test "script-only tag resolves to a regional with matching script" do
      # "zh-Hans" maximises to zh-Hans-CN → matches zh_CN.
      assert {:ok, "zh_CN", 0} =
               Cldr.Locale.Match.best_match("zh-Hans",
                 supported: @gettext_locales,
                 backend: TestBackend.Cldr
               )
    end

    test "Traditional Chinese tag falls back to zh_HK rather than nil" do
      # "zh-Hant" used to return nil; should now match zh_HK
      # (Traditional script region).
      assert {:ok, "zh_HK", _distance} =
               Cldr.Locale.Match.best_match("zh-Hant",
                 supported: @gettext_locales,
                 backend: TestBackend.Cldr
               )
    end
  end
end
