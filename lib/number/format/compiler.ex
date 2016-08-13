# http://unicode.org/reports/tr35/tr35-numbers.html#Language_Plural_Rules
defmodule Cldr.Number.Format.Compiler do
  import Kernel, except: [length: 1]
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
    IO.puts "Definition: #{inspect definition}"
    case parse(definition) do
    {:ok, format} ->
      analyze(format)
    {:error, {_line, _parser, [message, [context]]}} ->
      {:error, "Decimal format compiler: #{message}#{context}"}
    end
  end
    
  defp analyze(format) do
    IO.puts "Length: #{length(format)}"
    IO.puts "Multiplier: #{multiplier(format)}"
  end
  
  defp length(format) do
    Enum.reduce format[:positive], 0, fn (element, len) ->
      len + case element do
        {:currency, size}   -> size
        {:percent, _}       -> 1
        {:permille, _}      -> 1
        {:plus, _}          -> 1
        {:minus, _}         -> 1
        {:literal, literal} -> String.length(literal)
        {:format, format}   -> String.length(format)
      end
    end
  end 
  
  defp multiplier(format) do
    cond do
      percent_format?(format)   -> 100
      permille_format?(format)  -> 1000
      true                      -> 1
    end
  end
  
  defp percent_format?(format) do
    Keyword.has_key? format[:positive], :percent
  end
  
  defp permille_format?(format) do
    Keyword.has_key? format[:positive], :permille
  end
end      
         