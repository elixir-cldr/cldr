defmodule Cldr.Validity.Territory do
  @moduledoc false

  use Cldr.Validity, :territories
  @behaviour Cldr.Validity

  @doc since: "2.23.0"

  def validate(nil) do
    {:ok, nil, nil}
  end

  def validate(code) when is_binary(code) or is_atom(code) do
    code
    |> normalize()
    |> valid()
    |> case do
      {:error, _} -> {:error, code}
      {:ok, code, status} -> {:ok, String.to_atom(code), status}
    end
  end

  @doc since: "2.23.0"
  def normalize(code) when is_integer(code) do
    case code do
      code when code < 10 -> "00#{code}"
      code when code < 100 -> "0#{code}"
      _ -> "#{code}"
    end
  end

  def normalize(code) when is_binary(code) do
    String.upcase(code)
  end

  def normalize(nil) do
    nil
  end

  def normalize(code) when is_atom(code) do
    code
    |> Atom.to_string()
    |> normalize()
  end
end
