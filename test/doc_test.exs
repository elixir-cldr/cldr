defmodule Doc.Test do
  use ExUnit.Case
  doctest Cldr
  doctest Cldr.Config
  doctest Cldr.List
  doctest Cldr.Currency
  doctest Cldr.Number
  doctest Cldr.Number.String
  doctest Cldr.Number.Format
  doctest Cldr.Number.System
  doctest Cldr.Number.Math
  doctest Cldr.Number.Format.Compiler

end
