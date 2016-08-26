defmodule Number.Int.Digits.Bench do
  import Cldr.Number.Math, only: [log10: 1]
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

  # Repeated division by 10 solution

  def number_of_integer_digits4(number) when is_integer(number) do
    do_number_of_integer_digits(number, 0)
  end

  def number_of_integer_digits4(number) when is_float(number) do
    number
    |> trunc
    |> do_number_of_integer_digits(0)
  end

  def number_of_integer_digits4(%Decimal{} = number) do
    number
    |> Decimal.round(0, :floor)
    |> Decimal.to_integer
    |> do_number_of_integer_digits(0)
  end

  defp do_number_of_integer_digits(number, count) when number == 0 do
    count
  end

  defp do_number_of_integer_digits(number, count) do
    number
    |> div(10)
    |> do_number_of_integer_digits(count + 1)
  end

  # floor(log10(number)) + 1 Method

  def number_of_integer_digits2(%Decimal{} = number) do
    number
    |> log10
    |> Decimal.round(0, :floor)
    |> Decimal.to_integer
    |> Kernel.+(1)
  end

  def number_of_integer_digits2(number) do
    number
    |> log10
    |> Float.floor
    |> Kernel.+(1)
  end

  # Division table method

  @list [{10000000000000000, 16}, {100000000, 8}, {10000, 4}, {100, 2}, {10, 1}]
  def number_of_integer_digits3(number) when number > 10000000000000000 do
    raise ArgumentError, message: "Can't handle numbers that big!"
  end

  def number_of_integer_digits3(number) do
    {_, num} = Enum.reduce @list, {number, 2}, fn {marker, add}, {int, digits} ->
      if int > marker do
        {int / marker, digits + add}
      else
        {int, digits}
      end
    end
    num
  end
end