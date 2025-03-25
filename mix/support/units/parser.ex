defmodule Cldr.Unit.Parser do
  @moduledoc false

  @operators "[*\/^]"

  def parse(expression, default \\ "")

  def parse("", default) do
    default
  end

  def parse(expression, _default) do
    operator_regex = Regex.compile!(@operators)

    expression
    |> String.split(operator_regex, include_captures: true)
    |> Enum.map(&String.trim/1)
    |> infix_to_postfix
  end

  def infix_to_postfix([constant]) do
    parse_constant(constant)
  end

  def infix_to_postfix([constant, op | other]) when op in ["*", "/"] do
    [op, parse_constant(constant), infix_to_postfix(other)]
  end

  def infix_to_postfix([constant, op, pow | other]) when op in ["^"] do
    infix_to_postfix([[op, parse_constant(constant), parse_constant(pow)] | other])
  end

  def parse_constant(constant) when is_binary(constant) do
    case Integer.parse(constant) do
      {integer, ""} -> integer
      {_integer, _remainder} -> Decimal.parse(constant) |> elem(0)
      :error -> constant
    end
  end

  def parse_constant(constant) do
    constant
  end

  def systems("") do
    [:metric]
  end

  def systems(systems) do
    systems
    |> String.split()
    |> Enum.map(&String.trim/1)
  end
end
