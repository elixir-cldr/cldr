# http://icu-project.org/apiref/icu4c/classRuleBasedNumberFormat.html
defmodule Cldr.Numbers do
  @default_rounding 2
  
  @doc """
  Returns the default rounding used by fraction_as_integer/2
  and any other Cldr function that takes a `rounding` argument.
  """
  def default_rounding do
    @default_rounding
  end

  @doc """
  Returns the fractional part of a float or decimal as an integer
  """
  def fraction_as_integer(fraction, rounding \\ @default_rounding)
  def fraction_as_integer(fraction, rounding) when is_float(fraction) do
    if (truncated_fraction = trunc(fraction)) == fraction do
      truncated_fraction
    else
      Float.round(fraction, rounding) * 10 |> fraction_as_integer(rounding)
    end
  end
  
  @decimal_10 Decimal.new(10)
  def fraction_as_integer(fraction, rounding) when is_map(fraction) do
    truncated_fraction = Decimal.round(fraction, 0, :floor)
    if Decimal.equal?(truncated_fraction, fraction) do
      truncated_fraction |> Decimal.to_integer
    else
      Decimal.round(fraction, rounding) |> Decimal.mult(@decimal_10) |> fraction_as_integer(rounding)
    end
  end
  
  @doc """
  Calculates the number of decimal digits in a number.
  
  Calculates the number of decimal digits for integer
  or decimal number.
  """
  def number_of_digits(number) when is_integer(number) do
    do_number_of_digits(number, 0)
  end
  
  def number_of_digits(number) when is_map(number) do
    do_number_of_digits(Decimal.to_integer(number), 0)
  end
  
  def do_number_of_digits(number, count) do
    if number == 0 do
      count
    else
      div(number, 10) |> do_number_of_digits(count + 1)
    end
  end
  
  def remove_trailing_zeroes(number) when number == 0, do: number
  def remove_trailing_zeroes(number) do
    if rem(number, 10) != 0 do
      number
    else
      div(number,10) |> remove_trailing_zeroes()
    end
  end
  
  @doc """
  Check if the value is within a range.  Handle integer, float and
  decimal separately.
  """
  def within(value, range) when is_integer(value) do
    value in range
  end
  
  # When checking if a decimal is in a range it is only
  # valid if there are no decimal places
  def within(value, first..last) when is_float(value) do
    value == trunc(value) && value >= first && value <= last
  end
  
  @doc """
  Calculates the modulus of a number (integer, float, decimal)
  
  For the case of an integer the result is that of the BIF
  function rem/2. For the other cases the modulo is calculated 
  separately.
  """
  def mod(number, modulus) when is_integer(number) do
    rem(number, modulus)
  end
  
  def mod(number, modulus) when is_float(number) do
    number - (Float.floor(number / modulus) * modulus)
  end
  
  def mod(number, modulus) when is_map(number) and is_map(modulus) do
    modulo = Decimal.div(number, modulus) |> Decimal.round(0) |> Decimal.mult(modulus)
    Decimal.sub(number, modulo)
  end
  
  def mod(number, modulus) when is_map(number) and is_integer(modulus) do
    mod(number, Decimal.new(modulus))
  end
  
  # % Count the number of trailing zeroes
  # trailing_zeroes(Num) when is_integer(Num) ->
  #   do_trailing_zeroes(Num, 0);
  # trailing_zeroes(Num) when is_float(Num) ->
  #   trailing_zeroes(trunc(Num)).
  #
  # do_trailing_zeroes(Num, Count) ->
  #   if
  #     Num == 0 -> Count;
  #     (Num rem 10) /= 0 -> Count;
  #     true -> do_trailing_zeroes(Num div 10, Count + 1)
  #   end.
end 