defmodule Cldr.Test do
  use ExUnit.Case

  # If you're testing on your own machine, replace @dev_dir
  # with the repo root directory of your own system
  def strip(string) do
    String.replace(string, Cldr.Config.cldr_home(),"")
  end

  test "that the cldr source data directory is correct" do
    assert strip(Cldr.Config.source_data_dir()) == "/priv/cldr"
  end

  test "that the client data directory is correct" do
    assert strip(Cldr.Config.client_data_dir()) ==
      "/_build/test/lib/ex_cldr/priv/cldr"
  end

  test "that the cldr data directory is correct" do
    assert strip(Cldr.Config.cldr_data_dir()) ==
      "/_build/test/lib/ex_cldr/priv/cldr"
  end

  test "that the download data directory is correct" do
    assert strip(Cldr.Config.download_data_dir()) == "/data"
  end

  test "that we have the correct modules (keys) for the json consolidation" do
    assert Cldr.Config.required_modules() ==
      ["number_formats", "list_formats", "currencies", "number_systems",
       "number_symbols", "minimum_grouping_digits", "rbnf", "units", "date_fields", "dates"]
  end

  test "default locale" do
    assert Cldr.default_locale() == "en"
  end

  test "locale does not exist" do
    refute Cldr.locale_exists?("jabberwocky")
  end

end