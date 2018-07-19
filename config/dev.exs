use Mix.Config

config :ex_cldr,
  locales: ["root", "bs", "pl", "es"],
  gettext: Cldr.Gettext,
  precompile_number_formats: ["¤¤#,##0.##"],
  precompile_transliterations: [{:latn, :arab}, {:arab, :thai}]

config :ex_cldr, Cldr.Gettext, default_locale: "it"
