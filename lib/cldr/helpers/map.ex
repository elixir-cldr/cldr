defmodule Cldr.Map do
  @moduledoc """
  Functions for transforming maps, keys and values.
  """

  @doc """
  Recursively traverse a map and invoke a function for each key/
  value pair that transforms the map.

  ## Arguments

  * `map` is any `Map.t`

  * `function` is a function or function reference that
    is called for each key/value pair of the provided map

  ## Returns

  * The `map` transformed by the recursive application of
    `function`

  ## Example

    iex> map = %{a: "a", b: %{c: "c"}}
    iex> Cldr.Map.deep_map map, fn {k, v} ->
    ...>   {k, String.upcase(v)}
    ...> end
    %{a: "A", b: %{c: "C"}}

  """
  @spec deep_map(Map.t(), function :: function()) :: Map.t()

  # Don't deep map structs since they have atom keys anyway and they
  # also don't support enumerable
  def deep_map(%_struct{} = map, _function) when is_map(map) do
    map
  end

  def deep_map(map, function) when is_map(map) do
    Enum.map(map, fn
      {k, v} when is_map(v) or is_list(v) ->
        {k, deep_map(v, function)}

      {k, v} ->
        function.({k, v})
    end)
    |> Enum.into(%{})
  end

  def deep_map([head | rest], fun) do
    [deep_map(head, fun) | deep_map(rest, fun)]
  end

  def deep_map(nil, _fun) do
    nil
  end

  def deep_map(value, fun) do
    fun.(value)
  end

  @doc """
  Recursively traverse a map and invoke a function for each key
  and a function for each value that transform the map.

  * `map` is any `Map.t`

  * `key_function` is a function or function reference that
    is called for each key of the provided map and any keys
    of any submaps

  * `value_function` is a function or function reference that
    is called for each value of the provided map and any values
    of any submaps

  Returns:

  * The `map` transformed by the recursive application of `key_function`
    and `value_function`

  ## Examples

  """
  @spec deep_map(Map.t(), key_function :: function(), value_function :: function()) :: Map.t()
  def deep_map(map, key_function, value_function)

  # Don't deep map structs since they have atom keys anyway and they
  # also don't support enumerable
  def deep_map(%_struct{} = map, _key_function, _value_function) when is_map(map) do
    map
  end

  def deep_map(map, key_function, value_function) when is_map(map) do
    Enum.map(map, fn
      {k, v} when is_map(v) or is_list(v) ->
        {key_function.(k), deep_map(v, key_function, value_function)}

      {k, v} ->
        {key_function.(k), value_function.(v)}
    end)
    |> Enum.into(%{})
  end

  def deep_map([head | rest], key_fun, value_fun) do
    [deep_map(head, key_fun, value_fun) | deep_map(rest, key_fun, value_fun)]
  end

  def deep_map(nil, _key_fun, _value_fun) do
    nil
  end

  def deep_map(value, _key_fun, value_fun) do
    value_fun.(value)
  end

  @doc """
  Transforms a `map`'s `String.t` keys to `atom()` keys.

  * `map` is any `Map.t`

  * `options` is a keyword list of options.  The
    available option is:

    * `:only_existing` which is set to `true` will
      only convert the binary key to an atom if the atom
      already exists.  The default is `false`.

  ## Examples

  """
  def atomize_keys(map, options \\ [only_existing: false]) do
    deep_map(map, &atomize_element(&1, options[:only_existing]), &identity/1)
  end

  @doc """
  Transforms a `map`'s `String.t` values to `atom()` values.

  * `map` is any `Map.t`

  * `options` is a keyword list of options.  The
    available option is:

    * `:only_existing` which is set to `true` will
      only convert the binary value to an atom if the atom
      already exists.  The default is `false`.

  ## Examples

  """
  def atomize_values(map, options \\ [only_existing: false]) do
    deep_map(map, &identity/1, &atomize_element(&1, options[:only_existing]))
  end

  @doc """
  Transforms a `map`'s `atom()` keys to `String.t` keys.

  * `map` is any `Map.t`

  ## Examples

  """
  def stringify_keys(map) do
    deep_map(
      map,
      fn
        k when is_atom(k) -> Atom.to_string(k)
        k -> k
      end,
      &identity/1
    )
  end

  @doc """
  Transforms a `map`'s keys to `Integer.t` keys.

  * `map` is any `Map.t`

  The map key is converted to an `integer` from
  either an `atom` or `String.t` only when the
  key is comprised of `integer` digits.

  Keys which cannot be converted to an `integer`
  are returned unchanged.

  ## Examples

  """
  def integerize_keys(map) do
    deep_map(map, &integerize_element/1, &identity/1)
  end

  @doc """
  Transforms a `map`'s values to `Integer.t` values.

  * `map` is any `Map.t`

  The map value is converted to an `integer` from
  either an `atom` or `String.t` only when the
  value is comprised of `integer` digits.

  Keys which cannot be converted to an integer
  are returned unchanged.

  ## Examples

  """
  def integerize_values(map) do
    deep_map(map, &identity/1, &integerize_element/1)
  end

  @doc """
  Transforms a `map`'s values to `Float.t` values.

  * `map` is any `Map.t`

  The map value is converted to a `float` from
  either an `atom` or `String.t` only when the
  value is comprised of a valid float forma.

  Keys which cannot be converted to a `float`
  are returned unchanged.

  ## Examples

  """
  def floatize_values(map) do
    deep_map(map, &identity/1, &floatize_element/1)
  end

  @doc """
  Rename map keys from `from` to `to`

  * `map` is any `Map.t`

  * `from` is any value map key

  * `to` is any valud map key

  ## Examples

  """
  def rename_key(map, from, to) do
    deep_map(
      map,
      fn
        ^from -> to
        other -> other
      end,
      &identity/1
    )
  end

  @doc """
  Convert map keys from `camelCase` to `snake_case`

  * `map` is any `Map.t`

  ## Examples

  """
  def underscore_keys(map = %{}) do
    deep_map(map, &underscore/1, &identity/1)
  end

  @doc """
  Removes any leading underscores from `map`
  keys.

  * `map` is any `Map.t`

  ## Examples

  """
  def remove_leading_underscores(map) do
    deep_map(map, &String.replace_prefix(&1, "_", ""), &identity/1)
  end

  @doc """
  Returns the result of deep merging a list of maps

  ## Examples

      iex> Cldr.Map.merge_map_list [%{a: "a", b: "b"}, %{c: "c", d: "d"}]
      %{a: "a", b: "b", c: "c", d: "d"}

  """
  def merge_map_list([h | []]) do
    h
  end

  def merge_map_list([h | t]) do
    deep_merge(h, merge_map_list(t))
  end

  def merge_map_list([]) do
    []
  end

  @doc """
  Deep merge two maps

  * `left` is any `Map.t`

  * `right` is any `Map.t`

  ## Examples

      iex> Cldr.Map.deep_merge %{a: "a", b: "b"}, %{c: "c", d: "d"}
      %{a: "a", b: "b", c: "c", d: "d"}

      iex> Cldr.Map.deep_merge %{a: "a", b: "b"}, %{c: "c", d: "d", a: "aa"}
      %{a: "aa", b: "b", c: "c", d: "d"}

  """
  def deep_merge(left, right) do
    Map.merge(left, right, &deep_resolve/3)
  end

  # Key exists in both maps, and both values are maps as well.
  # These can be merged recursively.
  defp deep_resolve(_key, left = %{}, right = %{}) do
    deep_merge(left, right)
  end

  # Key exists in both maps, but at least one of the values is
  # NOT a map. We fall back to standard merge behavior, preferring
  # the value on the right.
  defp deep_resolve(_key, _left, right) do
    right
  end

  @doc """
  Delete all members of a map that have a
  key in the list of keys

  ## Examples

      iex> Cldr.Map.delete_in %{a: "a", b: "b"}, [:a]
      %{b: "b"}

  """
  def delete_in(%{} = map, keys) when is_list(keys) do
    Enum.reject(map, fn {k, _v} -> k in keys end)
    |> Enum.map(fn {k, v} -> {k, delete_in(v, keys)} end)
    |> Enum.into(%{})
  end

  def delete_in(map, keys) when is_list(map) and is_binary(keys) do
    delete_in(map, [keys])
  end

  def delete_in(map, keys) when is_list(map) do
    Enum.reject(map, fn {k, _v} -> k in keys end)
    |> Enum.map(fn {k, v} -> {k, delete_in(v, keys)} end)
  end

  def delete_in(%{} = map, keys) when is_binary(keys) do
    delete_in(map, [keys])
  end

  def delete_in(other, _keys) do
    other
  end

  def from_keyword(keyword) do
    Enum.into(keyword, %{})
  end

  defp identity(x), do: x

  defp atomize_element(x, true) when is_binary(x) do
    String.to_existing_atom(x)
  rescue
    ArgumentError ->
      x
  end

  defp atomize_element(x, false) when is_binary(x) do
    String.to_atom(x)
  end

  defp atomize_element(x, _) do
    x
  end

  @integer_reg Regex.compile!("^[0-9]+$")
  defp integerize_element(x) when is_atom(x) do
    integer =
      x
      |> Atom.to_string()
      |> integerize_element

    if is_integer(integer) do
      integer
    else
      x
    end
  end

  defp integerize_element(x) when is_binary(x) do
    if Regex.match?(@integer_reg, x) do
      String.to_integer(x)
    else
      x
    end
  end

  defp integerize_element(x) do
    x
  end

  @float_reg Regex.compile!("^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$")
  defp floatize_element(x) when is_atom(x) do
    x
    |> Atom.to_string()
    |> floatize_element
  end

  defp floatize_element(x) when is_binary(x) do
    if Regex.match?(@float_reg, x) do
      String.to_float(x)
    else
      x
    end
  end

  defp floatize_element(x) do
    x
  end

  @doc """
  Convert a camelCase string or atome to a snake_case

  * `string` is a `String.t` or `atom()` to be
    transformed

  This is the code of Macro.underscore with modifications.
  The change is to cater for strings in the format:

    This_That

  which in Macro.underscore gets formatted as

    this__that (note the double underscore)

  when we actually want

    that_that

  ## Examples

  """
  @spec underscore(string :: String.t() | atom()) :: String.t()
  def underscore(atom) when is_atom(atom) do
    "Elixir." <> rest = Atom.to_string(atom)
    underscore(rest)
  end

  def underscore(<<h, t::binary>>) do
    <<to_lower_char(h)>> <> do_underscore(t, h)
  end

  def underscore("") do
    ""
  end

  # h is upper case, next char is not uppercase, or a _ or .  => and prev != _
  defp do_underscore(<<h, t, rest::binary>>, prev)
       when h >= ?A and h <= ?Z and not (t >= ?A and t <= ?Z) and t != ?. and t != ?_ and t != ?- and
              prev != ?_ do
    <<?_, to_lower_char(h), t>> <> do_underscore(rest, t)
  end

  # h is uppercase, previous was not uppercase or _
  defp do_underscore(<<h, t::binary>>, prev)
       when h >= ?A and h <= ?Z and not (prev >= ?A and prev <= ?Z) and prev != ?_ do
    <<?_, to_lower_char(h)>> <> do_underscore(t, h)
  end

  # h is dash "-" -> replace with underscore "_"
  defp do_underscore(<<?-, t::binary>>, _) do
    <<?_>> <> underscore(t)
  end

  # h is .
  defp do_underscore(<<?., t::binary>>, _) do
    <<?/>> <> underscore(t)
  end

  # Any other char
  defp do_underscore(<<h, t::binary>>, _) do
    <<to_lower_char(h)>> <> do_underscore(t, h)
  end

  defp do_underscore(<<>>, _) do
    <<>>
  end

  def to_upper_char(char) when char >= ?a and char <= ?z, do: char - 32
  def to_upper_char(char), do: char

  def to_lower_char(char) when char == ?-, do: ?_
  def to_lower_char(char) when char >= ?A and char <= ?Z, do: char + 32
  def to_lower_char(char), do: char
end
