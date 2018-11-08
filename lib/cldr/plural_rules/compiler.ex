# http://unicode.org/reports/tr35/tr35-numbers.html#Language_Plural_Rules
defmodule Cldr.Number.PluralRule.Compiler do
  @moduledoc false

  @doc """
  Tokenize a plural rule definition.

  Using a leex lexer, tokenize a rule definition.

  """
  def tokenize(definition) when is_binary(definition) do
    definition
    |> String.to_charlist()
    |> :plural_rules_lexer.string()
  end

  @doc """
  Parse a plural rule definition.

  Using a yexx lexer, parse a rule definition into an Elixir
  AST that can then be `unquoted` into a function definition.

  """
  def parse(tokens) when is_list(tokens) do
    :plural_rules_parser.parse(tokens)
  end

  def parse(definition) when is_binary(definition) do
    {:ok, tokens, _end_line} = tokenize(definition)
    tokens |> :plural_rules_parser.parse()
  end
end
