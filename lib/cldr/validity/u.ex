defmodule Cldr.Validity.U do
  @moduledoc false

  @field_mapping %{
    "ca" => :calendar,
    "co" => :collation,
    "ka" => :col_alternate,
    "kb" => :col_backwards,
    "kc" => :col_case_level,
    "kf" => :col_case_first,
    "kh" => :col_hiragana_quaternary,
    "kk" => :col_normalization,
    "kn" => :col_numeric,
    "kr" => :col_reorder,
    "ks" => :col_strength,
    "kv" => :kv,
    "cu" => :currency,
    "cf" => :cf,
    "nu" => :numbers,
    "em" => :em,
    "fw" => :fw,
    "hc" => :hc,
    "lb" => :lb,
    "lw" => :lw,
    "ms" => :ms,
    "mu" => :mu,
    "ss" => :ss,
    "tz" => :timezone,
    "rg" => :rg,
    "sd" => :sd,
    "vt" => :vt,
    "va" => :va,
    "dx" => :dx
  }

  @fields Map.values(@field_mapping) |> Enum.sort
  @inverse_field_mapping Enum.map(@field_mapping, fn {k, v} -> {v, k} end) |> Map.new()
  @validity_data Cldr.Config.validity(:u)
  @dont_process_keys ["vt", "rg", "sd", "dx", "kr"]
  @valid_keys Map.keys(@validity_data)
  @process_keys @valid_keys -- @dont_process_keys

  @region_subtag_filler "zzzz"

  @doc false
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
  @dont_atomize ["tz", "rg", "sd", "kr"]
  def decode(key, value) when key in @dont_atomize do
    with {:ok, value} <- valid(key, value) do
      {:ok, {map(key), value}}
    else
      {:error, _value} ->
        {:error, invalid_value_error(key, value)}
    end
  end

  def decode(key, value) do
    with {:ok, value} <- valid(key, value) do
      {:ok, {map(key), atomize(value)}}
    else
      {:error, _value} ->
        {:error, invalid_value_error(key, value)}
    end
  end

  @doc """
  Encodes a key and value into the
  form required for a string version
  of a language tag.

  """

  # Calendar names may be compound like
  # islamic-rgsa
  def encode(:calendar = key, value) do
    unmapped_key = unmap(key)

    value =
      unmapped_key
      |> encode_key(value)
      |> String.replace("_", "-")

    {unmapped_key, value}
  end

  def encode(key, value) do
    unmapped_key = unmap(key)
    {unmapped_key, encode_key(unmapped_key, value)}
  end

  # Encode key functions take the form that is
  # in the language tag locale struct and encodes it
  # back to what is required in a textual form of
  # the locale.

  for {key, values} <- @validity_data, key in @process_keys do
    inverted_values =
      Enum.map(values, fn
        {k, v} when is_list(v) -> Enum.map(v, fn tz -> {tz, k} end)
        {k, nil} -> {String.to_atom(k), k}
        {k, v} -> {String.to_atom(v), k}
      end)
      |> List.flatten()
      |> Map.new()

    defp encode_key(unquote(key), value) when value in unquote(Map.keys(inverted_values)) do
      unquote(Macro.escape(inverted_values))
      |> Map.fetch!(value)
    end
  end

  defp encode_key("cu", value) do
    value
    |> Atom.to_string()
    |> String.downcase()
  end

  defp encode_key("rg", value) when is_atom(value) do
    value
    |> Atom.to_string()
    |> String.downcase()
    |> Kernel.<>(@region_subtag_filler)
  end

  defp encode_key("rg", value) do
    value
  end

  defp encode_key("sd", value) do
    value
  end

  defp encode_key("vt", value) do
    value
    |> String.downcase()
  end

  defp encode_key("kr", values) when is_list(values) do
    values
    |> Enum.map(&to_string/1)
    |> Enum.map(&String.downcase/1)
    |> Enum.join("-")
  end

  defp encode_key("dx", value) when is_atom(value) do
    value
    |> Atom.to_string()
    |> String.downcase()
  end

  defp encode_key("dx", values) when is_list(values) do
    values
    |> Enum.map(&to_string/1)
    |> Enum.map(&String.downcase/1)
    |> Enum.join("-")
  end

  # valid function check that the value provided
  # is acceptable for the given key.

  for {key, values} <- @validity_data, key in @process_keys do
    defp valid(unquote(key), value) when value in unquote(Map.keys(values)) do
      unquote(Macro.escape(values))
      |> get_value(unquote(key), value)
      |> maybe_get_list_head()
      |> wrap(:ok)
    end
  end

  # Calendar names may be compound like
  # islamic-rgsa
  defp valid("ca", values) when is_list(values) do
    valid("ca", Enum.join(values, "_"))
  end

  # Codepoints?
  defp valid("vt", value) do
    {:ok, value}
  end

  defp valid("rg", <<value::binary-size(2), "#{@region_subtag_filler}">>) do
    case Cldr.Validity.Territory.validate(value) do
      {:ok, territory, _status} -> {:ok, territory}
      other -> other
    end
  end

  defp valid("rg", value) do
    case Cldr.Validity.Subdivision.validate(value) do
      {:ok, subdivision, _status} -> {:ok, subdivision}
      other -> other
    end
  end

  defp valid("sd", value) do
    case Cldr.Validity.Subdivision.validate(value) do
      {:ok, subdivision, _status} -> {:ok, subdivision}
      other -> other
    end
  end

  # dx can be more than one script
  defp valid("dx", value) when is_binary(value) do
    case Cldr.Validity.Script.validate(value) do
      {:ok, script, _status} -> {:ok, script}
      other -> other
    end
  end

  defp valid("dx" = key, values) when is_list(values) do
    Enum.reduce_while(values, {:ok, []}, fn value, {:ok, acc} ->
      case Cldr.Validity.Script.validate(value) do
        {:ok, script, _status} -> {:cont, {:ok, [script | acc]}}
        {:error, _script} -> {:halt, {:error, invalid_value_error(key, value)}}
      end
    end)
  end

  @kr_valid_values @validity_data["kr"] |> Map.delete("REORDER_CODE")
  defp valid("kr", value) when is_binary(value) do
    cond do
      Map.has_key?(@kr_valid_values, value) ->
        {:ok, [atomize(value)]}
      true ->
        case Cldr.Validity.Script.validate(value) do
          {:ok, script, _status} -> {:ok, [script]}
          other -> other
        end
    end
  end

  defp valid("kr" = key, values) when is_list(values) do
    Enum.reduce_while(values, {:ok, []}, fn value, {:ok, acc} ->
      case valid("kr", value) do
        {:ok, [reorder_code]} -> {:cont, {:ok, [reorder_code | acc]}}
        {:error, _reorder_code} -> {:halt, {:error, invalid_value_error(key, value)}}
      end
    end)
    |> case do
      {:ok, list} -> {:ok, Enum.reverse(list)}
      other -> other
    end
  end

  defp valid(key, value) when key in @valid_keys do
    {:error, invalid_value_error(key, value)}
  end

  defp valid(key, _value) do
    {:error, invalid_key_error(key)}
  end

  defp get_value(map, "cu", value) do
    (Map.get(map, value) || value)
    |> String.upcase()
  end

  defp get_value(map, _key, value) do
    Map.get(map, value) || value
  end

  defp map(key) do
    Map.fetch!(@field_mapping, key)
  end

  defp unmap(key) do
    Map.fetch!(@inverse_field_mapping, key)
  end

  defp wrap(term, atom) do
    {atom, term}
  end

  defp maybe_get_list_head([head | _rest]) do
    head
  end

  defp maybe_get_list_head(other) do
    other
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

  @doc false
  def invalid_value_error(key, value) do
    {Cldr.LanguageTag.ParseError,
     "The value #{inspect(value)} is not valid for the key #{inspect(key)}"}
  end

  @doc false
  def invalid_key_error(key) do
    {Cldr.LanguageTag.ParseError, "The key #{inspect(key)} is not valid for the -u- subtag"}
  end
end
