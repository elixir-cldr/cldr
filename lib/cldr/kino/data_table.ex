defmodule Cldr.Kino.DataTable do
  @moduledoc false

  @dialyzer {:nowarn_function, [value_to_string: 2]}
  def value_to_string(:__column__, value) when is_atom(value) do
    value
    |> to_string()
    |> String.capitalize()
    |> String.replace("_", " ")
  end

  def value_to_string(_key, value) when is_atom(value), do: inspect(value)

  def value_to_string(_key, value) when is_list(value) do
    if List.ascii_printable?(value) do
      List.to_string(value)
    else
      inspect(value)
    end
  end

  def value_to_string(_key, value) when is_binary(value) do
    inspect_opts = Inspect.Opts.new([])

    if String.printable?(value, inspect_opts.limit) do
      value
    else
      inspect(value)
    end
  end

  def value_to_string(_key, value) do
    if mod = Cldr.Chars.impl_for(value) do
      mod.to_string(value)
    else
      inspect(value)
    end
  end
end