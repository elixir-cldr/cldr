defmodule Cldr.Rbnf.Rule do
  @moduledoc """
  Tokenizer for an RBNF rule.
  """
  
  defstruct [:ruleset, :name, :radix, :definition, :range]
  alias Cldr.Rbnf.Rule
 
  @doc """
  Scan a rule definition
  
  Using a leex lexer, tokenize a rule definition
  """
  def tokenize(definition) when is_binary(definition) do
    definition
    |> String.to_charlist
    |> :rbnf.string
  end
  
  def tokenize(%Rule{definition: definition} = _rule) do
    tokenize(definition)
  end
  
end