defmodule Cldr.Validity.Variant do
  use Cldr.Validity, :variants

  def validate(code) do
    code
    |> to_string()
    |> String.downcase()
    |> valid()
    |> case do
      {:error, _} -> {:error, code}
      other -> other
    end
  end
end
