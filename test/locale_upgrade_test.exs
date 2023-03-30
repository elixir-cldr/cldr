defmodule Cldr.LocaleUpgradeTest do
  use ExUnit.Case, async: false

  test "That locales with no version are replaced with current version" do
    File.cp "./priv/cldr/locales/und.json", "/tmp/und.json"
    File.cp "./priv/cldr/locales/en.json", "/tmp/en.json"

    File.cp "./test/support/locales/no_version/de.json", "/tmp/de.json"
    File.cp "./test/support/locales/no_version/de.json", "/tmp/de.json"

    defmodule NoVersion do
      use Cldr,
        cldr_data_dir: "/tmp",
        locales: ["en", "de", "fr"],
        default_locale: "en"

    end
  end

end