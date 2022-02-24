require Cldr.Backend
require Cldr.Locale.Loader

defmodule MyApp.Cldr do
  use Cldr,
    gettext: MyApp.Gettext,
    locales: ["en", "de", "ja", "en-AU", "th", "ar", "pl", "doi", "fr-CA", "nb", "no"],
    generate_docs: true,
    providers: []

    def for_dialyzer do
      Cldr.put_locale("en")
      Cldr.put_locale(:en)
    end
end



