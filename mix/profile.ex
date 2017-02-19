defmodule Cldr.Profile do
  import ExProf.Macro

  @names [
    "adjust_fraction_for_currency",
    "adjust_fraction_for_significant_digits",
    "adjust_for_fractional_digits",
    "absolute_value",
    "multiply_by_factor",
    "round_to_significant_digits",
    "round_to_nearest",
    "set_exponent",
    "round_fractional_digits",
    "output_to_tuple",
    "adjust_leading_zeros",
    "adjust_trailing_zeros",
    "set_max_integer_digits",
    "apply_grouping",
    "reassemble_number_string",
    "transliterate",
    "assemble_format"
  ]

  @doc "analyze with profile macro"
  def do_analyze do
    profile do
      Cldr.Number.to_string 12345.6789
    end
  end

  @doc "get analysis records and sum them up"
  def run do
    records = do_analyze()
    |> Enum.filter(&of_interest?(&1.function))
    |> Enum.sort_by(&(&1.time))
    total_percent = Enum.reduce(records, 0.0, &(&1.percent + &2))
    IO.inspect "total = #{total_percent}"
  end

  defp of_interest?(function) do
    Enum.any?(@names, fn n -> String.contains?(function, n) and !String.contains?(function, "-") end)
  end
end
