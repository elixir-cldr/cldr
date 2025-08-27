defmodule CldrLanguageTagTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  @tag timeout: :infinity
  property "check that we can parse language tags" do
    check all(language_tag <- GenerateLanguageTag.valid_language_tag(), max_runs: 500) do
      assert {:ok, _} = Cldr.AcceptLanguage.parse(language_tag, TestBackend.Cldr)
    end
  end

  # Tests from RFC5646 examples

  test "Simple language subtags" do
    assert {:ok, _} = Cldr.LanguageTag.parse("de")
    assert {:ok, _} = Cldr.LanguageTag.parse("fr")
    assert {:ok, _} = Cldr.LanguageTag.parse("ja")
    assert {:ok, _} = Cldr.LanguageTag.parse("i-enochian")
  end

  test "Language subtag plus Script subtag" do
    assert {:ok, _} = Cldr.LanguageTag.parse("zh-Hant")
    assert {:ok, _} = Cldr.LanguageTag.parse("zh-Hans")
    assert {:ok, _} = Cldr.LanguageTag.parse("sr-Cyrl")
    assert {:ok, _} = Cldr.LanguageTag.parse("sr-Latn")
  end

  test "Extended language subtags and their primary language subtag counterparts" do
    assert {:ok, _} = Cldr.LanguageTag.parse("zh-cmn-Hans-CN")
    assert {:ok, _} = Cldr.LanguageTag.parse("cmn-Hans-CN")
    assert {:ok, _} = Cldr.LanguageTag.parse("zh-yue-HK")
    assert {:ok, _} = Cldr.LanguageTag.parse("yue-HK")
  end

  test "Language-Script-Region" do
    assert {:ok, _} = Cldr.LanguageTag.parse("zh-Hans-CN")
    assert {:ok, _} = Cldr.LanguageTag.parse("sr-Latn-RS")
  end

  test "Language-Variant" do
    assert {:ok, _} = Cldr.LanguageTag.parse("sl-rozaj")
    assert {:ok, _} = Cldr.LanguageTag.parse("sl-rozaj-biske")
    assert {:ok, _} = Cldr.LanguageTag.parse("sl-nedis")
  end

  test "Language-Region-Variant" do
    assert {:ok, _} = Cldr.LanguageTag.parse("de-CH-1901")
    assert {:ok, _} = Cldr.LanguageTag.parse("sl-IT-nedis")
  end

  test "Language-Script-Region-Variant" do
    assert {:ok, _} = Cldr.LanguageTag.parse("hy-Latn-IT-arevela")
  end

  test "Language-Region" do
    assert {:ok, _} = Cldr.LanguageTag.parse("de-DE")
    assert {:ok, _} = Cldr.LanguageTag.parse("en-US")
    assert {:ok, _} = Cldr.LanguageTag.parse("es-419")
  end

  test "Private use subtags" do
    assert {:ok, _} = Cldr.LanguageTag.parse("de-CH-x-phonebk")
    assert {:ok, _} = Cldr.LanguageTag.parse("az-Arab-x-AZE-derbend")
  end

  test "Private use registry values" do
    assert {:ok, _} = Cldr.LanguageTag.parse("x-whatever")
    assert {:ok, _} = Cldr.LanguageTag.parse("qaa-Qaaa-QM-x-southern")
    assert {:ok, _} = Cldr.LanguageTag.parse("de-Qaaa")
    assert {:ok, _} = Cldr.LanguageTag.parse("sr-Latn-QM")
    assert {:ok, _} = Cldr.LanguageTag.parse("sr-Qaaa-RS")
  end

  test "Tags that use extensions" do
    assert {:ok, _} = Cldr.LanguageTag.parse("en-US-u-islamcal")
    assert {:ok, _} = Cldr.LanguageTag.parse("zh-CN-a-myext-x-private")
    assert {:ok, _} = Cldr.LanguageTag.parse("en-a-myext-b-another")
  end

  test "Some Invalid Tags" do
    assert {:error, _} = Cldr.LanguageTag.parse("de-419-DE ")
    assert {:error, _} = Cldr.LanguageTag.parse("a-DE")

    # Implementation varies from spec.  The implementation won't error
    # on duplicate extensions - it overwrites earlier ones with later
    # ones
    # assert {:error, _} = Cldr.LanguageTag.parse("ar-a-aaa-b-bbb-a-ccc")
  end

  test "with u extension and measurement system" do
    assert Cldr.LanguageTag.parse("en-AU-u-ms-ussystem") ==
             {
               :ok,
               %Cldr.LanguageTag{
                 canonical_locale_name: nil,
                 cldr_locale_name: nil,
                 extensions: %{},
                 gettext_locale_name: nil,
                 language: "en",
                 language_subtags: [],
                 language_variants: [],
                 locale: %{"ms" => "ussystem"},
                 private_use: [],
                 rbnf_locale_name: nil,
                 requested_locale_name: "en-AU-u-ms-ussystem",
                 script: nil,
                 territory: "AU",
                 transform: %{}
               }
             }

    assert Cldr.LanguageTag.parse("en-AU-u-ms-uksystem") ==
             {:ok,
              %Cldr.LanguageTag{
                canonical_locale_name: nil,
                cldr_locale_name: nil,
                extensions: %{},
                gettext_locale_name: nil,
                language: "en",
                language_subtags: [],
                language_variants: [],
                locale: %{"ms" => "uksystem"},
                private_use: [],
                rbnf_locale_name: nil,
                requested_locale_name: "en-AU-u-ms-uksystem",
                script: nil,
                territory: "AU",
                transform: %{}
              }}

    assert Cldr.LanguageTag.parse("en-AU-u-ms-metric") ==
             {:ok,
              %Cldr.LanguageTag{
                canonical_locale_name: nil,
                cldr_locale_name: nil,
                extensions: %{},
                gettext_locale_name: nil,
                language: "en",
                language_subtags: [],
                language_variants: [],
                locale: %{"ms" => "metric"},
                private_use: [],
                rbnf_locale_name: nil,
                requested_locale_name: "en-AU-u-ms-metric",
                script: nil,
                territory: "AU",
                transform: %{}
              }}
  end

  test "with u extension and measurement unit override" do
    import Cldr.LanguageTag.Sigil

    assert ~l"en-u-mu-celsius"
    assert ~l"en-u-mu-fahrenhe"
    assert ~l"en-u-mu-kelvin"

    assert Cldr.validate_locale("en-u-mu-bogus") ==
             {:error,
              {Cldr.LanguageTag.ParseError, "The value \"bogus\" is not valid for the key \"mu\""}}
  end

  test "with u extensions and time zone that requires canonicalisation" do
    import Cldr.LanguageTag.Sigil

    assert {:ok, tag} = Cldr.validate_locale("en-u-tz-est5edt")
    assert "TestBackend.Cldr.Locale.new!(\"en-US-u-tz-usnyc\")" == inspect(tag)
    assert "America/New_York" = tag.locale.timezone
  end
end
