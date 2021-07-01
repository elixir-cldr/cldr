defmodule Cldr.Validity.Script do
  @moduledoc false

  use Cldr.Validity, :scripts
  @behaviour Cldr.Validity

  @doc since: "2.23.0"

  def validate(nil) do
    {:ok, nil, nil}
  end

  def validate(code) when is_binary(code) or is_atom(code) do
    code
    |> to_string()
    |> normalize
    |> valid()
    |> case do
      {:error, _} -> {:error, code}
      {:ok, code, status} -> {:ok, String.to_atom(code), status}
    end
  end

  @doc since: "2.23.0"

  def normalize(code) when is_binary(code) do
    String.capitalize(code)
  end

  def normalize(code) when is_atom(code) do
    code
    |> Atom.to_string()
    |> normalize()
  end

  def normalize(nil) do
    nil
  end
end
