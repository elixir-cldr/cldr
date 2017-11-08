defmodule Cldr.Test do
  use ExUnit.Case

  test "that the cldr home directory is correct" do
    assert String.ends_with?(Cldr.Config.cldr_home(), "/cldr") == true
  end

  test "that the cldr source data directory is correct" do
    assert String.ends_with?(Cldr.Config.source_data_dir(), "/priv/cldr") == true
  end

  test "that the client data directory is correct" do
    assert String.ends_with?(Cldr.Config.client_data_dir(),
      "/_build/test/lib/ex_cldr/priv/cldr") == true
  end

  test "that the cldr data directory is correct" do
    assert String.ends_with?(Cldr.Config.cldr_data_dir(),
      "/_build/test/lib/ex_cldr/priv/cldr") == true
  end

  test "that the download data directory is correct" do
    assert String.ends_with?(Cldr.Config.download_data_dir(), "/data") == true
  end

  test "that we have the correct modules (keys) for the json consolidation" do
    assert Cldr.Config.required_modules() ==
      ["number_formats", "list_formats", "currencies", "number_systems",
       "number_symbols", "minimum_grouping_digits", "rbnf", "units", "date_fields",
       "dates", "territories", "languages"]
  end

  test "default locale" do
    assert Cldr.default_locale() ==
      %Cldr.LanguageTag{canonical_locale_name: "en-Latn-001",
        cldr_locale_name: "en-001", extensions: %{},
        language: "en", locale: %{}, private_use: [],
        territory: "001", requested_locale_name: "en-001",
        script: "Latn", transform: %{}, variant: nil,
        rbnf_locale_name: "en"}
  end

  test "locale name does not exist" do
    refute Cldr.available_locale_name?("jabberwocky")
  end

  test "that we have the right number of rbnf locales" do
    assert Cldr.known_rbnf_locale_names ==
    ["af", "ak", "am", "ar", "az", "be", "bg", "bs", "ca", "chr", "cs", "cy", "da",
     "de", "de-CH", "ee", "el", "en", "en-IN", "eo", "es", "es-419", "et", "fa",
     "fa-AF", "fi", "fil", "fo", "fr", "fr-BE", "fr-CH", "ga", "he", "hi", "hr",
     "hu", "hy", "id", "is", "it", "ja", "ka", "kl", "km", "ko", "ky", "lo", "lrc",
     "lt", "lv", "mk", "ms", "mt", "my", "nb", "nl", "nn", "pl", "pt", "pt-PT",
     "ro", "root", "ru", "se", "sk", "sl", "sq", "sr", "sr-Latn", "sv", "ta", "th",
     "tr", "uk", "vi", "yue-Hans", "zh", "zh-Hant"]
  end

  test "that requesting rbnf for a locale that doesn't define it returns and error" do
    assert Cldr.Rbnf.Config.for_locale("zzz") ==
      {:error,
        {Cldr.Rbnf.NotAvailable,
          "The locale name \"zzz\" does not have an RBNF configuration file available"}}
  end
end