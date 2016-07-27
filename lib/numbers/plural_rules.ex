# http://unicode.org/reports/tr35/tr35-numbers.html#Language_Plural_Rules
defmodule Cldr.Numbers.PluralRules do
  import Cldr.Numbers, only: [fraction_as_integer: 2, number_of_digits: 1]
  
  @moduledoc """
  Generate functions from CLDR plural rules that can be used to determine 
  which pularization rule to be used for a given number.
  """
  
  @doc """
  Scan a rule definition
  
  Using a leex lexer, tokenize a rule definition
  """
  def tokenize(definition) when is_binary(definition) do
    String.to_charlist(definition) |> :plural_rules_lexer.string
  end
  
  @doc """
  Parse a rule definition
  
  Using a yexx lexer, parse a rule definition into an Elixir
  AST that can then be `unquoted` into a function definition.
  """
  def parse(tokens) when is_list(tokens) do
    :plural_rules_parser.parse tokens
  end
  
  def parse(definition) when is_binary(definition) do
    {:ok, tokens, _end_line} = tokenize(definition) 
    tokens |> :plural_rules_parser.parse
  end
  
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
  def cardinal(number, locale \\ Cldr.default_locale(), rounding \\ Cldr.Numbers.default_rounding())
  def cardinal(number, locale, _rounding) when is_integer(number) do
    n = abs(number)
    i = n
    v = 0; w = 0; f = 0; t = 0
    do_cardinal(number, locale, n, i, v, w, f, t)
  end
  
  def cardinal(number, locale, rounding) when is_float(number) and is_integer(rounding) and rounding > 0 do
    n = abs(number) |> Float.round(rounding)
    i = trunc(n)
    v = rounding
    t = fraction_as_integer(n - i, rounding)
    w = number_of_digits(t)
    f = t * :math.pow(10, v - w) |> trunc
    do_cardinal(number, locale, n, i, v, w, f, t)
  end
  
  # For the case where its a Decimal we guard against a map (which is the underlying representation of
  # a Decimal)
  def cardinal(number, locale, rounding) when is_map(number) and is_integer(rounding) and rounding > 0 do
    n = Decimal.abs(number)
    i = Decimal.round(n, 0)
    v = rounding
    t = fraction_as_integer(Decimal.sub(n, i), rounding)
    w = number_of_digits(t)
    f = t * :math.pow(10, v - w) |> trunc
    do_cardinal(number, locale, n, i, v, w, f, t)
  end
  
  # This is where we generate rules
  def do_cardinal(number, locale, n, i, v, w, f, t) do
    IO.puts "number=#{inspect number}\nlocale=#{inspect locale}\nn=#{inspect n}\ni=#{inspect i}\nv=#{inspect v}\nw=#{inspect w}\nf=#{inspect f}\nt=#{inspect t}"
    :one
  end
  
end