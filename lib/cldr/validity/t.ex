defmodule Cldr.Validity.T do
  alias Cldr.Validity.U

  @field_mapping %{
    "language" => :language,
    "m0" => :m0,
    "s0" => :s0,
    "d0" => :d0,
    "i0" => :i0,
    "k0" => :k0,
    "t0" => :t0,
    "h0" => :h0,
    "x0" => :x0
  }

  @fields Map.values(@field_mapping)
  @inverse_field_mapping Enum.map(@field_mapping, fn {k, v} -> {v, k} end) |> Map.new()
  @validity_data Cldr.Config.validity(:t)
  @dont_process_keys ["language"]
  @valid_keys Map.keys(@validity_data) ++ @dont_process_keys
  @process_keys @valid_keys -- @dont_process_keys

  def fields do
    @fields
  end

  @doc """
  Decodes and validates that a given value is valid
  for a given key.

  Returns both the canonical key
  and the canonical value or an error.

  """
  def decode("language" = key, {:ok, language_tag}) do
    {:ok, {map(key), language_tag}}
  end

  def decode("language", {:error, error_language_tag}) do
    {:error, error_language_tag}
  end

  def decode(key, value) do
    with {:ok, value} <- valid(key, value) do
      {:ok, {map(key), atomize(value)}}
    else
      {:error, _value} ->
        {:error, U.invalid_value_error(key, value)}
    end
  end

  @doc """
  Encodes a key and value into the
  form required for a string version
  of a language tag.

  """

  def encode(key, value) do
    unmapped_key = unmap(key)
    {unmapped_key, encode_key(unmapped_key, value)}
  end

  # Encode key functions take the form that is
  # in the language tag locale struct and encodes it
  # back to what is required in a textual form of
  # the locale.

  for {key, values} <- @validity_data, key in @process_keys do
    inverted_values = Enum.map(values, &String.to_atom/1)

    defp encode_key(unquote(key), value) when value in unquote(inverted_values) do
      Atom.to_string(value)
    end
  end

  defp encode_key("language", nil) do
    nil
  end

  defp encode_key("language", language) do
    String.downcase(language.canonical_locale_name)
  end

  # Check that the value provided
  # is acceptable for the given key.

  for {key, values} <- @validity_data, key in @process_keys do
    defp valid(unquote(key), value) when value in unquote(values) do
      {:ok, value}
    end
  end

  defp valid(key, value) when key in @valid_keys do
    {:error, U.invalid_value_error(key, value)}
  end

  defp valid("language", language) do
    language
  end

  defp valid(key, _value) do
    {:error, U.invalid_key_error(key)}
  end

  defp map(key) do
    Map.fetch!(@field_mapping, key)
  end

  defp unmap(key) do
    Map.fetch!(@inverse_field_mapping, key)
  end

  defp atomize(value) when is_atom(value) do
    value
  end

  defp atomize(value) when is_binary(value) do
    String.to_atom(value)
  end

  defp atomize(other) do
    other
  end

end