defmodule Cldr.Helpers do
  def empty?([]), do: true
  def empty?(%{} = map) when map == %{}, do: true
  def empty?(nil), do: true
  def empty?(_), do: false
end
