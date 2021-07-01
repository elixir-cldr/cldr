defmodule Cldr.Validity.Variant do
  @moduledoc false

  use Cldr.Validity, :variants
  @behaviour Cldr.Validity

  @doc since: "2.23.0"

  def validate([]) do
    {:ok, [], nil}
  end

  def validate(list) when is_list(list) do
    list
    |> Enum.reverse()
    |> Enum.reduce_while({:ok, [], nil}, fn elem, {:ok, acc, _status} ->
      case validate(elem) do
        {:ok, variant, status} -> {:cont, {:ok, [variant | acc], status}}
        {:error, elem} -> {:halt, {:error, elem}}
      end
    end)
  end

  # Its not in the validity list but there is a
  # CLDR locale called "en-posix"
  def validate("posix") do
    {:ok, "posix", :obsolete}
  end

  def validate(code) do
    code
    |> normalize()
    |> valid()
    |> case do
      {:error, _} -> {:error, code}
      other -> other
    end
  end

  @doc since: "2.23.0"

  def normalize(list) when is_list(list) do
    Enum.map(list, &normalize/1)
  end

  def normalize(code) when is_binary(code) do
    String.downcase(code)
  end

  def normalize(nil) do
    nil
  end
end
