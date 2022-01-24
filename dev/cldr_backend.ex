require Cldr.Backend
require Cldr.Locale.Loader

defmodule MyApp.Cldr do
  use Cldr,
    gettext: MyApp.Gettext,
    locales: ["en", "de", "ja", "en-AU", "th", "ar", "pl", "doi", "fr-CA", "nb"],
    generate_docs: true,
    providers: []

end



