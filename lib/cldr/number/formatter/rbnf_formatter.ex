defmodule Cldr.Number.Formatter.Rbnf do
  @moduledoc """

  * If the rule set includes a master rule (and the number was passed in as a
    double), use the master rule. (If the number being formatted was passed in
    as a long, the master rule is ignored.)

  * If the number is negative, use the negative-number rule.

  * If the number has a fractional part and is greater than 1, use the improper
    fraction rule. * If the number has a fractional part and is between 0 and
    1, use the proper fraction rule.

  """

  def to_string(_number, _format, _options \\ []) do

  end
end