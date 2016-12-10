defmodule Cldr.Float do
  @moduledoc """
  Implement rounding of a list of decimal digits to an arbitrary precision
  using one of several rounding algorithms.
  Rounding algorithms are based on the definitions given in IEEE 754, but also
  include 2 additional options (effectively the complementary versions):

  ## Rounding algorithms

  Directed roundings:
  * `:down` - Round towards 0 (truncate), eg 10.9 rounds to 10.0
  * `:up` - Round away from 0, eg 10.1 rounds to 11.0. (Non IEEE algorithm)
  * `:ceiling` - Round toward +∞ - Also known as rounding up or ceiling
  * `:floor` - Round toward -∞ - Also known as rounding down or floor

  Round to nearest:
  * `:half_even` - Round to nearest value, but in a tiebreak, round towards the
    nearest value with an even (zero) least significant bit, which occurs 50%
    of the time. This is the default for IEEE binary floating-point and the recommended
    value for decimal.
  * `:half_up` - Round to nearest value, but in a tiebreak, round away from 0.
    This is the default algorithm for Erlang's Kernel.round/2
  * `:half_down` - Round to nearest value, but in a tiebreak, round towards 0
    (Non IEEE algorithm)
  """
  require Integer
  alias Cldr.Digits

  @type rounding :: :down |
                    :half_up |
                    :half_even |
                    :ceiling |
                    :floor |
                    :half_down |
                    :up


  @doc """
  Round a digit using a specified rounding.

  Given a list of decimal digits (without trailing zeros) in the form:

    `sign [sig_digits] | least_sig | tie | [rest]`

  There are a number of rounding options which may be conditional on, for example:

  * sign of the orignal number
  * even-ness of the least_sig digit
  * whether there is a non-zero tie break digit
  * if the tie break digit is 5, whether there are further non zero digits

  The various rounding rules are based on IEEE 754 and documented in `Cldr.Float`
  """
  def round(digits_t, options)

  # Passing true for decimal places avoids rounding and uses whatever is necessary
  def round(digits_t, %{scientific: true}), do: digits_t
  def round(digits_t, %{decimals: true}), do: digits_t

  # rounded away all the decimals... return 0
  def round(_, %{scientific: dp}) when dp <= 0,
    do: {[0], 1, true}
  def round({_, place, _}, %{decimals: dp}) when dp + place <= 0,
    do: {[0], 1, true}

  # scientific/decimal rounding are the same, we are just varying which
  # digit we start counting from to find our rounding point
  def round(number, %{} = options) when is_number(number) do
    number
    |> Digits.to_digits
    |> round(options)
  end

  def round(number, options) when is_number(number) and is_list(options) do
    options = Enum.into(options, %{})
    round(number, options)
  end

  def round(digits_t, options = %{scientific: dp}) do
    {digits, place, sign} = do_round(digits_t, dp, options)
    {List.flatten(digits), place, sign}
  end

  def round(digits_t = {_, place, _}, options = %{decimals: dp}) do
    {digits, place, sign} = do_round(digits_t, dp + place - 1, options)
    {List.flatten(digits), place, sign}
  end

  defp do_round({digits, place, positive}, round_at, %{rounding: rounding}) do
      case Enum.split(digits, round_at) do
        {l, [least_sig | [tie | rest]]} ->
          case do_incr(l, least_sig, increment?(positive, least_sig, tie, rest, rounding)) do
            [:rollover | digits] -> {digits, place + 1, positive}
            digits               -> {digits, place, positive}
          end
        {l, [least_sig | []]}           -> {[l, least_sig], place, positive}
        {l, []}                         -> {l, place, positive}
      end
  end

  defp do_incr(l, least_sig, false), do: [l, least_sig]
  defp do_incr(l, least_sig, true) when least_sig < 9, do: [l, least_sig + 1]
  # else need to cascade the increment
  defp do_incr(l, 9, true) do
    l
    |> Enum.reverse
    |> cascade_incr
    |> Enum.reverse([0])
  end

  # cascade an increment of decimal digits which could be rolling over 9 -> 0
  defp cascade_incr([9 | rest]), do: [0 | cascade_incr(rest)]
  defp cascade_incr([d | rest]), do: [d+1 | rest]
  defp cascade_incr([]), do: [1, :rollover]


  @spec increment?(boolean, non_neg_integer | nil, non_neg_integer | nil, list, FloatPP.rounding) :: non_neg_integer
  defp increment?(positive, least_sig, tie, rest, round)

  # Directed rounding towards 0 (truncate)
  defp increment?(_, _ls, _tie, _, :down), do: false
  # Directed rounding away from 0 (non IEEE option)
  defp increment?(_, _ls, nil, _, :up), do: false
  defp increment?(_, _ls, _tie, _, :up), do: true

  # Directed rounding towards +∞ (rounding up / ceiling)
  defp increment?(true, _ls, tie, _, :ceiling) when tie != nil, do: true
  defp increment?(_, _ls, _tie, _, :ceiling), do: false

  # Directed rounding towards -∞ (rounding down / floor)
  defp increment?(false, _ls, tie, _, :floor) when tie != nil, do: true
  defp increment?(_, _ls, _tie, _, :floor), do: false

  # Round to nearest - tiebreaks by rounding to even
  # Default IEEE rounding, recommended default for decimal
  defp increment?(_, ls, 5, [], :half_even) when Integer.is_even(ls), do: false
  defp increment?(_, _ls, tie, _rest, :half_even) when tie >= 5, do: true
  defp increment?(_, _ls, _tie, _rest, :half_even), do: false

  # Round to nearest - tiebreaks by rounding away from zero (same as Elixir Kernel.round)
  defp increment?(_, _ls, tie, _rest, :half_up) when tie >= 5, do: true
  defp increment?(_, _ls, _tie, _rest, :half_up), do: false

  # Round to nearest - tiebreaks by rounding towards zero (non IEEE option)
  defp increment?(_, _ls, 5, [], :half_down), do: false
  defp increment?(_, _ls, tie, _rest, :half_down) when tie >= 5, do: true
  defp increment?(_, _ls, _tie, _rest, :half_down), do: false
end