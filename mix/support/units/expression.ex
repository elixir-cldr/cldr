# This module resolves the expressions in the CLDR unit_preferences.xml
# file as a rational number using the Ratio library. This approach is
# intended to preserve precision wherever possible.

require Protocol
Protocol.derive(Jason.Encoder, Ratio)

defmodule Cldr.Unit.Expression do
  @moduledoc false

  use Ratio

  def run("", _constants) do
    0
  end

  def run(v, _constants) when is_float(v) do
    {numerator, denominator} = Float.ratio(v)
    Ratio.new(numerator, denominator)
  end

  def run(v, _constants) when is_integer(v) do
    Ratio.new(v)
  end

  def run(%Ratio{} = rational, _constants) do
    rational
  end

  def run(v, constants) when is_binary(v) do
    constants
    |> Map.fetch!(v)
    |> run(constants)
  end

  def run(["*", v1, v2], constants) do
    run(v1, constants) * run(v2, constants)
  end

  def run(["/", v1, v2], constants) do
    run(v1, constants) / run(v2, constants)
  end

  def run(["^", v1, v2], constants) do
    Ratio.pow(run(v1, constants), run(v2, constants))
  end
end
