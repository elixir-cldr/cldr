use Mix.Config

config :ex_cldr,
  default_locale: "en",
  locales: ["root", "fr", "en", "bs", "pl", "ru", "th", "he"],
  gettext: Cldr.Gettext,
  precompile_number_formats: ["¤¤#,##0.##"]
