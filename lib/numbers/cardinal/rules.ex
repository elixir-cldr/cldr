defmodule Cldr.Numbers.Cardinal.Rules do
  import Cldr.Numbers
  import Cldr.Numbers.Cardinal.Rules.Compiler 
  import Cldr.Numbers.Cardinal.Rules.Transformer
  
  # Plural Operand Meanings as defined in CLDR plural rules and used
  # in the generated code
  #
  #   Symbol  Value
  #   n       absolute value of the source number (integer and decimals).
  #   i       integer digits of n.
  #   v       number of visible fraction digits in n, with trailing zeros.
  #   w       number of visible fraction digits in n, without trailing zeros.
  #   f       visible fractional digits in n, with trailing zeros.
  #   t       visible fractional digits in n, without trailing zeros.
  
  @doc """
  Lookup the plural cardinal category for a given number in a given locale
  
  Identify which category (zero, one, two, few, many or other) a given number
  in a given locale fits into.  This category can then be used to format the
  number or currency
  """
  def category(number, locale \\ Cldr.default_locale(), rounding \\ Cldr.Numbers.default_rounding())
  def category(number, locale, _rounding) when is_integer(number) do
    n = abs(number)
    i = n
    v = 0; w = 0; f = 0; t = 0
    do_cardinal(locale, n, i, v, w, f, t)
  end
  
  def category(number, locale, rounding) when is_float(number) and is_integer(rounding) and rounding > 0 do
    n = abs(number) |> Float.round(rounding)
    i = trunc(n)
    v = rounding
    t = fraction_as_integer(n - i, rounding)
    w = number_of_digits(t)
    f = t * :math.pow(10, v - w) |> trunc
    do_cardinal(locale, n, i, v, w, f, t)
  end
  
  # For the case where its a Decimal we guard against a map (which is the underlying representation of
  # a Decimal).  Don't use rounding because the precision is specified for Decimals.
  def category(number, locale, rounding) when is_map(number) and is_integer(rounding) and rounding > 0 do
    # n absolute value of the source number (integer and decimals).
    n = Decimal.abs(number)
    
    # i integer digits of n.    
    i = Decimal.round(n, 0, :floor)
    
    # v number of visible fraction digits in n, with trailing zeros.
    v = abs(n.exp)
    
    # f visible fractional digits in n, with trailing zeros.
    f = Decimal.sub(n, i) 
      |> Decimal.mult(Decimal.new(:math.pow(10, v))) 
      |> Decimal.round(0, :floor) 
      |> Decimal.to_integer
    
    #   t visible fractional digits in n, without trailing zeros.
    t = remove_trailing_zeroes(f)
    
    # w number of visible fraction digits in n, without trailing zeros.
    w = number_of_digits(t)
    
    i = Decimal.to_integer(i)
    n = to_float(n)
    
    # IO.puts "n: #{inspect n}; i: #{inspect i}; v: #{inspect v}; w: #{inspect w}; f: #{inspect f}; t: #{inspect t}"
    do_cardinal(locale, n, i, v, w, f, t)
  end
  
  defp to_float(decimal) do
    decimal.sign * decimal.coef * 1.0 * :math.pow(10, decimal.exp)
  end
  
  # Generate the functions to process plural rules
  @spec do_cardinal(binary, number, number, number, number, number, number) 
    :: :one | :two | :few | :many | :other
    
  Enum.each configured_locales, fn (locale) ->
    function_body = cardinal_rules[locale] |> rules_to_condition_statement(__MODULE__)
    function = quote do
      defp do_cardinal(unquote(locale), n, i, v, w, f, t), do: unquote(function_body)
    end
    if System.get_env("DEBUG"), do: IO.puts Macro.to_string(function)
    Code.eval_quoted(function, [], __ENV__)
  end
end
