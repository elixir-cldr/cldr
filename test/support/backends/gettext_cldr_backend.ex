defmodule TestGettext.GettextWithCldrPlural do
  @moduledoc """
  Implements a Gettext-compatible module but using Cldr locales.  Its for
  testing only.
  """
  require TestBackend.Gettext.Plural

  use Gettext.Backend,
    otp_app: Cldr.Config.app_name(),
    plural_forms: TestBackend.Gettext.Plural,
    priv: "priv/gettext_test"
end
