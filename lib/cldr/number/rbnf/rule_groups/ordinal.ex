# credo:disable-for-this-file
defmodule Cldr.Rbnf.Ordinal do
  @moduledoc """
  Functions to implement the ordinal rule-based-number-format rules of CLDR.

  As CLDR notes, the data is incomplete or non-existent for many languages.  It
  is considered complete for English however.

  The standard public API for RBNF is via the `Cldr.Number.to_string/2` function.

  The functions on this module are defined at compile time based upon the RBNF rules
  defined in the Unicode CLDR data repository.  Available rules are identified by:

      iex> Cldr.Rbnf.Ordinal.rule_sets "en"
      [:digits_ordinal]

  A rule can then be invoked on an available rule_set.  For example

      iex> Cldr.Rbnf.Ordinal.digits_ordinal 123, "en"
      "123rd"

  This call is equivalent to the call through the public API of:

      iex> Cldr.Number.to_string 123, format: :ordinal
      {:ok, "123rd"}
  """

  import Kernel, except: [and: 2]
  use    Cldr.Rbnf.Processor

  define_rules(:OrdinalRules, __ENV__)

end