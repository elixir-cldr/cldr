use Mix.Config

config :ex_cldr,
  default_locale: "en-SG",
  locales: ["root", "fr", "en", "bs", "pl", "ru", "th", "he", "af", "af-NA"],
  gettext: Cldr.Gettext,
  precompile_number_formats: ["¤¤#,##0.##"],
  precompile_transliterations: [{:latn, :arab}, {:arab, :thai}]
