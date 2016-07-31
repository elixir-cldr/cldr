use Mix.Config

config :cldr,
  default_locale: "en",
  locales: ["fr", "en", "bs", "si", "ak"],
  gettext: Cldr.Gettext