defmodule Cldr.Map do
  @moduledoc """
  Functions to transform maps
  """

  @doc """
  Convert map string camelCase keys to underscore_keys
  """
  def underscore_keys(nil), do: nil
  def underscore_keys(map) do
    map
    |> Enum.map(fn {k, v} ->
      if is_map(v) do
        {Macro.underscore(k), underscore_keys(v)}
      else
        {Macro.underscore(k), v}
      end
    end)
    |> Enum.into(%{})
  end

  @doc """
  Convert map string keys to :atom keys
  """
  def atomize_keys(nil), do: nil
  def atomize_keys(map) do
    map
    |> Enum.map(fn {k, v} ->
      if is_map(v) do
        {String.to_atom(k), atomize_keys(v)}
      else
        {String.to_atom(k), v}
      end
    end)
    |> Enum.into(%{})
  end
end
