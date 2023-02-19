defmodule TestGettext.Gettext do
  @moduledoc """
  Implements a Gettext-compatible module but using Cldr locales.  Its for
  testing only.
  """
  use Gettext,
    otp_app: Cldr.Config.app_name(),
    priv: "priv/gettext_test"
end

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

# From Gettext 0.22 onwards this module will raise
# an exception since the locale "gsw" isn't configured
# in Gettext. Since no tests depend on this module other
# than its compilation (which cannot now happen) it
# is currently omitted.

# defmodule TestGettext.GettextUnknown do
#   @moduledoc """
#   Implements a Gettext-compatible module but using Cldr locales.  Its for
#   testing only.
#   """
#   use Gettext,
#     otp_app: Cldr.Config.app_name(),
#     priv: "priv/gettext_unknown"
# end
