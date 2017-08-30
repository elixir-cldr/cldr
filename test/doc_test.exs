defmodule Doc.Test do
  use ExUnit.Case
  doctest Cldr
  doctest Cldr.Config
  doctest Cldr.Math
  doctest Cldr.Currency
  doctest Cldr.Number
  doctest Cldr.Number.String
  doctest Cldr.Number.Format
  doctest Cldr.Number.System
  doctest Cldr.Number.Transliterate
  doctest Cldr.Number.Format.Compiler
  doctest Cldr.Number.Formatter.Decimal
  doctest Cldr.Number.Formatter.Short
  doctest Cldr.Number.Formatter.Currency
  doctest Cldr.Rbnf.Config
  doctest Cldr.Rbnf.Ordinal
  doctest Cldr.Rbnf.Spellout
  doctest Cldr.Rbnf.NumberSystem
end
