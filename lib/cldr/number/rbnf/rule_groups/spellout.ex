# credo:disable-for-this-file
defmodule Cldr.Rbnf.Spellout do
  @moduledoc """
  Functions to implement the spellout rule-based-number-format rules of CLDR.

  As CLDR notes, the data is incomplete or non-existent for many languages.  It
  is considered complete for English however.

  The standard public API for RBNF is via the `Cldr.Number.to_string/2` function.

  The functions on this module are defined at compile time based upon the RBNF rules
  defined in the Unicode CLDR data repository.  Available rules are identified by:

      iex> Cldr.Rbnf.Spellout.rule_sets "en"
      [:spellout_ordinal_verbose, :spellout_ordinal, :spellout_numbering_year,
        :spellout_numbering_verbose, :spellout_numbering, :spellout_cardinal_verbose,
        :spellout_cardinal]

  A rule can then be invoked on an available rule_set. For example:

      iex> Cldr.Rbnf.Spellout.spellout_ordinal 123, "en"
      "one hundred twenty-third"

  This call is equivalent to the call through the public API of:

      iex> Cldr.Number.to_string 123, format: :spellout
      {:ok, "one hundred twenty-three"}
  """

  import Kernel, except: [and: 2]
  use    Cldr.Rbnf.Processor

  define_rules(:SpelloutRules, __ENV__)

end