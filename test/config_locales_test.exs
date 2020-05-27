defmodule Cldr.Config.Test do
  use ExUnit.Case, async: true

  @from_locales ["en", "en-au", "zh-hant-hk", "zh_haNt"]

  test "locale resolution in a config is case insensitive" do
    to_locales = ["en", "en-001", "en-AU", "root", "zh", "zh-Hant", "zh-Hant-HK"]
    assert Cldr.Config.known_locale_names(%Cldr.Config{locales: @from_locales}) == to_locales
  end

  test "a backend locales configuration" do
    opts = [locales: unquote(@from_locales), providers: []]
    config = Cldr.Config.config_from_opts(opts)

    assert config.locales == ["en", "en-AU", "zh-Hant-HK", "zh-Hant", "en-001", "root"]
  end

end