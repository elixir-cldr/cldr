defmodule Cldr.Substitution do
  @moduledoc """
  Compiles substitution formats that are of the form
  "{0} something {1}" into a token list that allows for
  more efficient parameter substitution at runtime.
  """

  @doc """
  Parses a substitution template into a list of tokens to
  allow efficient parameter substitution at runtime.

  * `template` is a binary that may include parameter markers that
  are substituted for values at runtime.

  Returns:

  * A list of tokens where any substitution is marked as an integer
  any any binary tokens are passed through as is.

  ## Examples

      iex> Cldr.Substitution.parse "{0}, {1}"
      [0, ", ", 1]

      iex> Cldr.Substitution.parse "{0} This is something {1} or another {2}"
      [0, " This is something ", 1, " or another ", 2]

  This function is primarily intended to support compile-time generation
  of templates that simplify and speed up parameter substitution at runtime.

  """
  @spec parse(String.t()) :: [String.t() | integer, ...]
  def parse("") do
    []
  end

  def parse(template) when is_binary(template) do
    String.split(template, ~r/{[0-9]}/, include_captures: true, trim: true)
    |> Enum.map(&item_from_token/1)
  end

  def parse(_template) do
    {:error, "#{inspect(__MODULE__)}.parse/1 accepts only a binary parameter"}
  end

  @doc """
  Substitutes a list of values into a template token list that is
  created by `Cldr.Substitution.parse/1`.

  * `list1` is a list of values that will be substituted into a
  a template list previously created by `Cldr.Substitution.parse/1`

  * `list2` is a template list previously created by
  `Cldr.Substitution.parse/1`

  Returns:

  * A list with values substituted for parameters in the `list1` template

  ## Examples:

      iex> template = Cldr.Substitution.parse "{0} This is something {1}"
      [0, " This is something ", 1]
      iex> Cldr.Substitution.substitute ["a", "b"], template
      ["a", " This is something ", "b"]

  """
  @spec substitute(term | [term, ...], [String.t() | integer, ...]) :: [term, ...]

  # Takes care of the case where no parameters are used
  def substitute([_item], [string]) when is_binary(string) do
    [string]
  end

  def substitute(_item, [string]) when is_binary(string) do
    [string]
  end

  # Takes care of a common case where there is one parameter
  def substitute([item], [0, string]) when is_binary(string) do
    [item, string]
  end

  def substitute(item, [0, string]) when is_binary(string) do
    [item, string]
  end

  def substitute([item], [string, 0]) when is_binary(string) do
    [string, item]
  end

  def substitute(item, [string, 0]) when is_binary(string) do
    [string, item]
  end

  def substitute(item, [string1, 0, string2]) when is_binary(string1) and is_binary(string2) do
    [string1, item, string2]
  end

  # Takes care of the common case where there are two parameters separated
  # by a string.
  def substitute([item_0, item_1], [0, string, 1]) when is_binary(string) do
    [item_0, string, item_1]
  end

  def substitute([item_0, item_1], [1, string, 0]) when is_binary(string) do
    [item_1, string, item_0]
  end

  # Takes care of the case when there are two parameters and two strings
  def substitute([item_0, item_1], [0, string1, 1, string2]) do
    [item_0, string1, item_1, string2]
  end

  # Takes care of the common case where there are three parameters separated
  # by strings.
  def substitute([item_0, item_1, item_2], [0, string_1, 1, string_2, 2])
      when is_binary(string_1) and is_binary(string_2) do
    [item_0, string_1, item_1, string_2, item_2]
  end

  @digits [?0, ?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9]
  defp item_from_token(<<?{, digit, ?}>>) when digit in @digits do
    digit - ?0
  end

  defp item_from_token(string) do
    string
  end
end
