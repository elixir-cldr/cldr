defmodule Doc.Test.Backend do
  use ExUnit.Case
  doctest TestBackend.Cldr
  doctest Cldr.Config
  doctest Cldr
end
