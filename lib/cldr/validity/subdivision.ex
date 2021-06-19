defmodule Cldr.Validity.Subdivision do
  use Cldr.Validity, :subdivisions

  def validate(nil) do
    {:ok, nil, nil}
  end

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

  def normalize(code) when is_binary(code) do
    String.downcase(code)
  end

  def normalize(nil) do
    nil
  end
end
