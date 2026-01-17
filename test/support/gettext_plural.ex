# require WithGettextPlural.Cldr

defmodule TestBackend.Gettext.Plural do
  use Cldr.Gettext.Plural, cldr_backend: WithGettextPlural.Cldr
end
