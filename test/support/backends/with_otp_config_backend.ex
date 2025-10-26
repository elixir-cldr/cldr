# Tests with otp_app
defmodule WithOtpAppBackend.Cldr do
  use Cldr,
    locales: ["fr", "en"],
    otp_app: :logger,
    providers: []
end
