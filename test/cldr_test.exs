defmodule Cldr.Test do
  use ExUnit.Case

  test "that the cldr home directory is correct" do
    assert String.ends_with?(Cldr.Config.cldr_home(), "/cldr") == true
  end

  test "that the cldr source data directory is correct" do
    assert String.ends_with?(Cldr.Config.source_data_dir(), "/priv/cldr") == true
  end

  test "that the client data directory is correct" do
    assert String.ends_with?(Cldr.Config.client_data_dir(), "/_build/test/lib/ex_cldr/priv/cldr") ==
             true
  end

  test "that the cldr data directory is correct" do
    assert String.ends_with?(Cldr.Config.cldr_data_dir(), "/_build/test/lib/ex_cldr/priv/cldr") ==
             true
  end

  test "that the download data directory is correct" do
    assert String.ends_with?(Cldr.Config.download_data_dir(), "/data") == true
  end

  test "that we have the correct modules (keys) for the json consolidation" do
    assert Cldr.Config.required_modules() ==
             [
               "number_formats",
               "list_formats",
               "currencies",
               "number_systems",
               "number_symbols",
               "minimum_grouping_digits",
               "rbnf",
               "units",
               "date_fields",
               "dates",
               "territories",
               "languages"
             ]
  end

  test "default locale" do
    assert Cldr.default_locale() ==
             %Cldr.LanguageTag{
               canonical_locale_name: "en-Latn-001",
               cldr_locale_name: "en-001",
               language_subtags: [],
               extensions: %{},
               gettext_locale_name: nil,
               language: "en",
               locale: %{},
               private_use: [],
               rbnf_locale_name: "en",
               requested_locale_name: "en-001",
               script: "Latn",
               territory: "001",
               transform: %{},
               language_variant: nil
             }
  end

  test "locale name does not exist" do
    refute Cldr.available_locale_name?("jabberwocky")
  end

  test "that we have the right number of rbnf locales" do
    assert Cldr.known_rbnf_locale_names() ==
             [
               "af",
               "ak",
               "am",
               "ar",
               "az",
               "be",
               "bg",
               "bs",
               "ca",
               "ccp",
               "chr",
               "cs",
               "cy",
               "da",
               "de",
               "de-CH",
               "ee",
               "el",
               "en",
               "en-IN",
               "eo",
               "es",
               "es-419",
               "et",
               "fa",
               "fa-AF",
               "ff",
               "fi",
               "fil",
               "fo",
               "fr",
               "fr-BE",
               "fr-CH",
               "ga",
               "he",
               "hi",
               "hr",
               "hu",
               "hy",
               "id",
               "is",
               "it",
               "ja",
               "ka",
               "kl",
               "km",
               "ko",
               "ky",
               "lb",
               "lo",
               "lrc",
               "lt",
               "lv",
               "mk",
               "ms",
               "mt",
               "my",
               "nb",
               "nl",
               "nn",
               "pl",
               "pt",
               "pt-PT",
               "qu",
               "ro",
               "root",
               "ru",
               "se",
               "sk",
               "sl",
               "sq",
               "sr",
               "sr-Latn",
               "sv",
               "sw",
               "ta",
               "th",
               "tr",
               "uk",
               "vi",
               "yue-Hans",
               "zh",
               "zh-Hant"
             ]
  end

  test "that requesting rbnf for a locale that doesn't define it returns and error" do
    assert Cldr.Rbnf.Config.for_locale("zzz") ==
             {
               :error,
               {
                 Cldr.Rbnf.NotAvailable,
                 "The locale name \"zzz\" does not have an RBNF configuration file available"
               }
             }
  end

  test "that locale substitutions are applied" do
    assert Cldr.Locale.substitute_aliases(Cldr.LanguageTag.Parser.parse!("en-US")) ==
             %Cldr.LanguageTag{
               canonical_locale_name: nil,
               cldr_locale_name: nil,
               language_subtags: [],
               extensions: %{},
               gettext_locale_name: nil,
               language: "en",
               locale: %{},
               private_use: [],
               rbnf_locale_name: nil,
               requested_locale_name: "en-US",
               script: nil,
               territory: "US",
               transform: %{},
               language_variant: nil
             }

    assert Cldr.Locale.substitute_aliases(Cldr.LanguageTag.Parser.parse!("sh_Arab_AQ")) ==
             %Cldr.LanguageTag{
               canonical_locale_name: nil,
               cldr_locale_name: nil,
               language_subtags: [],
               extensions: %{},
               gettext_locale_name: nil,
               language: "sr",
               locale: %{},
               private_use: [],
               rbnf_locale_name: nil,
               requested_locale_name: "sh_Arab_AQ",
               script: "Arab",
               territory: "AQ",
               transform: %{},
               language_variant: nil
             }

    assert Cldr.Locale.substitute_aliases(Cldr.LanguageTag.Parser.parse!("sh_AQ")) ==
             %Cldr.LanguageTag{
               canonical_locale_name: nil,
               cldr_locale_name: nil,
               language_subtags: [],
               extensions: %{},
               gettext_locale_name: nil,
               language: "sr",
               locale: %{},
               private_use: [],
               rbnf_locale_name: nil,
               requested_locale_name: "sh_AQ",
               script: "Latn",
               territory: "AQ",
               transform: %{},
               language_variant: nil
             }
  end

  test "that we can have repeated currencies in a territory" do
    assert Cldr.Config.territory_info(:PS)[:currency] ==
             [
               JOD: %{from: ~D[1996-02-12]},
               ILS: %{from: ~D[1985-09-04]},
               ILP: %{from: ~D[1967-06-01], to: ~D[1980-02-22]},
               JOD: %{from: ~D[1950-07-01], to: ~D[1967-06-01]}
             ]
  end

  test "that we get the correct default json library" do
    assert Cldr.Config.json_library() == Jason
  end
end
