# http://unicode.org/reports/tr35/tr35-numbers.html#Language_Plural_Rules
defmodule Cldr.Number.Format.Compiler do
  @moduledoc """
  Generate functions from CLDR number format definitions.
  """
  
  @doc """
  Scan a number format definition
  
  Using a leex lexer, tokenize a rule definition
  """
  def tokenize(definition) when is_binary(definition) do
    String.to_charlist(definition) |> :decimal_formats_lexer.string
  end
  
  @doc """
  Parse a number format definition

  Using a yexx lexer, parse a nunber format definition into an Elixir
  AST that can then be `unquoted` into a function definition.
  """
  def parse(tokens) when is_list(tokens) do
    :decimal_formats_parser.parse tokens
  end

  def parse(definition) when is_binary(definition) do
    {:ok, tokens, _end_line} = tokenize(definition)
    tokens |> :decimal_formats_parser.parse
  end
  
  def decode(definition) do
    case parse(definition) do
    {:ok, format} ->
      analyse(format)
    {:error, {_line, _parser, [message, [context]]}} ->
      {:error, "Decimal format compiler: #{message}#{context}"}
    end
  end
    
  defp analyse(_format) do

  end
end