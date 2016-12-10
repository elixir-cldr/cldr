defmodule Cldr.Digits do


  use Bitwise
  import Cldr.Macros
  require Integer
  alias Cldr.Math

  @two52 bsl 1, 52
  @two53 bsl 1, 53
  @float_bias 1022
  @min_e -1074

  @doc """
  Returns the fractional part of an integer, float or Decimal as an integer.

  * `number` can be either a float, Decimal or integer although an integer has
    no fraction part and will therefore always return 0.

  ## Examples

      iex> Cldr.Math.fraction_as_integer(123.456)
      456

      iex> Cldr.Math.fraction_as_integer(Decimal.new("123.456"))
      456

      iex> Cldr.Math.fraction_as_integer(1999)
      0
  """
  @spec fraction_as_integer(Math.number_or_decimal | {list, list, 1 | -1}) :: integer
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

  @doc """
  Returns the number of decimal digits in the integer
  part of a number.

  * `number` can be an integer, float or `Decimal` or
  a list (which is assumed to contain digits).

  ## Examples

      iex> Cldr.Math.number_of_integer_digits(1234)
      4

      iex> Cldr.Math.number_of_integer_digits(Decimal.new("123456789"))
      9

      iex> Cldr.Math.number_of_integer_digits(1234.456)
      4

      iex> Cldr.Digits.number_of_integer_digits '12345'
      5
  """
  @spec number_of_integer_digits(Math.number_or_decimal) :: integer
  def number_of_integer_digits(%Decimal{} = number) do
    number
    |> Decimal.round(0, :floor)
    |> Decimal.to_integer
    |> number_of_integer_digits
  end

  # +/- 0,xxxxx
  def number_of_integer_digits(number)
  when is_number(number) and number < 1 and number > -1 do
    0
  end

  def number_of_integer_digits(number) when is_float(number) do
    number
    |> trunc
    |> number_of_integer_digits
  end

  # the abs() is required for Elixir 1.3 since Integer.digits() barfs
  # on negative numbers which we can get
  def number_of_integer_digits(number) when is_integer(number) do
    number
    |> Kernel.abs
    |> Integer.digits
    |> Enum.count
  end

  # A decomposed integer might be charlist or a list of integers
  # since for certain transforms this is more efficient.  Note
  # that we are not checking if the list elements are actually
  # digits.
  def number_of_integer_digits(list) when is_list(list) do
    length(list)
  end

  # Processes a tuple returned by Digits.to_tuple
  def number_of_integer_digits({[], _fraction, _sign}) do
    0
  end

  def number_of_integer_digits({integer, _fraction, _sign}) when is_list(integer) do
    number_of_integer_digits(integer)
  end

  @doc """
  Remove trailing zeroes from an integer.

  * `number` must be an integer.

  ## Examples

      iex> Cldr.Math.remove_trailing_zeros(1234000)
      1234
  """
  @spec remove_trailing_zeros(integer) :: integer
  def remove_trailing_zeros(0) do
    0
  end

  def remove_trailing_zeros(number)
  when is_integer(number) do
    if rem(number, 10) != 0 do
      number
    else
      number
      |> div(10)
      |> remove_trailing_zeros()
    end
  end

  def remove_trailing_zeros(number) when is_list(number) do
    Enum.filter number, fn c ->
      c >= ?1 and c <= ?9
    end
  end

  @doc """
  Returns the number of leading zeros in a
  Decimal fraction.

  * `number` is any Decimal number

  Returns the number of leading zeros in a Decimal number
  that is between `-1..1` (ie, has no integer part).  If the
  number is outside `-1..1` it retuns a negative number, the
  `abs` value of which is the number of integer digits in
  the number.

  ## Examples

      iex> Cldr.Math.number_of_leading_zeros(Decimal.new(0.0001))
      3

      iex> Cldr.Math.number_of_leading_zeros(Decimal.new(3.0001))
      -1
  """
  @spec number_of_leading_zeros(%Decimal{}) :: integer
  def number_of_leading_zeros(%Decimal{coef: coef, exp: exp}) do
    abs(exp) - number_of_integer_digits(coef)
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

  @spec to_tuple(Decimal.t | number) :: {List.t, List.t, integer}
  def to_tuple(number) do
    {mantissa, exp, sign} = to_digits(number)
    mantissa = cond do
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
  def to_digits(0.0), do: {[0], 1, true}
  def to_digits(float) when is_number(float) do
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
    if exp == 0 do
      {digits, exp, sign}
    else
      {digits, length(digits) + exp, sign}
    end
  end

  @doc """
  Takes a list of digits and coverts them back to a number of the same
  type as `number`
  """
  def to_number(digits, number) when is_integer(number),   do: to_integer(digits)
  def to_number(digits, number) when is_float(number),     do: to_float(digits)
  def to_number(digits, %Decimal{}),                       do: to_decimal(digits)

  def to_number(digits, :integer),                         do: to_integer(digits)
  def to_number(digits, :float),                           do: to_float(digits)
  def to_number(digits, :decimal),                         do: to_decimal(digits)

  def to_integer({digits, place, sign}) do
    {int_digits, _fraction_digits} = Enum.split(digits, place)
    Integer.undigits(int_digits) * sign
  end

  def to_float({digits, place, sign}) do
    Integer.undigits(digits) / :math.pow(10, length(digits) - place) * sign
  end

  def to_decimal({digits, place, sign}) do
    %Decimal{coef: Integer.undigits(digits), exp: place - length(digits), sign: sign}
  end

  ############################################################################
  # The following functions are Elixir translations of the original paper:
  # "Printing Floating-Point Numbers Quickly and Accurately"
  # See the paper for further explanation

  docp """
  Set initial values {r, s, m+, m-}
  based on table 1 from FP-Printing paper
  Assumes frac is scaled to integer (and exponent scaled appropriately)
  """
  defp flonum(float, frac, exp) do
    round = Integer.is_even(frac)
    if exp >= 0 do
      b_exp = bsl(1, exp)
      if frac !== @two52 do
        scale((frac * b_exp * 2), 2, b_exp, b_exp, round, round, float)
      else
        scale((frac * b_exp * 4), 4, (b_exp * 2), b_exp, round, round, float)
      end
    else
      if (exp === @min_e) or (frac !== @two52) do
        scale((frac * 2), bsl(1, (1 - exp)), 1, 1, round, round, float)
      else
        scale((frac * 4), bsl(1, (2 - exp)), 2, 1, round, round, float)
      end
    end
  end

  def scale(r, s, m_plus, m_minus, low_ok, high_ok, float) do
    # TODO: Benchmark removing the log10 and using the approximation given in original paper?
    est = trunc(Float.ceil(:math.log10(abs(float)) - 1.0e-10))
    if est >= 0 do
      fixup(r, s * power_of_10(est), m_plus, m_minus, est, low_ok, high_ok, float)
    else
      scale = power_of_10(-est)
      fixup(r * scale, s, m_plus * scale, m_minus * scale, est, low_ok, high_ok, float)
    end
  end

  def fixup(r, s, m_plus, m_minus, k, low_ok, high_ok, float) do
    too_low = if high_ok, do: (r + m_plus) >= s, else: (r + m_plus) > s

    if too_low do
      {generate(r, s, m_plus, m_minus, low_ok, high_ok), (k + 1), sign(float)}
    else
      {generate(r * 10, s, m_plus * 10, m_minus * 10, low_ok, high_ok), k, sign(float)}
    end
  end

  defp generate(r, s, m_plus, m_minus, low_ok, high_ok) do
    d = div r, s
    r = rem r, s

    tc1 = if low_ok,  do: r <= m_minus,       else: r < m_minus
    tc2 = if high_ok, do: (r + m_plus) >= s,  else: (r + m_plus) > s

    if not(tc1) do
      if not(tc2) do
        [d | generate(r * 10, s, m_plus * 10, m_minus * 10, low_ok, high_ok)]
      else
        [d + 1]
      end
    else
      if not(tc2) do
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

  docp """
  The frexp() function is as per the clib function with the same name. It breaks
  the floating-point number value into a normalized fraction and an integral
  power of 2.

  Returns {frac, exp}, where the magnitude of frac is in the interval
  [1/2, 1) or 0, and value = frac*(2^exp).
  """
  defp frexp(value) do
    << sign::1, exp::11, frac::52 >> = << value::float >>
    frexp(sign, frac, exp)
  end

  defp frexp(_Sign, 0, 0) do
    {0.0, 0}
  end

  # Handle denormalised values
  defp frexp(sign, frac, 0) do
    exp = bitwise_length(frac)
    <<f::float>> = <<sign::1, @float_bias::11, (frac-1)::52>>
    {f, -(@float_bias) - 52 + exp}
  end

  # Handle normalised values
  defp frexp(sign, frac, exp) do
    <<f::float>> = <<sign::1, @float_bias::11, frac::52>>
    {f, exp - @float_bias}
  end

  docp """
  Return the number of significant bits needed to store the given number
  """
  defp bitwise_length(value) do
    bitwise_length(value, 0)
  end

  defp bitwise_length(0, n), do: n
  defp bitwise_length(value, n), do: bitwise_length(bsr(value, 1), n+1)

  defp sign(float) when float < 0, do: -1
  defp sign(_float), do: 1

  # Precompute powers of 10 up to 10^326
  # FIXME: duplicating existing function in Float, which only goes up to 15.
  Enum.reduce 0..326, 1, fn x, acc ->
    defp power_of_10(unquote(x)), do: unquote(acc)
    acc * 10
  end

end