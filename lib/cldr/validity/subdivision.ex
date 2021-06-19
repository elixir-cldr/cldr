defmodule Cldr.Validity.Subdivision do
  use Cldr.Validity, :subdivisions

  @doc since: "2.23.0"

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

  @doc since: "2.23.0"

  def normalize(code) when is_binary(code) do
    String.downcase(code)
  end

  def normalize(nil) do
    nil
  end
end
