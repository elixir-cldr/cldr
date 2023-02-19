# Tests when there is no config
require Cldr

defmodule DefaultBackend.Cldr do
  use Cldr,
    generate_docs: false,
    providers: []
end

