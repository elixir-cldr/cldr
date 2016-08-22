defmodule Cldr.Number.String do
  @moduledoc """
  String helper functions
  """

  @doc """
  Pad a a string (representing a number) with leading "0"'s to the
  specified length.

  * `number` is a string representation of a number

  * `count` is the final length required of the string
  """
  @spec pad_leading_zeroes(String.t, integer) :: String.t
  def pad_leading_zeroes(number, count) when count <= 0 do
    number
  end

  def pad_leading_zeroes(number, count) do
    String.pad_leading(number, count, "0")
  end

  @doc """
  Pad a a string (representing a number) with trailing "0"'s to the
  specified length.

  * `number` is a string representation of a number

  * `count` is the final length required of the string
  """
  @spec pad_trailing_zeroes(String.t, integer) :: String.t
  def pad_trailing_zeroes(number, count) when count <= 0 do
    number
  end

  def pad_trailing_zeroes(number, count) do
    String.pad_trailing(number, count, "0")
  end

  @doc """
  Split a string up into fixed size chunks.

  Returns a list of strings the size of `size` plus potentially
  one more chunk at the end that is the remainder of the string
  after chunking.

  ## Examples

      iex> Cldr.Number.String.chunk_string("This is a string", 3)
      ["Thi", "s i", "s a", " st", "rin", "g"]

      iex> Cldr.Number.String.chunk_string("1234", 4)
      ["1234"]

      iex> Cldr.Number.String.chunk_string("1234", 3)
      ["123","4"]

      iex> Cldr.Number.String.chunk_string("1234", 3, :reverse)
      ["1", "234"]
  """
  @spec chunk_string(String.t, integer, :forward | :reverse) :: [String.t]
  def chunk_string(string, size, direction \\ :forward)
  def chunk_string("", _size, _) do
    [""]
  end

  def chunk_string(string, size, :forward) do
    len = String.length(string)
    remainder = rem(len, size)
    if remainder > 0 do
      {head, last} = String.split_at(string, len - remainder)
      do_chunk_string(head, size) ++ [last]
    else
      do_chunk_string(string, size)
    end
  end

  def chunk_string(string, size, :reverse) do
    len = String.length(string)
    remainder = rem(len, size)
    if remainder > 0 do
      {head, last} = String.split_at(string, remainder)
      [head] ++ do_chunk_string(last, size)
    else
      do_chunk_string(string, size)
    end
  end

  defp do_chunk_string("", _size) do
    []
  end

  defp do_chunk_string(string, size) do
    {chunk, rest} = String.split_at(string, size)
    [chunk] ++ do_chunk_string(rest, size)
  end
end
