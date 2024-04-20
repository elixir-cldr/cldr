defmodule Cldr.Unit.Expression do
  @moduledoc false

  # This module resolves the expressions in the CLDR unit_preferences.xml
  # file as a Decimal or integer numbers. This approach is
  # intended to preserve precision wherever possible.

  import Kernel, except: [div: 2]

  @dialyzer {:nowarn_function, run: 2}

  def run("", _constants) do
    0
  end

  def run(%Decimal{} = v, _constants) do
    v
  end

  def run(v, _constants) when is_integer(v) do
    v
  end

  def run(v, constants) when is_binary(v) do
    constants
    |> Map.fetch!(v)
    |> run(constants)
  end

  def run(["*", v1, v2], _constants) when is_integer(v1) and is_integer(v2) do
    mult(v1, v2)
  end

  def run(["*", v1, v2], constants) do
    mult(run(v1, constants), run(v2, constants))
  end

  def run(["/", v1, v2], _constants) when is_integer(v1) and is_integer(v2) do
    div(v1, v2)
  end

  def run(["/", v1, v2], constants) do
    div(run(v1, constants), run(v2, constants))
  end

  def run(["^", v1, v2], constants) do
    pow(run(v1, constants), run(v2, constants))
  end

  def mult(v1, v2) when is_integer(v1) and is_integer(v2) do
    v1 * v2
  end

  def mult(v1, v2) do
    Decimal.mult(Decimal.new(v1), Decimal.new(v2))
  end

  def pow(v1, v2) when is_integer(v1) and is_integer(v2) do
    Cldr.Math.power(v1, v2)
  end

  def pow(%Decimal{} = v1, v2) when is_integer(v2) do
    Cldr.Math.power(v1, v2)
  end

  def div(v1, v2) when is_integer(v1) and is_integer(v2) do
    integer_div = Kernel.div(v1, v2)

    if integer_div * v2 == v1 do
      integer_div
    else
      Decimal.div(Decimal.new(v1), Decimal.new(v2))
    end
  end

  def div(v1, v2) do
    Decimal.div(Decimal.new(v1), Decimal.new(v2))
  end
end
