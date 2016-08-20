defmodule Cldr.Helpers do
  def underscore_keys(nil), do: nil
  def underscore_keys(map) do
    Enum.map(map, fn {k, v} -> {Macro.underscore(k), v} end)
    |> Enum.into(%{})
  end
  
  def atomize_keys(nil), do: nil
  def atomize_keys(map) do
    Enum.map(map, fn {k, v} -> {String.to_atom(k), v} end)
    |> Enum.into(%{})
  end
end