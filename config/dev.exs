import Config

config :ex_cldr,
  default_backend: MyApp.Cldr,
  json_library: Jason

config :ex_cldr, MyApp.Gettext, default_locale: "en"
