# Test with Gettext
defmodule WithGettextBackend.Cldr do
  use Cldr,
    gettext: TestGettext.Gettext,
    providers: []
end
