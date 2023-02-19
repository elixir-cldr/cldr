defmodule TestGettext.GettextWithCldrPlural do
  @moduledoc """
  Implements a Gettext-compatible module but using Cldr locales.  Its for
  testing only.
  """
  use Gettext,
    otp_app: Cldr.Config.app_name(),
    plural_forms: TestBackend.Gettext.Plural,
    priv: "priv/gettext_test"
end