# In test mode we compile and test all locales
use Mix.Config

config :ex_cldr,
  default_locale: "en-001",
  locales: :all,
  gettext: Cldr.Gettext,
  precompile_transliterations: [{:latn, :arab}, {:arab, :thai}, {:arab, :latn}]

config :ex_unit,
  case_load_timeout: 220_000,
  timeout: 120_000
