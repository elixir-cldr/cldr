use Mix.Config

config :cldr,
  default_locale: "en",
  locales: ["fr", "en", "bs", "si", "ak", "th"],
  gettext: Cldr.Gettext