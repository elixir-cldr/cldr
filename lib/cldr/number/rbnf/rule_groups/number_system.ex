# credo:disable-for-this-file
defmodule Cldr.Rbnf.NumberSystem do
  @moduledoc """
  Functions to implement the number system rule-based-number-format rules of CLDR.

  These rules are defined only on the "root" locale and represent specialised
  number formatting.

  The standard public API for RBNF is via the `Cldr.Number.to_string/2` function.

  The functions on this module are defined at compile time based upon the RBNF rules
  defined in the Unicode CLDR data repository.  Available rules are identified by:

      iex> Cldr.Rbnf.NumberSystem.rule_sets "root"
      [:tamil, :roman_upper, :roman_lower, :hebrew_item, :hebrew_0_99, :hebrew,
      :greek_upper, :greek_lower, :georgian, :ethiopic_p1, :ethiopic,
      :cyrillic_lower_1_10, :cyrillic_lower, :armenian_upper, :armenian_lower]

  A rule can then be invoked on an available rule_set.  For example

      iex> Cldr.Rbnf.NumberSystem.roman_upper 123, "root"
      "CXXIII"

  This call is equivalent to the call through the public API of:

      iex> Cldr.Number.to_string 123, format: :roman
      {:ok, "CXXIII"}
  """

  import Kernel, except: [and: 2]
  use    Cldr.Rbnf.Processor

  define_rules(:NumberingSystemRules, __ENV__)

end