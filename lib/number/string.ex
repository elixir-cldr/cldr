defmodule Cldr.Number.String do
  def pad_leading_zeroes(number, count) when count <= 0 do
    number
  end
  
  def pad_leading_zeroes(number, count) do
    String.pad_leading(number, count, "0")
  end
  
  def pad_trailing_zeroes(number, count) when count <= 0 do
    number
  end
  
  def pad_trailing_zeroes(number, count) do
    String.pad_trailing(number, count, "0")
  end
  
  # Split a string up into fixed size chunks (except the last
  # chunk)
  def chunk_string("", _size) do
    []
  end
  
  def chunk_string(string, size) do
    if String.length(string) < size do
      [string]
    else
      {chunk, rest} = String.split_at(string, size)
      [chunk] ++ chunk_string(rest, size)
    end
  end
end