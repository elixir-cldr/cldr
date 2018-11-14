defmodule Cldr.Gettext.Test do
  use ExUnit.Case

  test "get the gettext module and find its configured locales" do
    gettext_module = TestBackend.Cldr.__cldr__(:gettext)
    otp_app = gettext_module.__gettext__(:otp_app)

    config = Application.get_env(otp_app, gettext_module)
    default_locale = config[:default_locale]

    assert default_locale == "en"
  end

  test "that Cldr.Config gets the list of locales when there is no global default" do
    assert TestBackend.Cldr.known_gettext_locale_names == ["en", "en-GB", "es"]
  end
end
