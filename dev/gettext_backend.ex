Application.ensure_all_started(:gettext)
require MyApp.Gettext.Plural

defmodule MyApp.Gettext do
  use Gettext,
    otp_app: Cldr.Config.app_name(),
    plural_forms: MyApp.Gettext.Plural,
    priv: "priv/gettext_test"
end