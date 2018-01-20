defmodule Cldr.Gettext.Test do
  use ExUnit.Case

  test "get the gettext module and find its configured locales" do
    gettext_module = Application.get_env(:ex_cldr, :gettext)
    otp_app = gettext_module.__gettext__(:otp_app)

    config = Application.get_env(otp_app, gettext_module)
    default_locale = config[:default_locale]

    assert default_locale == "en"
  end

  test "that Cldr.Config gets the list of locales" do
    Application.put_env(:gettext, :default_locale, "zh")
    assert Cldr.Config.gettext_locales == ["en", "en-GB", "zh"]
    Application.put_env(:gettext, :default_locale, nil)
  end

  test "that Cldr.Config gets the list of locales when there is no global default" do
    assert Cldr.Config.gettext_locales == ["en", "en-GB"]
  end
end