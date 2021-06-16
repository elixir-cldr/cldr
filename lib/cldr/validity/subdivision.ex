defmodule Cldr.Validity.Subdivision do
  use Cldr.Validity, :subdivisions

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
