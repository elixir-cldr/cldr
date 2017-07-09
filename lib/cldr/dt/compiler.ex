defmodule Cldr.DateTime.Compiler do
  @moduledoc """
  Tokenizes and parses Date and DateTime format strings
  """

  @doc """
  Scan a number format definition

  Using a leex lexer, tokenize a rule definition

  ## Example

      iex> Cldr.DateTime.Compiler.tokenize "yyyy/MM/dd"
      {:ok,
       [{:year_numeric, 1, 4}, {:literal, 1, '/'}, {:month, 1, 2}, {:literal, 1, '/'},
        {:day_of_month, 1, 2}], 1}
  """
  def tokenize(definition) when is_binary(definition) do
    definition
    |> String.to_charlist
    |> :datetime_format_lexer.string
  end

  @doc """
  Parse a number format definition

  Using a yexx lexer, parse a datetime format definition into list of
  elements we can then interpret to format a date or datetime.

  ## Example

      iex> Cldr.Number.Format.Compiler.parse "yyyy/MM/dd"

  """
  def parse(tokens) when is_list(tokens) do
    :datetime_format_parser.parse tokens
  end

  def parse("") do
    {:error, "empty format string cannot be compiled"}
  end

  def parse(nil) do
    {:error, "no format string or token list provided"}
  end

  def parse(definition) when is_binary(definition) do
    {:ok, tokens, _end_line} = tokenize(definition)
    tokens |> :datetime_format_parser.parse
  end

  def parse(arg) do
    raise ArgumentError, message: "No idea how to compile format: #{inspect arg}"
  end
end