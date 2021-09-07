import Config

config :ex_cldr,
  default_backend: MyApp.Cldr

config :ex_cldr, MyApp.Gettext, default_locale: "en"
