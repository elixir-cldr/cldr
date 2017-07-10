defmodule Cldr.DateTime.Compiler do
  @moduledoc """
  Tokenizes and parses Date and DateTime format strings
  """

  alias Cldr.DateTime.Formatter

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

  def tokenize(%{_numbers: _numbers, _value: value}) do
    tokenize(value)
  end

  @doc """
  Parse a number format definition

  Using a yexx lexer, parse a datetime format definition into list of
  elements we can then interpret to format a date or datetime.

  ## Example

      iex> Cldr.Number.Format.Compiler.compile "yyyy/MM/dd"

  """
  def compile("") do
    {:error, "empty format string cannot be compiled"}
  end

  def compile(nil) do
    {:error, "no format string or token list provided"}
  end

  def compile(definition) when is_binary(definition) do
    {:ok, tokens, _end_line} = tokenize(definition)

    transforms = Enum.map(tokens, fn {fun, _line, count} ->
      quote do
        Formatter.unquote(fun)(var!(date), unquote(count), var!(locale), var!(options))
      end
    end)

    {:ok, transforms}
  end

  def compile(%{_numbers: _number_system, _value: value}) do
    compile(value)
  end

  def compile(arg) do
    raise ArgumentError, message: "No idea how to compile format: #{inspect arg}"
  end
end