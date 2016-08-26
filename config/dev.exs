use Mix.Config

config :cldr,
  default_locale: "en",
  locales: ["fr", "en", "bs", "pl", "ru", "th"],
  gettext: Cldr.Gettext
