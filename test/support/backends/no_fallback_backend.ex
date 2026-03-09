defmodule NoFallback.Cldr do
  use Cldr,
    locales: ["en", "es-US"],
    default_locale: "en",
    providers: []
end