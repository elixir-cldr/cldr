defmodule Cldr.Validity.Language do
  use Cldr.Validity, :languages

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
