use Mix.Config

config :ex_cldr,
  default_locale: "en",
  locales: ["fr", "en", "bs", "pl", "ru", "th", "he"],
  gettext: Cldr.Gettext
