defmodule Cldr.Kino.DataTable do
  @moduledoc false

  @dialyzer {:nowarn_function, [format: 2]}
  def format(:__header__, value) when is_atom(value) do
    value
    |> to_string()
    |> String.capitalize()
    |> String.replace("_", " ")
  end

  def format(_key, value) do
    if mod = Cldr.Chars.impl_for(value) do
      {:ok, mod.to_string(value)}
    else
      :default
    end
  end
end