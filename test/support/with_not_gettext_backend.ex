# Test with not Gettext
defmodule WithNoGettextBackend.Cldr do
  use Cldr,
    providers: []
end

