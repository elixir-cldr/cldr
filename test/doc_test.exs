defmodule Doc.Test do
  use ExUnit.Case
  doctest Cldr
  doctest Cldr.Config
  doctest Cldr.File
  doctest Cldr.List
  doctest Cldr.Currency
  doctest Cldr.Number.Format
  doctest Cldr.Number.System
  doctest Cldr.Number.Math

end
