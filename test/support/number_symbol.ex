defmodule Cldr.Number.Symbol do
  @moduledoc false
  # Stands in for the struct of ex_cldr_numbers, which ex_cldr does not
  # depend on. The fields are those of ex_cldr_numbers 2.38.3.
  defstruct [
    :decimal,
    :group,
    :exponential,
    :infinity,
    :list,
    :minus_sign,
    :nan,
    :per_mille,
    :percent_sign,
    :plus_sign,
    :superscripting_exponent,
    :time_separator
  ]
end
