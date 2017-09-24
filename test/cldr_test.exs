defmodule Cldr.Test do
  use ExUnit.Case

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
       "number_symbols", "minimum_grouping_digits", "rbnf", "units", "date_fields", "dates"]
  end

  test "default locale" do
    assert Cldr.default_locale() ==
      %Cldr.LanguageTag{canonical_locale_name: "en-Latn-001",
        extensions: %{}, language: "en", locale: [], private_use: [],
        region: "001", requested_locale_name: "en-001", script: "Latn",
        transforms: %{}, variant: nil}
  end

  test "locale does not exist" do
    refute Cldr.locale_exists?("jabberwocky")
  end

end