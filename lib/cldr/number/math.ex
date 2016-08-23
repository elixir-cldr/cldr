# http://icu-project.org/apiref/icu4c/classRuleBasedNumberFormat.html
defmodule Cldr.Number.Math do
  @moduledoc """
  Math helper functions for number formatting
  """

  @default_rounding 3

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

  def fraction_as_integer(fraction, rounding) when is_float(fraction) and fraction > 1.0 do
    fraction_as_integer(fraction - trunc(fraction), rounding)
  end
  def fraction_as_integer(fraction, rounding) when is_float(fraction) do
    do_fraction_as_integer(fraction, rounding)
  end

  @decimal_10 Decimal.new(10)
  def fraction_as_integer(fraction, rounding) when is_map(fraction) do
    if Decimal.cmp(fraction, Decimal.new(1)) == :gt do
      fraction
      |> Decimal.sub(Decimal.round(fraction, 0, :floor))
      |> fraction_as_integer(rounding)
    else
      do_fraction_as_integer(fraction, rounding)
    end
  end

  def fraction_as_integer(fraction, _rounding) when is_integer(fraction) do
    0
  end


  @doc """
  Returns the number of decimal digits in the integer
  part of a number.

  `number` can be an `integer`. `Decimal` or `float`.

  ## Examples

      iex(10)> Cldr.Number.Math.number_of_integer_digits(1234)
      4

      iex(11)> Cldr.Number.Math.number_of_integer_digits(Decimal.new("123456789"))
      9

      iex(15)> Cldr.Number.Math.number_of_integer_digits(1234.456)
      4
  """
  def number_of_integer_digits(number) when is_integer(number) do
    do_number_of_integer_digits(number, 0)
  end

  def number_of_integer_digits(number) when is_float(number) do
    number
    |> trunc
    |> do_number_of_integer_digits(0)
  end

  def number_of_integer_digits(%Decimal{} = number) do
    number
    |> Decimal.round(0, :floor)
    |> Decimal.to_integer
    |> do_number_of_integer_digits(0)
  end

  @doc """
  Remove trailing zeroes from an integer.

  `number` must be an integer.

  ## Examples

      iex> Cldr.Number.Math.remove_trailing_zeroes(1234000)
      1234
  """
  def remove_trailing_zeroes(number) when is_integer(number) and number == 0, do: number
  def remove_trailing_zeroes(number) when is_integer(number) do
    if rem(number, 10) != 0 do
      number
    else
      number
      |> div(10)
      |> remove_trailing_zeroes()
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
  @spec mod(float | %Decimal{}, integer | float | %Decimal{}) :: float | %Decimal{}
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
  """
  @spec to_float(%Decimal{}) :: float
  def to_float(decimal) do
    decimal.sign * decimal.coef * 1.0 * :math.pow(10, decimal.exp)
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
      |> Decimal.mult(@decimal_10)
      |> do_fraction_as_integer(rounding)
    end
  end

  defp do_number_of_integer_digits(number, count) when number == 0 do
    count
  end

  defp do_number_of_integer_digits(number, count) do
    number
    |> div(10)
    |> do_number_of_integer_digits(count + 1)
  end

  @docp """
  Many thanks to:
  http://stackoverflow.com/questions/202302/rounding-to-an-arbitrary-number-of-significant-digits
  """
  def round_significant(num, n) when is_float(num) or is_integer(num) do
    num = if num < 0, do: -num, else: num
    d = Float.ceil(:math.log10(num))
    power = n - d

    magnitude = :math.pow(10, power)
    shifted = Float.round(num * magnitude)
    rounded = shifted / magnitude

    if is_integer(num) do
      trunc(rounded)
    else
      rounded
    end
  end

  def round_significant(%Decimal{sign: sign} = num, n) when sign < 0 do
    round_significant(Decimal.abs(num), n)
  end

  @ten Decimal.new(10)
  def round_significant(%Decimal{sign: sign} = num, n) when sign > 0 do
    d = num |> log10 |> Decimal.round(0, :ceiling)
    raised = n |> Decimal.new |> Decimal.sub(d)

    magnitude = power(@ten, raised)
    shifted = num |> Decimal.mult(magnitude) |> Decimal.round(0)
    Decimal.div(shifted, magnitude)
  end

  @doc """
  Return the log10 of a number.

  For Decimals the number if converted to a float then the
  BIF :math.log10 is called and the result converted back
  to a decimal.  This is definitely not optimal.

  ## Example

    iex> Cldr.Number.Math.log10(100)
    2.0

    iex> Cldr.Number.Math.log10(123)
    2.089905111439398
  """
  def log10(number) when is_number(number) do
    :math.log10(number)
  end

  def log10(%Decimal{} = number) do
   to_float(number) |> :math.log10 |> Decimal.new
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

  # For Decimals
  @one Decimal.new(1)
  @two Decimal.new(2)

  # Decimal number and decimal n
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
  def do_power(%Decimal{} = number, %Decimal{coef: coef}, %Decimal{coef: mod}) when mod == 0 and coef == 2 do
    Decimal.mult(number, number)
  end

  def do_power(%Decimal{} = number, %Decimal{coef: coef} = n, %Decimal{coef: mod}) when mod == 0 and coef != 2 do
    power(power(number, Decimal.div(n, @two)), @two)
  end

  def do_power(%Decimal{} = number, %Decimal{} = n, _mod) do
    Decimal.mult(number, power(number, Decimal.sub(n, @one)))
  end

  # Decimal number but integer n
  def do_power(%Decimal{} = number, n, mod) when is_number(n) and mod == 0 and n == 2 do
    Decimal.mult(number, number)
  end

  def do_power(%Decimal{} = number, n, mod) when is_number(n) and mod == 0 and n != 2 do
    power(power(number, n / 2), 2)
  end

  def do_power(%Decimal{} = number, n, _mod) when is_number(n) do
    Decimal.mult(number, power(number, n - 1))
  end

  # integer/float number and integer/float n
  def do_power(number, n, mod) when is_number(n) and mod == 0 and n == 2 do
    number * number
  end

  def do_power(number, n, mod)  when is_number(n) and mod == 0 and n != 2 do
    power(power(number, n / 2), 2)
  end

  def do_power(number, n, _mod) do
    number * power(number, n - 1)
  end

  # Alternative looping strategy
  def power2(number, n) when is_number(number) and is_number(n) do
    Enum.reduce 1..(n - 1), number, fn (_i, acc) ->
      acc * number
    end
  end

  def power2(%Decimal{} = number, %Decimal{coef: coef}) do
    Enum.reduce 1..(coef - 1), number, fn (_i, acc) ->
      Decimal.mult(acc, number)
    end
  end

end
