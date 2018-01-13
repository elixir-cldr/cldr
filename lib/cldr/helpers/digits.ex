defmodule Cldr.Digits do
  @moduledoc """
  Abstract representation of number (integer, float, Decimal) in tuple form
  and functions for transformations on number parts.

  Representing a number as a list of its digits, and integer representing
  where the decimal point is placed and an integer representing the sign
  of the number allow more efficient transforms on the various parts of
  the number as happens during the formatting of a number for string output.
  """

  use Bitwise
  import Cldr.Macros
  import Cldr.Math, only: [power_of_10: 1]
  require Integer
  alias Cldr.Math

  @typedoc """
  Defines a number in a tuple form of three parts:

  * A list of digits (0..9) representing the number

  * A digit representing the place of the decimal points
  in the number

  * a `1` or `-1` representing the sign of the number

  A number in integer, float or Decimal forma can be converted
  to digit form with `Digits.to_digits/1`

  THe digits can be converted back to normal form with
  `Cldr.Digits.to_integer/1`, `Cldr.Digits.to_float/1` and
  `Cldr.Digits.to_decimal/1`.
  """
  @type t :: {[0..9, ...], non_neg_integer, 1 | -1}

  @two52 bsl(1, 52)
  @two53 bsl(1, 53)
  @float_bias 1022
  @min_e -1074

  @doc """
  Returns the fractional part of an integer, float or Decimal as an integer.

  * `number` can be either a float, Decimal or integer although an integer has
    no fraction part and will therefore always return 0.

  ## Examples

      iex> Cldr.Digits.fraction_as_integer(123.456)
      456

      iex> Cldr.Digits.fraction_as_integer(Decimal.new("123.456"))
      456

      iex> Cldr.Digits.fraction_as_integer(1999)
      0
      
  """
  @spec fraction_as_integer(Math.number_or_decimal() | {list, list, 1 | -1}) :: integer
  def fraction_as_integer({_integer, fraction, _sign})
      when is_list(fraction) do
    Integer.undigits(fraction)
  end

  def fraction_as_integer({_integer, [], _sign}) do
    0
  end

  def fraction_as_integer(number) do
    number
    |> to_tuple
    |> fraction_as_integer
  end

  def fraction_as_integer(number, rounding) do
    number = Float.round(number, rounding)
    fraction_as_integer(number)
  end

  @doc """
  Returns the number of decimal digits in a number
  (integer, float, Decimal)

  ## Options

  * `number` is an integer, float or `Decimal`
  or a list (which is assumed to contain digits).

  ## Examples

      iex> Cldr.Digits.number_of_digits(1234)
      4

      iex> Cldr.Digits.number_of_digits(Decimal.new("123456789"))
      9

      iex> Cldr.Digits.number_of_digits(1234.456)
      7

      iex> Cldr.Digits.number_of_digits(1234.56789098765)
      15

      iex> Cldr.Digits.number_of_digits '12345'
      5

  """
  @spec number_of_digits(
          Math.number_or_decimal()
          | list()
          | {[integer(), ...], integer | [integer(), ...], -1 | 1}
        ) :: integer

  def number_of_digits(%Decimal{} = number) do
    number
    |> to_digits
    |> number_of_digits
  end

  def number_of_digits(number) when is_number(number) do
    number
    |> to_digits
    |> number_of_digits
  end

  def number_of_digits(list) when is_list(list) do
    length(list)
  end

  def number_of_digits({integer, place, _sign})
      when is_list(integer) and is_integer(place) do
    length(integer)
  end

  @doc """
  Returns the number of decimal digits in the integer
  part of a number.

  ## Options

  * `number` is an integer, float or `Decimal` or
  a list (which is assumed to contain digits).

  ## Examples

      iex> Cldr.Digits.number_of_integer_digits(1234)
      4

      iex> Cldr.Digits.number_of_integer_digits(Decimal.new("123456789"))
      9

      iex> Cldr.Digits.number_of_integer_digits(1234.456)
      4

      iex> Cldr.Digits.number_of_integer_digits '12345'
      5

  """
  @spec number_of_integer_digits(
          Math.number_or_decimal()
          | list()
          | {[integer(), ...], integer | [integer(), ...], -1 | 1}
        ) :: integer
  def number_of_integer_digits(%Decimal{} = number) do
    number
    |> to_digits
    |> number_of_integer_digits
  end

  def number_of_integer_digits(number) when is_number(number) do
    number
    |> to_digits
    |> number_of_integer_digits
  end

  # A decomposed integer might be charlist or a list of integers
  # since for certain transforms this is more efficient.  Note
  # that we are not checking if the list elements are actually
  # digits.
  def number_of_integer_digits(list) when is_list(list) do
    length(list)
  end

  # For a tuple returned by `Digits.to_digits/1`
  def number_of_integer_digits({integer, place, _sign})
      when is_list(integer) and is_integer(place) and place <= 0 do
    0
  end

  def number_of_integer_digits({integer, place, _sign})
      when is_list(integer) and is_integer(place) do
    place
  end

  # For a tuple returned by `Digits.to_tuple/1`
  def number_of_integer_digits({[], _fraction, _sign}) do
    0
  end

  def number_of_integer_digits({integer, fraction, _sign})
      when is_list(integer) and is_list(fraction) do
    number_of_integer_digits(integer)
  end

  @doc """
  Remove trailing zeroes from the integer part of a number
  and returns the integer part without trailing zeros.

  * `number` is an integer, float or Decimal.

  ## Examples

      iex> Cldr.Digits.remove_trailing_zeros(1234000)
      1234

  """
  @spec remove_trailing_zeros(Math.number_or_decimal() | [integer(), ...]) ::
          integer | [integer(), ...]
  def remove_trailing_zeros(0) do
    0
  end

  def remove_trailing_zeros(number) when is_number(number) do
    {integer_digits, _fraction_digits, sign} = to_tuple(number)
    removed = remove_trailing_zeros(integer_digits)
    to_integer({removed, length(removed), sign})
  end

  def remove_trailing_zeros(%Decimal{} = number) do
    {integer_digits, _fraction_digits, sign} = to_tuple(number)
    removed = remove_trailing_zeros(integer_digits)
    to_integer({removed, length(removed), sign})
  end

  # Filters either a charlist or a list of integers.
  def remove_trailing_zeros(number) when is_list(number) do
    Enum.take_while(number, fn c ->
      (c >= ?1 and c <= ?9) or c > 0
    end)
  end

  @doc """
  Returns the number of leading zeros in a
  Decimal fraction.

  * `number` is an integer, float or Decimal

  Returns the number of leading zeros in the fractional
  part of a number.

  ## Examples

      iex> Cldr.Digits.number_of_leading_zeros(Decimal.new(0.0001))
      3

  """
  @spec number_of_leading_zeros(Math.number_or_decimal() | [integer(), ...]) :: integer
  def number_of_leading_zeros(%Decimal{} = number) do
    {_integer_digits, fraction_digits, _sign} = to_tuple(number)
    number_of_leading_zeros(fraction_digits)
  end

  def number_of_leading_zeros(number) when is_number(number) do
    {_integer_digits, fraction_digits, _sign} = to_tuple(number)
    number_of_leading_zeros(fraction_digits)
  end

  def number_of_leading_zeros(number) when is_list(number) do
    Enum.take_while(number, fn c -> c == ?0 or c == 0 end)
    |> length
  end

  @doc """
  Converts given number to a list representation.

  Given an IEEE 754 float, computes the shortest, correctly rounded list of digits
  that converts back to the same Double value when read back with String.to_float/1.
  Implements the algorithm from "Printing Floating-Point Numbers Quickly and Accurately"
  in Proceedings of the SIGPLAN '96 Conference on Programming Language Design and Implementation.

  Returns a tuple comprising a charlist for the integer part,
  a charlist for the fractional part and an integer for the sign
  """
  #   Code extracted from: https://github.com/ewildgoose/elixir-float_pp/blob/master/lib/float_pp/digits.ex
  #   Which is licenced under http://www.apache.org/licenses/LICENSE-2.0

  @spec to_tuple(Decimal.t() | number) :: {list(), list(), integer}
  def to_tuple(number) do
    {mantissa, exp, sign} = to_digits(number)

    mantissa =
      cond do
        # Need to right fill with zeros
        exp > length(mantissa) ->
          mantissa ++ :lists.duplicate(exp - length(mantissa), 0)

        # Need to left fill with zeros
        exp < 0 ->
          :lists.duplicate(abs(exp), 0) ++ mantissa

        true ->
          mantissa
      end

    cond do
      # Its an integer
      exp == length(mantissa) ->
        {mantissa, [], sign}

      # It's a fraction with no integer part
      exp <= 0 ->
        {[], mantissa, sign}

      # It's a fraction
      exp > 0 and exp < length(mantissa) ->
        {integer, fraction} = :lists.split(exp, mantissa)
        {integer, fraction, sign}
    end
  end

  @doc """
  Computes a iodata list of the digits of the given IEEE 754 floating point number,
  together with the location of the decimal point as {digits, place, positive}
  A "compact" representation is returned, so there may be fewer digits returned
  than the decimal point location
  """
  def to_digits(0.0), do: {[0], 1, 1}
  def to_digits(0), do: {[0], 1, 1}

  def to_digits(float) when is_float(float) do
    # Find mantissa and exponent from IEEE-754 packed notation
    {frac, exp} = frexp(float)

    # Scale fraction to integer (and adjust mantissa to compensate)
    frac = trunc(abs(frac) * @two53)
    exp = exp - 53

    # Compute digits
    flonum(float, frac, exp)
  end

  def to_digits(%Decimal{} = number) do
    %Decimal{coef: coef, exp: exp, sign: sign} = Decimal.reduce(number)
    {digits, _place, _sign} = to_digits(coef)
    {digits, length(digits) + exp, sign}
  end

  def to_digits(integer) when is_integer(integer) when integer >= 0 do
    digits = Integer.digits(integer)
    {digits, length(digits), 1}
  end

  def to_digits(integer) when is_integer(integer) do
    digits = Integer.digits(integer)
    {digits, length(digits), -1}
  end

  @doc """
  Takes a list of digits and coverts them back to a number of the same
  type as `number`
  """
  def to_number(digits, number) when is_integer(number), do: to_integer(digits)
  def to_number(digits, number) when is_float(number), do: to_float(digits)
  def to_number(digits, %Decimal{}), do: to_decimal(digits)

  def to_number(digits, :integer), do: to_integer(digits)
  def to_number(digits, :float), do: to_float(digits)
  def to_number(digits, :decimal), do: to_decimal(digits)

  def to_integer({digits, place, sign}) do
    {int_digits, _fraction_digits} = Enum.split(digits, place)
    Integer.undigits(int_digits) * sign
  end

  def to_float({[0], _place, _sign}) do
    0.0
  end

  def to_float({digits, place, sign}) do
    Integer.undigits(digits) / power_of_10(length(digits) - place) * sign
  end

  def to_decimal({digits, place, sign}) do
    %Decimal{coef: Integer.undigits(digits), exp: place - length(digits), sign: sign}
  end

  ############################################################################
  # The following functions are Elixir translations of the original paper:
  # "Printing Floating-Point Numbers Quickly and Accurately"
  # http://www.cs.tufts.edu/~nr/cs257/archive/florian-loitsch/printf.pdf
  # See the paper for further explanation

  docp("""
  Set initial values {r, s, m+, m-}
  based on table 1 from FP-Printing paper
  Assumes frac is scaled to integer (and exponent scaled appropriately)
  """)

  defp flonum(float, frac, exp) do
    round = Integer.is_even(frac)

    if exp >= 0 do
      b_exp = bsl(1, exp)

      if frac !== @two52 do
        scale(frac * b_exp * 2, 2, b_exp, b_exp, round, round, float)
      else
        scale(frac * b_exp * 4, 4, b_exp * 2, b_exp, round, round, float)
      end
    else
      if exp === @min_e or frac !== @two52 do
        scale(frac * 2, bsl(1, 1 - exp), 1, 1, round, round, float)
      else
        scale(frac * 4, bsl(1, 2 - exp), 2, 1, round, round, float)
      end
    end
  end

  @log_0_approx -60
  def scale(r, s, m_plus, m_minus, low_ok, high_ok, float) do
    # TODO: Benchmark removing the log10 and using the approximation given in original paper?
    est =
      if float == 0 do
        @log_0_approx
      else
        trunc(Float.ceil(:math.log10(abs(float)) - 1.0e-10))
      end

    if est >= 0 do
      fixup(r, s * power_of_10(est), m_plus, m_minus, est, low_ok, high_ok, float)
    else
      scale = power_of_10(-est)
      fixup(r * scale, s, m_plus * scale, m_minus * scale, est, low_ok, high_ok, float)
    end
  end

  def fixup(r, s, m_plus, m_minus, k, low_ok, high_ok, float) do
    too_low = if high_ok, do: r + m_plus >= s, else: r + m_plus > s

    if too_low do
      {generate(r, s, m_plus, m_minus, low_ok, high_ok), k + 1, sign(float)}
    else
      {generate(r * 10, s, m_plus * 10, m_minus * 10, low_ok, high_ok), k, sign(float)}
    end
  end

  defp generate(r, s, m_plus, m_minus, low_ok, high_ok) do
    d = div(r, s)
    r = rem(r, s)

    tc1 = if low_ok, do: r <= m_minus, else: r < m_minus
    tc2 = if high_ok, do: r + m_plus >= s, else: r + m_plus > s

    if not tc1 do
      if not tc2 do
        [d | generate(r * 10, s, m_plus * 10, m_minus * 10, low_ok, high_ok)]
      else
        [d + 1]
      end
    else
      if not tc2 do
        [d]
      else
        if r * 2 < s do
          [d]
        else
          [d + 1]
        end
      end
    end
  end

  ############################################################################
  # Utility functions

  # FIXME: We don't handle +/-inf and NaN inputs. Not believed to be an issue in
  # Elixir, but beware future-self reading this...

  docp("""
  The frexp() function is as per the clib function with the same name. It breaks
  the floating-point number value into a normalized fraction and an integral
  power of 2.

  Returns {frac, exp}, where the magnitude of frac is in the interval
  [1/2, 1) or 0, and value = frac*(2^exp).
  """)

  defp frexp(value) do
    <<sign::1, exp::11, frac::52>> = <<value::float>>
    frexp(sign, frac, exp)
  end

  defp frexp(_Sign, 0, 0) do
    {0.0, 0}
  end

  # Handle denormalised values
  defp frexp(sign, frac, 0) do
    exp = bitwise_length(frac)
    <<f::float>> = <<sign::1, @float_bias::11, frac - 1::52>>
    {f, -@float_bias - 52 + exp}
  end

  # Handle normalised values
  defp frexp(sign, frac, exp) do
    <<f::float>> = <<sign::1, @float_bias::11, frac::52>>
    {f, exp - @float_bias}
  end

  docp("""
  Return the number of significant bits needed to store the given number
  """)

  defp bitwise_length(value) do
    bitwise_length(value, 0)
  end

  defp bitwise_length(0, n), do: n
  defp bitwise_length(value, n), do: bitwise_length(bsr(value, 1), n + 1)

  defp sign(float) when float < 0, do: -1
  defp sign(_float), do: 1
end
