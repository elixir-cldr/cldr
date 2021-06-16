defmodule Cldr.Validity.Script do
  use Cldr.Validity, :scripts

  def validate(code) do
    code
    |> to_string()
    |> String.capitalize()
    |> valid()
    |> case do
      {:error, _} -> {:error, code}
      other -> other
    end
  end
end
