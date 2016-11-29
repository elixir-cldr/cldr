defmodule Cldr.Rbnf.Ordinal do
  @moduledoc """
  Functions to implement the ordinal rule-based-number-format rules of CLDR.

  As CLDR notes, the data is incomplete or non-existent for many languages.  It
  is considered complete for English however.
  """

  import Kernel, except: [and: 2]
  use    Cldr.Rbnf.Processor

  define_rules(:OrdinalRules, __ENV__)

  def rule_sets(locale) do
    Cldr.Rbnf.Processor.rule_sets(:OrdinalRules, locale)
  end
end