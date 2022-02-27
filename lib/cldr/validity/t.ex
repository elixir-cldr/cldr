defmodule Cldr.Validity.T do
  @moduledoc false

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

  def field_mapping do
    @field_mapping
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

  def decode("x0" = key, private_use) do
    {:ok, {map(key), private_use}}
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

  defp encode_key(key, values) when is_list(values) do
    values
    |> Enum.map(&encode_key(key, &1))
    |> Enum.join("-")
  end

  defp encode_key(_key, {year}) do
    to_string(year)
  end

  defp encode_key(_key, {year, month}) do
    to_string(year) <> pad(month) <> to_string(month)
  end

  defp encode_key(_key, {year, month, day}) do
    to_string(year) <> pad(month) <> to_string(month) <> pad(day) <> to_string(day)
  end

  defp encode_key("language", nil) do
    nil
  end

  defp encode_key("language", language) do
    String.downcase(language.canonical_locale_name)
  end

  defp encode_key("x0", private_use) when is_list(private_use) do
    Enum.join(private_use, "-")
  end

  defp encode_key("x0", private_use) do
    private_use
  end

  # Check that the value provided
  # is acceptable for the given key.

  for {key, values} <- @validity_data, key in @process_keys do
    defp valid(unquote(key), value) when value in unquote(values) do
      {:ok, String.to_atom(value)}
    end
  end

  defp valid(key, values) when is_list(values) do
    case valid_list(key, values) do
      {:ok, values} ->
        # Dates sort to the end
        Enum.sort(values, fn
          <<digit_1::utf8, _rest_1::binary>>, <<digit_2::utf8, _rest_2::binary>>
              when digit_1 >= ?0 and digit_1 <= ?9 and digit_2 >= ?0 and digit_2 <= ?9 ->
            digit_1 < digit_2

          <<digit_1::utf8, _rest::binary>>, _date_2 when digit_1 >= ?0 and digit_1 <= ?9 ->
            false

          _date_1, <<digit_1::utf8, _rest::binary>> when digit_1 >= ?0 and digit_1 <= ?9 ->
            true

          value_1, value_2 ->
            value_1 < value_2
        end)
        |> wrap(:ok)

      other ->
        other
    end
  end

  defp valid(key, value) when key in @valid_keys do
    case Integer.parse(value) do
      {_integer, ""} -> {:ok, make_date_tuple(value)}
      _other -> {:error, U.invalid_value_error(key, value)}
    end
  end

  defp valid("language", language) do
    language
  end

  defp valid("x0", private_use) do
    private_use
  end

  defp valid(key, _value) do
    {:error, U.invalid_key_error(key)}
  end

  def valid_list(key, values) do
    Enum.reduce_while(values, {:ok, []}, fn value, {:ok, acc} ->
      # if we push a date tuple on a prior round then the
      # date tuple isn't in last place which it is required to
      # be so we return an error
      if length(acc) > 0 && is_tuple(hd(acc)) do
        {:halt, {:error, invalid_date_order(key, hd(acc))}}
      else
        case valid(key, value) do
          {:ok, value} -> {:cont, {:ok, [value | acc]}}
          {:error, _value} -> {:halt, {:error, U.invalid_value_error(key, value)}}
        end
      end
    end)
  end

  def wrap(term, atom) do
    {atom, term}
  end

  def pad(number) when number < 10, do: " "
  def pad(_number), do: ""

  defp make_date_tuple(<<year::binary-4, month::binary-2, day::binary-2>>) do
    {String.to_integer(year), String.to_integer(month), String.to_integer(day)}
  end

  defp make_date_tuple(<<year::binary-4, month::binary-2>>) do
    {String.to_integer(year), String.to_integer(month)}
  end

  defp make_date_tuple(<<year::binary-4>>) do
    {String.to_integer(year)}
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

  defp invalid_date_order(key, value) do
    encoded = encode_key(key, value)

    {Cldr.LanguageTag.ParseError,
     "The date #{inspect(encoded)} must be the last value in a subtag"}
  end
end
