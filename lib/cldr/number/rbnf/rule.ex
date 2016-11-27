defmodule Cldr.Rbnf.Rule do
  @moduledoc """
  Tokenizer and Parser for RBNF rules.
  """

  defstruct [:base_value, :radix, :definition, :range, :divisor]
  alias Cldr.Rbnf.Rule

  @doc """
  Scan and tokenize rule definition

  Using a leex lexer, tokenize a rule definition
  """
  def tokenize(definition) when is_binary(definition) do
    definition
    |> String.trim_leading("'")
    |> String.to_charlist
    |> :rbnf_lexer.string
  end

  def tokenize(%Rule{definition: definition} = _rule) do
    tokenize(definition)
  end

  @doc """
  Parse an RBNF rule definition

  Returns a list of rule subparts that can then be used for
  further processing or for turning into an AST for execution.
  """
  def parse(definition) when is_binary(definition) do
    {:ok, tokens, _end_line} = tokenize(definition)
    parse(tokens)
  end

  def parse([]) do
    {:ok, []}
  end

  def parse(tokens) when is_list(tokens) do
    tokens
    |> :rbnf_parser.parse
  end

end
