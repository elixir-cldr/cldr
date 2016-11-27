defmodule Cldr.Rbnf.Rule do
  @moduledoc """
  Tokenizer for an RBNF rule.
  """

  defstruct [:base_value, :radix, :definition, :range, :divisor]
  alias Cldr.Rbnf.Rule

  @doc """
  Scan a rule definition

  Using a leex lexer, tokenize a rule definition
  """
  def tokenize(definition) when is_binary(definition) do
    definition
    |> String.to_charlist
    |> :rbnf_lexer.string
  end

  def tokenize(%Rule{definition: definition} = _rule) do
    tokenize(definition)
  end

  def parse(definition) when is_binary(definition) do
    {:ok, tokens, _end_line} = tokenize(definition)
    parse(tokens)
  end

  def parse(tokens) when is_list(tokens) do
    tokens |> :rbnf_parser.parse
  end

end
