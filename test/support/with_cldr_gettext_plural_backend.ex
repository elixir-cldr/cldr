require TestGettext.GettextWithCldrPlural

defmodule WithGettextPlural.Cldr do
  use Cldr,
    locales: ["en", "it", "pl"],
    gettext: TestGettext.GettextWithCldrPlural,
    providers: []
end