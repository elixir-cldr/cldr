# Tests when there is no config
defmodule DefaultBackend.Cldr do
  use Cldr,
    generate_docs: false,
    providers: []
end

