use Mix.Config

config :cldr,
  default_locale: "en",
  locales: ["fr", "en", "bs", "pl", "ru", "th", "he"],
  gettext: Cldr.Gettext
