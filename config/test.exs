# In test mode we compile and test all locales
use Mix.Config

config :ex_cldr,
  default_locale: "en-001",
  locales: :all,
  gettext: Cldr.Gettext,
  precompile_transliterations: [{:latn, :arab}, {:arab, :thai}, {:arab, :latn}]

config :ex_cldr, Cldr.Gettext, default_locale: "en"

config :plug, validate_header_keys_during_test: true

config :ex_unit,
  module_load_timeout: 220_000,
  case_load_timeout: 220_000,
  timeout: 120_000
