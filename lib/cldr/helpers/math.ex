defmodule Cldr.Math do
  @moduledoc """
  Math helper functions for number formatting
  """
  alias Cldr.Digits
  require Integer

  @type rounding ::
          :down
          | :half_up
          | :half_even
          | :ceiling
          | :floor
          | :half_down
          | :up

  @type number_or_decimal :: number | %Decimal{}
  @type normalised_decimal :: {%Decimal{}, integer}
  @default_rounding 3
  @default_rounding_mode :half_even
  @zero Decimal.new(0)
  @one Decimal.new(1)
  @two Decimal.new(2)
  @ten Decimal.new(10)

  @doc """
  Returns the default number of rounding digits
  """
  @spec default_rounding :: integer
  def default_rounding do
    @default_rounding
  end

  @doc """
  Returns the default rounding mode for rounding operations
  """
  @spec default_rounding_mode :: atom
  def default_rounding_mode do
    @default_rounding_mode
  end

  @doc """
  Check if a `number` is within a `range`.

  * `number` is either an integer or a float.

  When an integer, the comparison is made using the standard Elixir `in`
  operator.

  When `number` is a float the comparison is made using the `>=` and `<=`
  operators on the range endpoints. Note the comparison for a float is only for
  floats that have no fractional part. If a float has a fractional part then
  `within` returns `false`.

  *Since this function is only provided to support plural rules, the float
  comparison is only useful if the float has no fractional part.*

  ## Examples

      iex> Cldr.Math.within(2.0, 1..3)
      true

      iex> Cldr.Math.within(2.1, 1..3)
      false

  """
  @spec within(number, integer | Range.t()) :: boolean
  def within(number, range) when is_integer(number) do
    number in range
  end

  # When checking if a decimal is in a range it is only
  # valid if there are no decimal places
  def within(number, first..last) when is_float(number) do
    number == trunc(number) && number >= first && number <= last
  end

  @doc """
  Calculates the modulo of a number (integer, float or Decimal).

  Note that this function uses `floored division` whereas the builtin `rem`
  function uses `truncated division`. See `Decimal.rem/2` if you want a
  `truncated division` function for Decimals that will return the same value as
  the BIF `rem/2` but in Decimal form.

  See [Wikipedia](https://en.wikipedia.org/wiki/Modulo_operation) for an
  explanation of the difference.

  ## Examples

      iex> Cldr.Math.mod(1234.0, 5)
      4.0

      iex> Cldr.Math.mod(Decimal.new("1234.456"), 5)
      #Decimal<4.456>

      iex> Cldr.Math.mod(Decimal.new(123.456), Decimal.new(3.4))
      #Decimal<1.056>

      iex> Cldr.Math.mod Decimal.new(123.456), 3.4
      #Decimal<1.056>

  """
  @spec mod(number_or_decimal, number_or_decimal) :: number_or_decimal

  def mod(number, modulus) when is_float(number) and is_number(modulus) do
    number - Float.floor(number / modulus) * modulus
  end

  def mod(number, modulus) when is_integer(number) and is_integer(modulus) do
    modulo =
      number
      |> Integer.floor_div(modulus)
      |> Kernel.*(modulus)

    number - modulo
  end

  def mod(number, modulus) when is_integer(number) and is_number(modulus) do
    modulo =
      number
      |> Kernel./(modulus)
      |> Float.floor()
      |> Kernel.*(modulus)

    number - modulo
  end

  def mod(%Decimal{} = number, %Decimal{} = modulus) do
    modulo =
      number
      |> Decimal.div(modulus)
      |> Decimal.round(0, :floor)
      |> Decimal.mult(modulus)

    Decimal.sub(number, modulo)
  end

  def mod(%Decimal{} = number, modulus) when is_number(modulus) do
    mod(number, Decimal.new(modulus))
  end

  @doc """
  Returns the adjusted modulus of `x` and `y`
  """
  @spec amod(number_or_decimal, number_or_decimal) :: number_or_decimal
  @decimal_zero Decimal.new(0)
  def amod(x, y) do
    case mod = mod(x, y) do
      %Decimal{} = decimal_mod ->
        if Decimal.cmp(decimal_mod, @decimal_zero) == :eq, do: y, else: mod

      _ ->
        if mod == 0, do: y, else: mod
    end
  end

  @doc """
  Returns the remainder and dividend of two integers.
  """
  @spec div_mod(integer, integer) :: {integer, integer}
  def div_mod(int1, int2) do
    div = div(int1, int2)
    mod = int1 - div * int2
    {div, mod}
  end

  @doc """
  Convert a Decimal to a float

  * `decimal` must be a Decimal

  This is very likely to lose precision - lots of numbers won't
  make the round trip conversion.  Use with care.  Actually, better
  not to use it at all.
  """
  @spec to_float(%Decimal{}) :: float
  def to_float(%Decimal{sign: sign, coef: coef, exp: exp}) do
    sign * coef * 1.0 * power_of_10(exp)
  end

  @doc """
  Rounds a number to a specified number of significant digits.

  This is not the same as rounding fractional digits which is performed
  by `Decimal.round/2` and `Float.round`

  * `number` is a float, integer or Decimal

  * `n` is the number of significant digits to which the `number` should be
    rounded

  ## Examples

      iex> Cldr.Math.round_significant(3.14159, 3)
      3.14

      iex> Cldr.Math.round_significant(10.3554, 1)
      10.0

      iex> Cldr.Math.round_significant(0.00035, 1)
      0.0004

  ## More on significant digits

  * 3.14159 has six significant digits (all the numbers give you useful
    information)

  * 1000 has one significant digit (only the 1 is interesting; you don't know
    anything for sure about the hundreds, tens, or units places; the zeroes may
    just be placeholders; they may have rounded something off to get this value)

  * 1000.0 has five significant digits (the ".0" tells us something interesting
    about the presumed accuracy of the measurement being made: that the
    measurement is accurate to the tenths place, but that there happen to be
    zero tenths)

  * 0.00035 has two significant digits (only the 3 and 5 tell us something; the
    other zeroes are placeholders, only providing information about relative
    size)

  * 0.000350 has three significant digits (that last zero tells us that the
    measurement was made accurate to that last digit, which just happened to
    have a value of zero)

  * 1006 has four significant digits (the 1 and 6 are interesting, and we have
    to count the zeroes, because they're between the two interesting numbers)

  * 560 has two significant digits (the last zero is just a placeholder)

  * 560.0 has four significant digits (the zero in the tenths place means that
    the measurement was made accurate to the tenths place, and that there just
    happen to be zero tenths; the 5 and 6 give useful information, and the
    other zero is between significant digits, and must therefore also be
    counted)

  Many thanks to [Stackoverflow](http://stackoverflow.com/questions/202302/rounding-to-an-arbitrary-number-of-significant-digits)
  """
  @spec round_significant(number_or_decimal, integer) :: number_or_decimal
  def round_significant(number, n) when is_number(number) and n <= 0 do
    number
  end

  def round_significant(number, n) when is_number(number) do
    sign = if number < 0, do: -1, else: 1
    number = abs(number)
    d = Float.ceil(:math.log10(number))
    power = n - d

    magnitude = :math.pow(10, power)
    shifted = Float.round(number * magnitude)
    rounded = shifted / magnitude

    sign *
      if is_integer(number) do
        trunc(rounded)
      else
        rounded
      end
  end

  def round_significant(%Decimal{sign: sign} = number, n) when sign < 0 do
    round_significant(Decimal.abs(number), n)
    |> Decimal.minus()
  end

  def round_significant(%Decimal{sign: sign} = number, n) when sign > 0 do
    d =
      number
      |> log10
      |> Decimal.round(0, :ceiling)

    raised =
      n
      |> Decimal.new()
      |> Decimal.sub(d)

    magnitude = power(@ten, raised)

    shifted =
      number
      |> Decimal.mult(magnitude)
      |> Decimal.round(0)

    Decimal.div(shifted, magnitude)
    |> Decimal.mult(Decimal.new(sign))
  end

  @doc """
  Return the natural log of a number.

  * `number` is an integer, a float or a Decimal

  * For integer and float it calls the BIF `:math.log10/1` function.

  * For Decimal the log is rolled by hand.

  ## Examples

      iex> Cldr.Math.log(123)
      4.812184355372417

      iex> Cldr.Math.log(Decimal.new(9000))
      #Decimal<9.103886231350952380952380952>

  """
  @spec log(number_or_decimal) :: number_or_decimal
  def log(number) when is_number(number) do
    :math.log(number)
  end

  @ln10 Decimal.new(2.30258509299)
  def log(%Decimal{} = number) do
    {mantissa, exp} = coef_exponent(number)
    exp = Decimal.new(exp)
    ln1 = Decimal.mult(exp, @ln10)

    sqrt_mantissa = sqrt(mantissa)
    y = Decimal.div(Decimal.sub(sqrt_mantissa, @one), Decimal.add(sqrt_mantissa, @one))

    ln2 =
      y
      |> log_polynomial([3, 5, 7])
      |> Decimal.add(y)
      |> Decimal.mult(@two)

    Decimal.add(Decimal.mult(@two, ln2), ln1)
  end

  defp log_polynomial(%Decimal{} = value, iterations) do
    Enum.reduce(iterations, @zero, fn i, acc ->
      i = Decimal.new(i)

      value
      |> power(i)
      |> Decimal.div(i)
      |> Decimal.add(acc)
    end)
  end

  @doc """
  Return the log10 of a number.

  * `number` is an integer, a float or a Decimal

    * For integer and float it calls the BIF `:math.log10/1` function.

    * For `Decimal`, `log10` is is rolled by hand using the identify `log10(x) =
    ln(x) / ln(10)`

  ## Examples

      iex> Cldr.Math.log10(100)
      2.0

      iex> Cldr.Math.log10(123)
      2.089905111439398

      iex> Cldr.Math.log10(Decimal.new(9000))
      #Decimal<3.953767554157656512064441441>

  """
  @spec log10(number_or_decimal) :: number_or_decimal
  def log10(number) when is_number(number) do
    :math.log10(number)
  end

  def log10(%Decimal{} = number) do
    Decimal.div(log(number), @ln10)
  end

  @doc """
  Raises a number to a integer power.

  Raises a number to a power using the the binary method. There is one
  exception for Decimal numbers that raise `10` to some power. In this case the
  power is calculated by shifting the Decimal exponent which is quite efficient.

  For further reading see
  [this article](http://videlalvaro.github.io/2014/03/the-power-algorithm.html)

  > This function works only with integer exponents!

  ## Examples

      iex> Cldr.Math.power(10, 2)
      100

      iex> Cldr.Math.power(10, 3)
      1000

      iex> Cldr.Math.power(10, 4)
      10000

      iex> Cldr.Math.power(2, 10)
      1024

  """

  # Decimal number and decimal n
  @spec power(number_or_decimal, number_or_decimal) :: number_or_decimal
  def power(%Decimal{} = _number, %Decimal{coef: n}) when n == 0 do
    @one
  end

  def power(%Decimal{} = number, %Decimal{coef: n}) when n == 1 do
    number
  end

  def power(%Decimal{} = number, %Decimal{sign: sign} = n) when sign < 1 do
    Decimal.div(@one, do_power(number, n, mod(n, @two)))
  end

  def power(%Decimal{} = number, %Decimal{} = n) do
    do_power(number, n, mod(n, @two))
  end

  # Decimal number and integer/float n
  def power(%Decimal{} = _number, n) when n == 0 do
    @one
  end

  def power(%Decimal{} = number, n) when n == 1 do
    number
  end

  def power(%Decimal{} = number, n) when n > 1 do
    do_power(number, n, mod(n, 2))
  end

  def power(%Decimal{} = number, n) when n < 0 do
    Decimal.div(@one, do_power(number, abs(n), mod(abs(n), 2)))
  end

  # For integers and floats
  def power(number, n) when n == 0 do
    if is_integer(number), do: 1, else: 1.0
  end

  def power(number, n) when n == 1 do
    number
  end

  def power(number, n) when n > 1 do
    do_power(number, n, mod(n, 2))
  end

  def power(number, n) when n < 1 do
    1 / do_power(number, abs(n), mod(abs(n), 2))
  end

  # Decimal number and decimal n
  defp do_power(%Decimal{} = number, %Decimal{coef: coef}, %Decimal{coef: mod})
       when mod == 0 and coef == 2 do
    Decimal.mult(number, number)
  end

  defp do_power(%Decimal{} = number, %Decimal{coef: coef} = n, %Decimal{coef: mod})
       when mod == 0 and coef != 2 do
    power(power(number, Decimal.div(n, @two)), @two)
  end

  defp do_power(%Decimal{} = number, %Decimal{} = n, _mod) do
    Decimal.mult(number, power(number, Decimal.sub(n, @one)))
  end

  # Decimal number but integer n
  defp do_power(%Decimal{} = number, n, mod)
       when is_number(n) and mod == 0 and n == 2 do
    Decimal.mult(number, number)
  end

  defp do_power(%Decimal{} = number, n, mod)
       when is_number(n) and mod == 0 and n != 2 do
    power(power(number, n / 2), 2)
  end

  defp do_power(%Decimal{} = number, n, _mod)
       when is_number(n) do
    Decimal.mult(number, power(number, n - 1))
  end

  # integer/float number and integer/float n
  defp do_power(number, n, mod)
       when is_number(n) and mod == 0 and n == 2 do
    number * number
  end

  defp do_power(number, n, mod)
       when is_number(n) and mod == 0 and n != 2 do
    power(power(number, n / 2), 2)
  end

  defp do_power(number, n, _mod) do
    number * power(number, n - 1)
  end

  #
  # Precompute powers of 10 up to 10^326
  # FIXME: duplicating existing function in Float, which only goes up to 15.
  Enum.reduce(0..326, 1, fn x, acc ->
    def power_of_10(unquote(x)), do: unquote(acc)
    acc * 10
  end)

  def power_of_10(n) when n < 0 do
    1 / power_of_10(abs(n))
  end

  @doc """
  Returns a tuple representing a number in a normalized form with
  the mantissa in the range `0 < m < 10` and a base 10 exponent.

  * `number` is an integer, float or Decimal

  ## Examples

      Cldr.Math.coef_exponent(Decimal.new(1.23004))
      {#Decimal<1.23004>, 0}

      Cldr.Math.coef_exponent(Decimal.new(465))
      {#Decimal<4.65>, 2}

      Cldr.Math.coef_exponent(Decimal.new(-46.543))
      {#Decimal<-4.6543>, 1}

  """

  # An integer should be returned as a float mantissa
  @spec coef_exponent(number_or_decimal) :: {number_or_decimal, integer}
  def coef_exponent(number) when is_integer(number) do
    {mantissa_digits, exponent} = coef_exponent_digits(number)
    {Digits.to_float(mantissa_digits), exponent}
  end

  # All other numbers are returned as the same type as the parameter
  def coef_exponent(number) do
    {mantissa_digits, exponent} = coef_exponent_digits(number)
    {Digits.to_number(mantissa_digits, number), exponent}
  end

  @doc """
  Returns a tuple representing a number in a normalized form with
  the mantissa in the range `0 < m < 10` and a base 10 exponent.

  The mantissa is represented as tuple of the form `Digits.t`.

  * `number` is an integer, float or Decimal

  ## Examples

      Cldr.Math.coef_exponent_digits(Decimal.new(1.23004))
      {{[1, 2, 3, 0], 1, 1}, 0}

      Cldr.Math.coef_exponent_digits(Decimal.new(465))
      {{[4, 6, 5], 1, 1}, -1}

      Cldr.Math.coef_exponent_digits(Decimal.new(-46.543))
      {{[4, 6, 5, 4], 1, -1}, 1}

  """
  @spec coef_exponent_digits(number_or_decimal) :: {Digits.t(), integer()}
  def coef_exponent_digits(number) do
    {digits, place, sign} = Digits.to_digits(number)
    {{digits, 1, sign}, place - 1}
  end

  @doc """
  Calculates the square root of a Decimal number using Newton's method.

  * `number` is an integer, float or Decimal.  For integer and float,
  `sqrt` is delegated to the erlang `:math` module.

  We convert the Decimal to a float and take its
  `:math.sqrt` only to get an initial estimate.
  The means typically we are only two iterations from
  a solution so the slight hack improves performance
  without sacrificing precision.

  ## Examples

      iex> Cldr.Math.sqrt(Decimal.new(9))
      #Decimal<3.0>

      iex> Cldr.Math.sqrt(Decimal.new(9.869))
      #Decimal<3.141496458696078173887197038>

  """
  @precision 0.0001
  @decimal_precision Decimal.new(@precision)
  def sqrt(number, precision \\ @precision)

  def sqrt(%Decimal{sign: sign} = number, _precision)
      when sign == -1 do
    raise ArgumentError, "bad argument in arithmetic expression #{inspect(number)}"
  end

  # Get an initial estimate of the sqrt by using the built in `:math.sqrt`
  # function.  This means typically its only two iterations to get the default
  # the sqrt at the specified precision.
  def sqrt(%Decimal{} = number, precision)
      when is_number(precision) do
    initial_estimate =
      number
      |> to_float
      |> :math.sqrt()
      |> Decimal.new()

    decimal_precision = Decimal.new(precision)
    do_sqrt(number, initial_estimate, @decimal_precision, decimal_precision)
  end

  def sqrt(number, _precision) do
    :math.sqrt(number)
  end

  defp do_sqrt(
         %Decimal{} = number,
         %Decimal{} = estimate,
         %Decimal{} = old_estimate,
         %Decimal{} = precision
       ) do
    diff =
      estimate
      |> Decimal.sub(old_estimate)
      |> Decimal.abs()

    if Decimal.cmp(diff, old_estimate) == :lt || Decimal.cmp(diff, old_estimate) == :eq do
      estimate
    else
      Decimal.div(number, Decimal.mult(@two, estimate))

      new_estimate =
        Decimal.add(
          Decimal.div(estimate, @two),
          Decimal.div(number, Decimal.mult(@two, estimate))
        )

      do_sqrt(number, new_estimate, estimate, precision)
    end
  end

  @doc """
  Calculate the nth root of a number.

  * `number` is an integer or a Decimal

  * `nth` is a positive integer

  ## Examples

      iex> Cldr.Math.root Decimal.new(8), 3
      #Decimal<2.0>

      iex> Cldr.Math.root Decimal.new(16), 4
      #Decimal<2.0>

      iex> Cldr.Math.root Decimal.new(27), 3
      #Decimal<3.0>

  """
  def root(%Decimal{} = number, nth) when is_integer(nth) and nth > 0 do
    guess =
      :math.pow(to_float(number), 1 / nth)
      |> Decimal.new()

    do_root(number, Decimal.new(nth), guess)
  end

  def root(number, nth) when is_number(number) and is_integer(nth) and nth > 0 do
    guess = :math.pow(number, 1 / nth)
    do_root(number, nth, guess)
  end

  @root_precision 0.0001
  defp do_root(number, nth, root) when is_number(number) do
    delta = 1 / nth * (number / :math.pow(root, nth - 1)) - root

    if delta > @root_precision do
      do_root(number, nth, root + delta)
    else
      root
    end
  end

  @decimal_root_precision Decimal.new(@root_precision)
  defp do_root(%Decimal{} = number, %Decimal{} = nth, %Decimal{} = root) do
    d1 = Decimal.div(@one, nth)
    d2 = Decimal.div(number, power(root, Decimal.sub(nth, @one)))
    d3 = Decimal.sub(d2, root)
    delta = Decimal.mult(d1, d3)

    if Decimal.cmp(delta, @decimal_root_precision) == :gt do
      do_root(number, nth, Decimal.add(root, delta))
    else
      root
    end
  end

  @doc """
  Round a number to an arbitrary precision using one of several rounding algorithms.

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

  # The canonical function head that takes a number and returns a number.
  def round(number, places \\ 0, mode \\ :half_up) when is_integer(places) and is_atom(mode) do
    number
    |> Digits.to_digits()
    |> round_digits(%{decimals: places, rounding: mode})
    |> Digits.to_number(number)
  end

  # The next function heads operate on decomposed numbers returned
  # by Digits.to_digits.

  # scientific/decimal rounding are the same, we are just varying which
  # digit we start counting from to find our rounding point
  def round_digits(digits_t, options)

  # Passing true for decimal places avoids rounding and uses whatever is necessary
  def round_digits(digits_t, %{scientific: true}), do: digits_t
  def round_digits(digits_t, %{decimals: true}), do: digits_t

  # rounded away all the decimals... return 0
  def round_digits(_, %{scientific: dp}) when dp <= 0, do: {[0], 1, true}
  def round_digits({_, place, _}, %{decimals: dp}) when dp + place <= 0, do: {[0], 1, true}

  def round_digits(digits_t = {_, place, _}, options = %{decimals: dp}) do
    {digits, place, sign} = do_round(digits_t, dp + place - 1, options)
    {List.flatten(digits), place, sign}
  end

  def round_digits(digits_t, options = %{scientific: dp}) do
    {digits, place, sign} = do_round(digits_t, dp, options)
    {List.flatten(digits), place, sign}
  end

  defp do_round({digits, place, positive}, round_at, %{rounding: rounding}) do
    case Enum.split(digits, round_at) do
      {l, [least_sig | [tie | rest]]} ->
        case do_incr(l, least_sig, increment?(positive, least_sig, tie, rest, rounding)) do
          [:rollover | digits] -> {digits, place + 1, positive}
          digits -> {digits, place, positive}
        end

      {l, [least_sig | []]} ->
        {[l, least_sig], place, positive}

      {l, []} ->
        {l, place, positive}
    end
  end

  # Helper functions for round/2-3
  defp do_incr(l, least_sig, false), do: [l, least_sig]
  defp do_incr(l, least_sig, true) when least_sig < 9, do: [l, least_sig + 1]
  # else need to cascade the increment
  defp do_incr(l, 9, true) do
    l
    |> Enum.reverse()
    |> cascade_incr
    |> Enum.reverse([0])
  end

  # cascade an increment of decimal digits which could be rolling over 9 -> 0
  defp cascade_incr([9 | rest]), do: [0 | cascade_incr(rest)]
  defp cascade_incr([d | rest]), do: [d + 1 | rest]
  defp cascade_incr([]), do: [1, :rollover]

  @spec increment?(boolean, non_neg_integer | nil, non_neg_integer | nil, list(), atom()) ::
          boolean
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
