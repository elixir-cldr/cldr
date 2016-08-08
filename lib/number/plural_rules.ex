defmodule Cldr.Number.PluralRules do
  defmacro __using__(opts) do
    unless opts in [:cardinal, :ordinal] do
      raise ArgumentError, "Invalid option #{inspect opts}.  :cardinal or :ordinal are the only valid options"
    end
    
    plurals_filename = if opts == :cardinal, do: "plurals", else: "ordinals"
    plurals_type = if opts == :cardinal, do: "cardinal", else: "ordinal"
    
    quote do
      import Cldr.Number.Math
      import Cldr.Number.PluralRules.Compiler 
      import Cldr.Number.PluralRules.Transformer
      
      {:ok, json} = Path.join(__DIR__, "/../../data/cldr-core/supplemental/#{unquote(plurals_filename)}.json") 
        |> File.read! 
        |> Poison.decode
      @rules json["supplemental"]["plurals-type-#{unquote(plurals_type)}"]
  
      @doc """
      The locales for which cardinal rules are defined
      """
      @rules_locales Map.keys(@rules) |> Enum.sort
      def known_locales do
        @rules_locales
      end
  
      @doc """
      The configured locales for which plural rules are defined
  
      This is the intersection of the Cldr.known_locales and the locales for
      which plural rules are defined.  There are many Cldr locales which
      don't have their own plural rules so this list is the intersection
      of Cldr's configured locales and those that have rules.
      """
      @configured_locales  MapSet.intersection(MapSet.new(@rules_locales), MapSet.new(Cldr.known_locales)) 
      |> MapSet.to_list
      |> Enum.sort
  
      def configured_locales do
        @configured_locales
      end
  
      @doc """
      The plural rules defined in CLDR.
      """
      @spec plural_rules :: Map.t
      def plural_rules do
        @rules
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
      def plural_rule(number, locale \\ Cldr.default_locale(), rounding \\ Cldr.Number.Math.default_rounding())
      def plural_rule(number, locale, _rounding) when is_integer(number) do
        n = abs(number)
        i = n
        v = 0; w = 0; f = 0; t = 0
        do_plural_rule(locale, n, i, v, w, f, t)
      end
  
      def plural_rule(number, locale, rounding) when is_float(number) and is_integer(rounding) and rounding > 0 do
        n = abs(number) |> Float.round(rounding)
        i = trunc(n)
        v = rounding
        t = fraction_as_integer(n - i, rounding)
        w = number_of_digits(t)
        f = t * :math.pow(10, v - w) |> trunc
        do_plural_rule(locale, n, i, v, w, f, t)
      end
  
      # For the case where its a Decimal we guard against a map (which is the underlying representation of
      # a Decimal).  Don't use rounding because the precision is specified for Decimals.
      def plural_rule(number, locale, rounding) when is_map(number) and is_integer(rounding) and rounding > 0 do
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
        do_plural_rule(locale, n, i, v, w, f, t)
      end
    end
  end
end
