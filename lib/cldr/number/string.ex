defmodule Cldr.Number.String do
  @moduledoc """
  String helper functions
  """

  @doc """
  Returns a regex which matches all latin1 characters
  """
  @latin1 ~r/([\x00-\x7F])/
  def latin1 do
    @latin1
  end

  @doc """
  Returns a regex which matches all non-latin1 characters
  """
  @not_latin1 ~r/([^\x00-\x7F])/
  def not_latin1 do
    @not_latin1
  end

  @doc """
  Replace any non-latin1 characters with a \?
  """
  def clean(string) do
    String.replace(string, @not_latin1, "\\?")
  end

  @doc """
  Replaces characters with a string hex representation
  """
  def hex_string(string) do
    String.to_charlist(string)
    |> Enum.map(&("\\x" <> Integer.to_string(&1)))
    |> Enum.join
  end

  @doc """
  Pad a a string (representing a number) with leading "0"'s to the
  specified length.

  * `number` is a string representation of a number

  * `count` is the final length required of the string
  """
  @spec pad_leading_zeroes(String.t, integer) :: String.t
  def pad_leading_zeroes(number_string, count) when count <= 0 do
    number_string
  end

  def pad_leading_zeroes(number_string, count) do
    String.pad_leading(number_string, count, "0")
  end

  @doc """
  Pad a a string (representing a number) with trailing "0"'s to the
  specified length.

  * `number` is a string representation of a number

  * `count` is the final length required of the string
  """
  @spec pad_trailing_zeroes(String.t, integer) :: String.t
  def pad_trailing_zeroes(number_string, count) when count <= 0 do
    number_string
  end

  def pad_trailing_zeroes(number_string, count) do
    String.pad_trailing(number_string, count, "0")
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

  # This version is the same as version 2 in the forward direction
  # but differs in the reverse direction.  Implementation [2] does
  # a lot of string reversal and enumeration which we can avoid if we
  # calculate the size of the orhpan chunk at the end. That means
  # the reverse version is pretty much the same as version 2 :reverse.
  def chunk_string(string, size, direction \\ :forward)
  def chunk_string("", _size, _) do
    [""]
  end

  def chunk_string(string, size, :forward) do
    string
    |> String.to_charlist
    |> Enum.chunk(size, size, [])
    |> Enum.map(&List.to_string/1)
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

  # Original version which is second fastest in the
  # forward direction and second fastest in the reverse direction
  def chunk_string3(string, size, direction \\ :forward)
  def chunk_string3("", _size, _) do
    [""]
  end

  def chunk_string3(string, size, :forward) do
    len = String.length(string)
    remainder = rem(len, size)
    if remainder > 0 do
      {head, last} = String.split_at(string, len - remainder)
      do_chunk_string(head, size) ++ [last]
    else
      do_chunk_string(string, size)
    end
  end

  def chunk_string3(string, size, :reverse) do
    len = String.length(string)
    remainder = rem(len, size)
    if remainder > 0 do
      {head, last} = String.split_at(string, remainder)
      [head] ++ do_chunk_string(last, size)
    else
      do_chunk_string(string, size)
    end
  end

  # Alternative version splitting into a list and chunking the list
  # We can assume these are all bytes representing integers in the latin1
  # alphabet since we are only using this method for formatting number
  # before transliteration.  The assumption is that we are working with
  # bytes, not unicode graphemes (which are variable length)
  def chunk_string2(string, size, direction \\ :forward)
  def chunk_string2("", _size, _) do
    [""]
  end

  def chunk_string2(string, size, :forward) do
    string
    |> String.to_charlist
    |> Enum.chunk(size, size, [])
    |> Enum.map(&List.to_string/1)
  end

  def chunk_string2(string, size, :reverse) do
    string
    |> String.to_charlist
    |> :lists.reverse
    |> Enum.chunk(size, size, [])
    |> Enum.map(&:lists.reverse/1)
    |> :lists.reverse
    |> Enum.map(&List.to_string/1)
  end
end
