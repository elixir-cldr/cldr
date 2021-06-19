defmodule Cldr.Validity.Script do
  use Cldr.Validity, :scripts

  def validate(nil) do
    {:ok, nil, nil}
  end

  def validate(code) do
    code
    |> to_string()
    |> normalize
    |> valid()
    |> case do
      {:error, _} -> {:error, code}
      other -> other
    end
  end

  def normalize(code) when is_binary(code) do
    String.capitalize(code)
  end

  def normalize(nil) do
    nil
  end
end
