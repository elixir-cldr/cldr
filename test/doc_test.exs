defmodule Doc.Test do
  use ExUnit.Case
  doctest Cldr
  doctest Cldr.Config
  doctest Cldr.List
  doctest Cldr.Math
  doctest Cldr.Currency
  doctest Cldr.Number
  doctest Cldr.Number.String
  doctest Cldr.Number.Format
  doctest Cldr.Number.System
  doctest Cldr.Number.Format.Compiler
  doctest Cldr.Number.Formatter.Short

end
