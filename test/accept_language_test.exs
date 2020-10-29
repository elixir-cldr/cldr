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

  test "Confirm that gettext-defined locales are not used if not registered in backend" do
    assert Cldr.AcceptLanguage.best_match(
             "oc,en-US;q=0.9,en;q=0.8,fr-FR;q=0.7,fr;q=0.6",
             WithNoGettextBackend.Cldr
           ) ==
             {:ok,
              %Cldr.LanguageTag{
                backend: WithNoGettextBackend.Cldr,
                canonical_locale_name: "en-Latn-US",
                cldr_locale_name: "en",
                extensions: %{},
                gettext_locale_name: nil,
                language: "en",
                language_subtags: [],
                language_variant: nil,
                locale: %{},
                private_use: [],
                rbnf_locale_name: "en",
                requested_locale_name: "en-US",
                script: "Latn",
                territory: :US,
                transform: %{}
              }}
  end

  test "Confirm that gettext-defined locales can be used" do
    assert Cldr.AcceptLanguage.best_match(
             "oc,en-US;q=0.9,en;q=0.8,fr-FR;q=0.7,fr;q=0.6",
             WithGettextBackend.Cldr
           ) ==
             {:ok,
              %Cldr.LanguageTag{
                backend: WithGettextBackend.Cldr,
                canonical_locale_name: "oc-Latn-FR",
                cldr_locale_name: nil,
                extensions: %{},
                gettext_locale_name: "oc",
                language: "oc",
                language_subtags: [],
                language_variant: nil,
                locale: %{},
                private_use: [],
                rbnf_locale_name: nil,
                requested_locale_name: "oc",
                script: "Latn",
                territory: :FR,
                transform: %{}
              }}
  end
end
