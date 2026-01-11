require Cldr.Locale.Loader
require MyApp.Gettext

defmodule MyApp.Cldr do
  use Cldr,
    gettext: MyApp.Gettext,
    locales: [
      "en", "en-001", "de", "ja", "en-AU", "th", "ar", "pl", "doi", "fr-CA", "nb", "no", "ca-ES-VALENCIA", "ca",
      "zh-Hant-HK", "zh", "nn", "da", "hr", "sr", "to"],
    generate_docs: true,
    providers: []

    def for_dialyzer do
      Cldr.put_locale("en")
      Cldr.put_locale(:en)
    end
end
