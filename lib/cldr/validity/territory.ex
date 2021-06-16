defmodule Cldr.Validity.Territory do
  use Cldr.Validity, :territories

  def validate(code) do
    code
    |> to_string()
    |> String.upcase()
    |> valid()
    |> case do
      {:error, _} -> {:error, code}
      {:ok, code} -> {:ok, String.to_atom(code)}
    end
  end
end
