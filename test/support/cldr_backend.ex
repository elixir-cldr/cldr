defmodule TestBackend.Cldr do
  use Cldr,
    default_locale: "en-001",
    locales: :all,
    gettext: TestGettext.Gettext,
    precompile_transliterations: [{:latn, :arab}, {:arab, :thai}, {:arab, :latn}]

end

defmodule DefaultBackend.Cldr do
  use Cldr

end

defmodule WithGettextBackend.Cldr do
  use Cldr, gettext: TestGettext.Gettext

end

defmodule WithOtpAppBackend.Cldr do
  use Cldr, otp_app: :ex_cldr

end