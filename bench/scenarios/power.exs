defmodule Power.Bench do
  import Cldr.Number.Math, only: [mod: 2]

  @default_rounding 3
  @zero Decimal.new(0)
  @one Decimal.new(1)
  @two Decimal.new(2)
  @minus_one Decimal.new(-1)
  @ten Decimal.new(10)


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
  # adjusting the exponent
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

  # Alternative looping strategy
  def power2(number, n)
  when is_number(number) and is_number(n) do
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
