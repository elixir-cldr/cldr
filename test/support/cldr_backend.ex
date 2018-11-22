defmodule TestBackend.Cldr do
  use Cldr,
    default_locale: "en-001",
    locales: :all,
    gettext: TestGettext.Gettext,
    precompile_transliterations: [{:latn, :arab}, {:arab, :thai}, {:arab, :latn}]
end

# Tests when there is no config
defmodule DefaultBackend.Cldr do
  use Cldr
end

# Tests when there are locales but no default
defmodule AnotherBackend.Cldr do
  use Cldr, locales: ["en", "fr"]
end

# Test with Gettext
defmodule WithGettextBackend.Cldr do
  use Cldr, gettext: TestGettext.Gettext
end

# Tests with otp_app
defmodule WithOtpAppBackend.Cldr do
  use Cldr, otp_app: :ex_cldr
end