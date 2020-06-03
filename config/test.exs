use Mix.Config

# Global config
config :ex_cldr,
  default_locale: "en-001",
  default_backend: TestBackend.Cldr,
  locales: ["en"]

config :ex_cldr, TestGettext.Gettext,
  default_locale: "en"

# otp app config
config :ex_cldr, WithOtpAppBackend.Cldr,
  locales: ["fr"]

# For testing data_dir config
config :logger, WithOtpAppBackend.Cldr,
  data_dir: "./with_opt_app_backend/cldr/some_dir"

# Other configs
config :plug,
  validate_header_keys_during_test: true

config :ex_unit,
  module_load_timeout: 220_000,
  case_load_timeout: 220_000,
  timeout: 120_000

config :logger,
  level: :error,
  truncate: 4096
