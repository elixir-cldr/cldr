# http://icu-project.org/apiref/icu4c/classRuleBasedNumberFormat.html
defmodule Cldr.Numbers.Cardinal do
  # import Cldr.Numbers, only: [fraction_as_integer: 2]
  @default_rounding 2
  
  def default_rounding do
    @default_rounding
  end
  
  # def spell(:infinity), do: "infinity"
  # def spell(0), do: "zero"
  # def spell(1), do: "one"
  # def spell(2), do: "two"
  # def spell(3), do: "three"
  # def spell(4), do: "four"
  # def spell(5), do: "five"
  # def spell(6), do: "six"
  # def spell(7), do: "seven"
  # def spell(8) do
  #   "eight"
  # end
  #
  # def spell(9) do
  #   "nine"
  # end
  #
  # def spell(10) do
  #   "ten"
  # end
  #
  # def spell(11) do
  #   "eleven"
  # end
  #
  # def spell(12) do
  #   "twelve"
  # end
  #
  # def spell(13) do
  #   "thirteen"
  # end
  #
  # def spell(14) do
  #   "fourteen"
  # end
  #
  # def spell(15) do
  #   "fifteen"
  # end
  #
  # def spell(16) do
  #   "sixteen"
  # end
  #
  # def spell(17) do
  #   "seventeen"
  # end
  #
  # def spell(18) do
  #   "eighteen"
  # end
  #
  # def spell(19) do
  #   "nineteen"
  # end
  #
  # def spell(value) when is_integer(value) and value < 30 do
  #   to_go = case rem(value, 20) do
  #     0 -> "twenty"
  #     _ -> "twenty" <> "-" <> spell(to_go)
  #   end
  # end
  #
  # def spell(value) when is_integer(value) and value < 40 do
  #   to_go = case rem(value, 30) do
  #     0 -> "thirty"
  #     _ -> "thirty" <> "-" <> spell(to_go)
  #   end
  # end
  #
  # def spell(value) when is_integer(value) and value < 50 do
  #   to_go = case rem(value, 40) do
  #     0 -> "forty"
  #     _ -> "forty" <> "-" <> spell(to_go)
  #   end
  # end
  #
  # def spell(value) when is_integer(value) and value < 60 do
  #   to_go = case rem(value, 50) do
  #     0 -> "fifty"
  #     _ -> "fifty" <> "-" <> spell(to_go)
  #   end
  # end
  #
  # def spell(value) when is_integer(value) and value < 70 do
  #   to_go = case rem(value, 60) do
  #     0 -> "sixty"
  #     _ -> "sixty" <> "-" <> spell(to_go)
  #   end
  # end
  #
  # def spell(value) when is_integer(value) and value < 80 do
  #   to_go = case rem(value, 70) do
  #     0 -> "seventy"
  #     _ -> "seventy" <> "-" <> spell(to_go)
  #   end
  # end
  #
  # # "90": "ninety[->>];",
  # def spell(value) when is_integer(value) and value < 90 do
  #   to_go = case rem(value, 80) do
  #     0 -> "eighty"
  #     _ -> "eighty" <> "-" <> spell(to_go)
  #   end
  # end
  #
  # # "100": "<< hundred[ >>];",
  # def spell(value) when is_integer(value) and value < 100 do
  #   m = rem(value, 90)
  #   parts = ["ninety"]
  #   conditional_parts = if m > 0, do: ["-", spell(m)], else: []
  #   Enum.join(parts ++ conditional_parts)
  # end
  #
  # # "100": "<< hundred[ >>];",
  # # Guard value is the value of the next highest range if there is one
  # # Get the div and mod of the value against the range
  # # Apply the conditional formatting (spacing)
  # def spell(value) when is_integer(value) and value < 1000 do
  #   # v is the value div the rule "name"
  #   v = div(value, 100)
  #
  #   # m is modulo of the value div the rule "name"
  #   m = rem(value, 100)
  #
  #   # << means assemble v
  #   # ' hundred' means add that as a literal
  #   parts = [spell(v), " hundred"]
  #
  #   # [ ] means optional only if the the modulo isn't 0
  #   # " " is a literal
  #   # >> means the spelling of the modulo
  #   conditional_parts = if m > 0, do: [" ", spell(m)], else: []
  #   Enum.join(parts ++ conditional_parts)
  # end
  #
  # # "1000": "<< thousand[ >>];",
  # def spell(value) when is_integer(value) and value < 1_000_000 do
  #   v = div(value, 1000)
  #   case m = rem(value, 1000) do
  #   0 ->
  #     spell(v) <> " " <> "thousand"
  #   _ ->
  #     spell(v) <> " " <> "thousand" <> " " <> spell(m)
  #   end
  # end
  #
  # # "1000000": "<< million[ >>];",
  # def spell(value) when is_integer(value) and value < 1_000_000_000 do
  #   v = div(value, 1_000_000)
  #   case m = rem(value, 1_000_000) do
  #   0 ->
  #     spell(v) <> " " <> "million"
  #   _ ->
  #     spell(v) <> " " <> "million" <> " " <> spell(m)
  #   end
  # end
  #
  # def spell(:nan) do
  #   "not a number"
  # end
  #
  # def spell(value) when is_float(value) do
  #   spell(value, 3)
  # end
  #
  # def spell(_other) do
  #   spell(:nan)
  # end
  #
  # def spell(value, precision) when is_float(value) do
  #   left = trunc(value)
  #   fraction = (value - left) |> Float.round(precision)
  #   right = fraction_as_integer(fraction, precision)
  #   spell(left) <> " point " <> spell(right)
  # end
end 