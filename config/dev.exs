use Mix.Config

config :ex_cldr,
  default_locale: "en-001",
  locales: ["root", "fr", "zh-Hant", "en-GB", "bs", "pl", "ru", "th", "he", "af"],
  gettext: Cldr.Gettext,
  precompile_number_formats: ["¤¤#,##0.##"],
  precompile_transliterations: [{:latn, :arab}, {:arab, :thai}],
  json_library: Poison
