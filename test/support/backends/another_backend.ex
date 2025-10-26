# Tests when there are locales but no default
defmodule AnotherBackend.Cldr do
  use Cldr,
    locales: ["en"],
    data_dir: "./another_backend/cldr/data_dir",
    providers: []
end
