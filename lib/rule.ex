defmodule Cldr.Rbnf.Rule do
  defstruct [:ruleset, :name, :radix, :definition, :range]
  alias Cldr.Rbnf.Rule
 
  @doc """
  Scan a rule definition
  
  Using a leex lexer, tokenize a rule definition
  """
  def tokenize(definition) when is_binary(definition) do
    String.to_charlist(definition) |> :rbnf.string
  end
  
  def tokenize(%Rule{definition: definition} = _rule) do
    tokenize(definition)
  end
  
end