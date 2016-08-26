# http://icu-project.org/apiref/icu4c/classRuleBasedNumberFormat.html
defmodule Cldr.Number.Math do
  @moduledoc """
  Math helper functions for number formatting
  """

  @default_rounding 3
  @zero Decimal.new(0)
  @one Decimal.new(1)
  @two Decimal.new(2)
  @minus_one Decimal.new(-1)
  @ten Decimal.new(10)

  @doc """
  Returns the default rounding used by fraction_as_integer/2
  and any other Cldr function that takes a `rounding` argument.
  """
  def default_rounding do
    @default_rounding
  end

  @doc """
  Returns the fractional part of a float, decimal as an integer.

  * `number` can be either a `float`, `Decimal` or `integer` although
  an integer has no fraction part and will therefore always return 0.

  * `rounding` is the precision applied on each internal iteration as
  the fraction is converted to an integer.  The default rounding is 3.

  ## Examples

      iex> Cldr.Number.Math.fraction_as_integer(123.456)
      456

      iex> Cldr.Number.Math.fraction_as_integer(123.456, 2)
      46

      iex> Cldr.Number.Math.fraction_as_integer(Decimal.new("123.456"), 3)
      456

      iex> Cldr.Number.Math.fraction_as_integer(1999, 3)
      0
  """
  def fraction_as_integer(fraction, rounding \\ @default_rounding)

  def fraction_as_integer(fraction, rounding)
  when is_float(fraction) and fraction > 1.0 do
    fraction_as_integer(fraction - trunc(fraction), rounding)
  end

  def fraction_as_integer(fraction, rounding) when is_float(fraction) do
    do_fraction_as_integer(fraction, rounding)
  end

  def fraction_as_integer(fraction, rounding) when is_map(fraction) do
    if Decimal.cmp(fraction, Decimal.new(1)) == :gt do
      fraction
      |> Decimal.sub(Decimal.round(fraction, 0, :floor))
      |> fraction_as_integer(rounding)
    else
      do_fraction_as_integer(fraction, rounding)
    end
  end

  def fraction_as_integer(fraction, _rounding)
  when is_integer(fraction) do
    0
  end

  defp do_fraction_as_integer(fraction, rounding) when is_float(fraction) do
    truncated_fraction = trunc(fraction)
    if truncated_fraction == fraction do
      truncated_fraction
    else
      fraction
      |> Float.round(rounding)
      |> Kernel.*(10)
      |> do_fraction_as_integer(rounding)
    end
  end

  defp do_fraction_as_integer(fraction, rounding) when is_map(fraction) do
    truncated_fraction = Decimal.round(fraction, 0, :floor)
    if Decimal.equal?(truncated_fraction, fraction) do
      truncated_fraction |> Decimal.to_integer
    else
      fraction
      |> Decimal.round(rounding)
      |> Decimal.mult(@ten)
      |> do_fraction_as_integer(rounding)
    end
  end

  @doc """
  Returns the number of decimal digits in the integer
  part of a number.

  * `number` can be an `integer`. `Decimal` or `float`.

  ## Examples

      iex(10)> Cldr.Number.Math.number_of_integer_digits(1234)
      4

      iex(11)> Cldr.Number.Math.number_of_integer_digits(Decimal.new("123456789"))
      9

      iex(15)> Cldr.Number.Math.number_of_integer_digits(1234.456)
      4
  """
  def number_of_integer_digits(%Decimal{exp: exp} = number) when exp < 0 do
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

  def number_of_integer_digits(%Decimal{} = number) do
    number
    |> Decimal.to_integer
    |> number_of_integer_digits
  end

  def number_of_integer_digits(number) when is_float(number) do
    number
    |> trunc
    |> number_of_integer_digits
  end

  def number_of_integer_digits(number) when is_integer(number) do
    Integer.digits(number)
    |> Enum.count
  end

  @doc """
  Remove trailing zeroes from an integer.

  * `number` must be an integer.

  ## Examples

      iex> Cldr.Number.Math.remove_trailing_zeros(1234000)
      1234
  """
  @spec remove_trailing_zeros(integer) :: integer
  def remove_trailing_zeros(number)
  when is_integer(number) and number == 0 do
    number
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

  @doc """
  Check if the `number` is within a `range`.

  `number` can be either an `integer` or `float`.
  When an integer, the comparison is made using the
  standard Elixir `in` operator.

  When `number` is a `float` the comparison is made
  using the `>=` and `<=` operators on the range
  endpoints.

  *Since this function is only provided to support plural
  rules, the float comparison is only valid if the
  float has no fractional part.*

  ## Examples

      iex> Cldr.Number.Math.within(2.0, 1..3)
      true

      iex> Cldr.Number.Math.within(2.1, 1..3)
      false
  """
  @spec within(number, integer) :: boolean
  def within(number, range) when is_integer(number) do
    number in range
  end

  # When checking if a decimal is in a range it is only
  # valid if there are no decimal places
  def within(number, first..last) when is_float(number) do
    number == trunc(number) && number >= first && number <= last
  end

  @doc """
  Calculates the modulo of a number (integer, float or decimal).

  Note that this function uses `floored division` whereas the builtin `rem`
  function uses `truncated division`. See `Decimal.rem/2` if you want a
  `truncated division` function for decimals that will return the same value as
  the BIF `:math.rem/2`

  See https://en.wikipedia.org/wiki/Modulo_operation

  ## Examples

      iex> Cldr.Number.Math.mod(1234.0, 5)
      4.0

      iex> Cldr.Number.Math.mod(Decimal.new("1234.456"), 5)
      #Decimal<4.456>

      iex> Cldr.Number.Math.mod(Decimal.new(123.456), Decimal.new(3.4))
      #Decimal<1.056>

      iex> Cldr.Number.Math.mod Decimal.new(123.456), 3.4
      #Decimal<1.056>
  """
  @spec mod(float | %Decimal{}, integer | float | %Decimal{}) ::
    float | %Decimal{}
  def mod(number, modulus) when is_float(number) do
    number - (Float.floor(number / modulus) * modulus)
  end

  def mod(number, modulus) when is_integer(number) do
    modulo = number
    |> Kernel./(modulus)
    |> Float.floor
    |> Kernel.*(modulus)
    number - modulo
  end

  def mod(%Decimal{} = number, %Decimal{} = modulus) do
    modulo = number
    |> Decimal.div(modulus)
    |> Decimal.round(0, :floor)
    |> Decimal.mult(modulus)
    Decimal.sub(number, modulo)
  end

  def mod(%Decimal{} = number, modulus) when is_number(modulus) do
    mod(number, Decimal.new(modulus))
  end

  @doc """
  Convert a decimal to a float

  * decimal must be a `Decimal`

  This is very likely to lose precision - lots of numbers won't
  make the round trip conversion.  Use with care
  """
  @spec to_float(%Decimal{}) :: float
  def to_float(decimal) do
    decimal.sign * decimal.coef * 1.0 * :math.pow(10, decimal.exp)
  end

  @doc """
  Rounds a number to a specified number of significant digits.

  This is not the same as rounding decimals which is performed
  by `Decimal.round/2`.

  * `number` is a float, integer or Decimal

  * `n` is the number of significant digits to be rounded to

  ## Examples

      iex> Cldr.Number.Math.round_significant(3.14159, 3)
      3.14

      iex> Cldr.Number.Math.round_significant(10.3554, 1)
      10.0

      iex> Cldr.Number.Math.round_significant(0.00035, 1)
      0.0004

  ## Further reading

  * 3.14159 has six significant digits (all the numbers give you useful
  information)

  * 1000 has one significant digit (only the 1 is interesting; you don't know
  anything for sure about the hundreds, tens, or units places; the zeroes may
  just be placeholders; they may have rounded something off to get this value)

  * 1000.0 has five significant digits (the ".0" tells us something interesting
  about the presumed accuracy of the measurement being made: that the
  measurement is accurate to the tenths place, but that there happen to be zero
  tenths)

  * 0.00035 has two significant digits (only the 3 and 5 tell us something; the
  other zeroes are placeholders, only providing information about relative size)

  * 0.000350 has three significant digits (that last zero tells us that the
  measurement was made accurate to that last digit, which just happened to have
  a value of zero)

  * 1006 has four significant digits (the 1 and 6 are interesting, and we have
  to count the zeroes, because they're between the two interesting numbers)

  * 560 has two significant digits (the last zero is just a placeholder)

  * 560. (notice the "point" after the zero) has three significant digits (the
  decimal point tells us that the measurement was made to the nearest unit, so
  the zero is not just a placeholder) 56

  * 0.0 has four significant digits (the zero in the tenths place means that the
  measurement was made accurate to the tenths place, and that there just happen
  to be zero tenths; the 5 and 6 give useful information, and the other zero is
  between significant digits, and must therefore also be counted)

  Many thanks to [Stackoverflow]
  (http://stackoverflow.com/questions/202302/rounding-to-an-arbitrary-number-of-significant-digits)
  """
  @spec round_significant(number, integer) :: number
  def round_significant(number, n) when is_number(number) do
    sign = if number < 0, do: -1, else: 1
    number = abs(number)
    d = Float.ceil(:math.log10(number))
    power = n - d

    magnitude = :math.pow(10, power)
    shifted = Float.round(number * magnitude)
    rounded = shifted / magnitude

    sign * if is_integer(number) do
      trunc(rounded)
    else
      rounded
    end
  end

  def round_significant(%Decimal{sign: sign} = number, n) when sign < 0 do
    round_significant(Decimal.abs(number), n) |> Decimal.minus
  end

  def round_significant(%Decimal{sign: sign} = number, n) when sign > 0 do
    d = number |> log10 |> Decimal.round(0, :ceiling)
    raised = n |> Decimal.new |> Decimal.sub(d)

    magnitude = power(@ten, raised)
    shifted = number |> Decimal.mult(magnitude) |> Decimal.round(0)
    Decimal.mult(Decimal.div(shifted, magnitude), Decimal.new(sign))
  end

  @doc """
  Return the natural log of a number.

  * `number` is an integer, a float or a Decimal

  For `integer` and `float` it calls the
  BIF `:math.log10/1` function.

  For `Decimal` is is rolled by hand.

  ## Examples

      iex> Cldr.Number.Math.log(123)
      4.812184355372417

      iex> Cldr.Number.Math.log(Decimal.new(9000))
      #Decimal<9.103886231350952380952380952>
  """
  def log(number) when is_number(number) do
    :math.log(number)
  end

  @ln10 Decimal.new(2.30258509299)
  def log(%Decimal{} = number) do
    {mantissa, exp} = mantissa_exponent(number)
    exp = Decimal.new(exp)
    ln1 = Decimal.mult(exp, @ln10)

    sqrt_mantissa = sqrt(mantissa)
    y = Decimal.div(Decimal.sub(sqrt_mantissa, @one),
      Decimal.add(sqrt_mantissa, @one))
    ln2 = y
    |> log_polynomial([3,5,7])
    |> Decimal.add(y)
    |> Decimal.mult(@two)

    Decimal.add(Decimal.mult(@two, ln2), ln1)
  end

  def log_polynomial(%Decimal{} = value, iterations \\ []) do
    Enum.reduce iterations, @zero, fn (i, acc) ->
      i = Decimal.new(i)
      value
      |> power(i)
      |> Decimal.div(i)
      |> Decimal.add(acc)
    end
  end

  @doc """
  Return the log10 of a number.

  * `number` is an integer, a float or a Decimal

  For `integer` and `float` is calls the
  BIF `:math.log10/1` function.

  For `Decimal` is is rolled by hand.

  ## Examples

      iex> Cldr.Number.Math.log10(100)
      2.0

      iex> Cldr.Number.Math.log10(123)
      2.089905111439398

      iex> Cldr.Number.Math.log10(Decimal.new(9000))
      #Decimal<3.953767554157656512064441441>
  """
  # For floats and ints
  def log10(number) when is_number(number) do
    :math.log10(number)
  end

  def log10(%Decimal{} = number) do
    Decimal.div(log(number), @ln10)
  end

  @doc """
  Raises a number to a power.

  Raises a number to a power using the the binary method.  For further
  reading see
  [this article](http://videlalvaro.github.io/2014/03/the-power-algorithm.html)

  ## Examples

      iex> Cldr.Number.Math.power(10, 2)
      100

      iex> Cldr.Number.Math.power(10, 3)
      1000

      iex> Cldr.Number.Math.power(10, 4)
      10000

      iex> Cldr.Number.Math.power(2, 10)
      1024
  """

  # Decimal number and decimal n
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

  # For a decimal we can short cut the multiplcations by just
  # adjusting the exponent when the coefficient is 10
  def power(%Decimal{coef: 10, sign: sign, exp: exp}, n) do
    %Decimal{coef: 10, sign: sign, exp: exp + n - 1}
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
  def do_power(%Decimal{} = number, %Decimal{coef: coef}, %Decimal{coef: mod})
  when mod == 0 and coef == 2 do
    Decimal.mult(number, number)
  end

  def do_power(%Decimal{} = number, %Decimal{coef: coef} = n, %Decimal{coef: mod})
  when mod == 0 and coef != 2 do
    power(power(number, Decimal.div(n, @two)), @two)
  end

  def do_power(%Decimal{} = number, %Decimal{} = n, _mod) do
    Decimal.mult(number, power(number, Decimal.sub(n, @one)))
  end

  # Decimal number but integer n
  def do_power(%Decimal{} = number, n, mod)
  when is_number(n) and mod == 0 and n == 2 do
    Decimal.mult(number, number)
  end

  def do_power(%Decimal{} = number, n, mod)
  when is_number(n) and mod == 0 and n != 2 do
    power(power(number, n / 2), 2)
  end

  def do_power(%Decimal{} = number, n, _mod)
  when is_number(n) do
    Decimal.mult(number, power(number, n - 1))
  end

  # integer/float number and integer/float n
  def do_power(number, n, mod)
  when is_number(n) and mod == 0 and n == 2 do
    number * number
  end

  def do_power(number, n, mod)
  when is_number(n) and mod == 0 and n != 2 do
    power(power(number, n / 2), 2)
  end

  def do_power(number, n, _mod) do
    number * power(number, n - 1)
  end

  @doc """
  Returns the tuple `{mantissa, exponent}` for a `%Decimal{}` number
  where `mantissa` is a `Decimal` and `exponent` is an integer.

  Returns a tuple such that `0 > mantissa < 10` and an exponent such that
  `mantissa * 10**exponent == number`

  * `number` is a `Decimal`

  ## Examples

      Cldr.Number.Math.mantissa_exponent(Decimal.new(1.23004))
      {#Decimal<1.23004>, 0}

      Cldr.Number.Math.mantissa_exponent(Decimal.new(465))
      {#Decimal<4.65>, 2}

      Cldr.Number.Math.mantissa_exponent(Decimal.new(-46.543))
      {#Decimal<-4.6543>, 1}
  """
  @spec mantissa_exponent(%Decimal{}) :: {%Decimal{}, integer}
  def mantissa_exponent(%Decimal{} = number) do
    if between_one_and_minus_one(number) do
      coef_digits = number_of_integer_digits(number.coef)
      leading_zeros = abs(number.exp) - coef_digits
      exp = -(leading_zeros + 1)
      mantissa = %Decimal{coef: number.coef, sign: number.sign, exp: -coef_digits + 1}
      {mantissa, exp}
    else
      coef_digits = number_of_integer_digits(number.coef)
      exp = coef_digits + number.exp - 1
      mantissa = %Decimal{sign: number.sign, coef: number.coef, exp: number.exp - exp}
      {mantissa, exp}
    end
  end

  defp between_one_and_minus_one(number) do
    (Decimal.cmp(number, @minus_one) == :gt && Decimal.cmp(number, @one) == :lt)
    || Decimal.cmp(number, @one) == :eq
    || Decimal.cmp(number, @minus_one) == :eq
  end

  @doc """
  Newton's method of calculating a square root

    * `number` is a `Decimal`

  We convert the Decimal to a float and take its `sqrt`
  using `:math.sqrt` only to get an initial estimate.
  The means typically we are only two iterations from
  a solution so the slight hack improves performance
  without sacrificing precions.

  ## Examples

      iex> Cldr.Number.Math.sqrt(Decimal.new(9))
      #Decimal<3.0>

      iex> Cldr.Number.Math.sqrt(Decimal.new(9.869))
      #Decimal<3.141496458696078173887197038>
  """
  @decimal_precision Decimal.new(0.0001)
  def sqrt(%Decimal{sign: sign} = number) when sign == -1 do
    raise ArgumentError, "bad argument in arithmetic expression #{inspect number}"
  end

  # Get an initial estimate of the sqrt by using the built in `:math.sqrt`
  # function.  This means typically its only two iterations to get the default
  # precision.
  def sqrt(%Decimal{} = number, %Decimal{} = precision \\ @decimal_precision) do
    initial_estimate = number
    |> to_float
    |> :math.sqrt
    |> Decimal.new

    do_sqrt(number, initial_estimate, @decimal_precision, precision)
  end

  defp do_sqrt(%Decimal{} = number, %Decimal{} = estimate,
      %Decimal{} = old_estimate, %Decimal{} = precision) do
    diff = estimate
    |> Decimal.sub(old_estimate)
    |> Decimal.abs

    if Decimal.cmp(diff, old_estimate) == :lt
      || Decimal.cmp(diff, old_estimate) == :eq do
      estimate
    else
      new_estimate = Decimal.add(Decimal.div(estimate, @two),
        Decimal.div(number, Decimal.mult(@two, estimate)))
      do_sqrt(number, new_estimate, estimate, precision)
    end
  end
end
