use Mix.Config

# Global config
config :ex_cldr,
  default_locale: "en-001",
  locales: ["en"],
  otp_app: :ex_cldr

config :ex_cldr, TestGettext.Gettext,
  default_locale: "en"

# otp app config
config :ex_cldr,
  :ex_cldr, locales: ["fr"]

# Other configs
config :plug,
  validate_header_keys_during_test: true

config :ex_unit,
  module_load_timeout: 220_000,
  case_load_timeout: 220_000,
  timeout: 120_000
