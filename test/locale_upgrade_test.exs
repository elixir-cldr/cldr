defmodule Cldr.LocaleUpgradeTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureLog
  import ExUnit.CaptureIO

  setup_all do
    old_level = Logger.level()
    Logger.configure level: :info

    File.cp! "./priv/cldr/locales/und.json", "/tmp/locales/und.json"
    File.cp! "./priv/cldr/locales/en.json", "/tmp/locales/en.json"

    File.cp! "./test/support/locales/no_version/de.json", "/tmp/locales/de.json"
    File.rename! "./priv/cldr/locales/de.json", "./priv/cldr/locales/_de.json"

    File.cp! "./test/support/locales/old_version/fr.json", "/tmp/locales/fr.json"
    File.rename! "./priv/cldr/locales/fr.json", "./priv/cldr/locales/_fr.json"

    on_exit(fn ->
      Logger.configure level: old_level
      File.rename! "./priv/cldr/locales/_de.json", "./priv/cldr/locales/de.json"
      File.rename! "./priv/cldr/locales/_fr.json", "./priv/cldr/locales/fr.json"
    end)

    :ok
  end

  test "That locales with no version are replaced with current version" do
    assert capture_log(fn ->
      capture_io(fn ->
        defmodule NoVersion do
          use Cldr,
            data_dir: "/tmp",
            locales: ["en", "de"],
            default_locale: "en",
            providers: []
        end
      end)
    end) =~ "Locale data for :de is stale. Updated locale data will be downloaded."
  end

  test "That locales with an old version are replaced with current version" do
    assert capture_log(fn ->
      capture_io(fn ->
        defmodule OldVersion do
          use Cldr,
            data_dir: "/tmp",
            locales: ["en", "fr"],
            default_locale: "en",
            providers: []
        end
      end)
    end) =~ "Locale data for :fr is stale. Updated locale data will be downloaded."
  end
end
