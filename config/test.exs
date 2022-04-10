import Config

# Global config
config :ex_cldr,
  default_locale: "en-001",
  default_backend: TestBackend.Cldr

# For testing data_dir config
config :logger, WithOtpAppBackend.Cldr, data_dir: "./with_opt_app_backend/cldr/some_dir"

config :ex_unit,
  module_load_timeout: 220_000,
  case_load_timeout: 220_000,
  timeout: 120_000

config :logger,
  level: :error,
  truncate: 4096
