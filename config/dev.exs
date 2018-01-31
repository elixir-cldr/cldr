use Mix.Config

config :ex_cldr,
  # default_locale: "en-001",
  locales: ["root", "fr", "bs", "pl", "ru", "th", "he", "af"],
  # locales: [],
  gettext: Cldr.Gettext,
  precompile_number_formats: ["¤¤#,##0.##"],
  precompile_transliterations: [{:latn, :arab}, {:arab, :thai}],
  json_library: Jason

config :ex_cldr, Cldr.Gettext,
  default_locale: "it"
