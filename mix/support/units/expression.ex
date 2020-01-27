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

  def run(v, _constants) when is_number(v) do
    v
  end

  def run(v, constants) when is_binary(v) do
    Map.fetch!(constants, v)
  end

  def run(["*", v1, v2], constants) do
    Ratio.new(run(v1, constants)) * Ratio.new(run(v2, constants))
  end

  def run(["/", v1, v2], constants) do
    run(v1, constants) / run(v2, constants)
  end

  def run(["^", v1, v2], constants) do
    :math.pow(run(v1, constants), run(v2, constants))
  end
end