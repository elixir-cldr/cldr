# credo:disable-for-this-file
defmodule Cldr.Normalize.Units do
  @moduledoc false

  alias Cldr.Substitution

  def normalize(content, locale) do
    content
    |> normalize_units(locale)
  end

  @unit_types ["short", "long", "narrow"]
  def normalize_units(content, locale) do
    units =
      units_for_locale(locale)
      |> get_in(["main", locale, "units"])
      |> Cldr.Map.underscore_keys()

    normalized_units =
      units
      |> Enum.filter(fn {k, _v} -> k in @unit_types end)
      |> Map.new()
      |> process_unit_types(@unit_types)
      |> Enum.map(fn {style, units} -> {style, group_units(units)} end)
      |> Map.new()
      |> Cldr.Map.atomize_keys()

    Map.put(content, "units", normalized_units)
  end

  def process_unit_types(%{} = content, unit_types) do
    Enum.reduce(unit_types, content, &process_unit_type(&1, &2))
  end

  def process_unit_type(type, %{} = content) do
    updated_format =
      get_in(content, [type])
      |> Enum.map(&process_formats/1)
      |> Cldr.Map.merge_map_list()

    put_in(content, [type], updated_format)
  end

  def process_formats({unit, formats}) do
    parsed_formats =
      Enum.map(formats, fn
        {"unit_pattern_count_" <> count, template} ->
          {:nominative, {count, Substitution.parse(template)}}

        {"genitive_count_" <> count, template} ->
          {:genitive, {count, Substitution.parse(template)}}

        {"accusative_count_" <> count, template} ->
          {:accusative, {count, Substitution.parse(template)}}

        {"dative_count_" <> count, template} ->
          {:dative, {count, Substitution.parse(template)}}

        {"locative_count_" <> count, template} ->
          {:locative, {count, Substitution.parse(template)}}

        {"instrumental_count_" <> count, template} ->
          {:instrumental, {count, Substitution.parse(template)}}

        {"vocative_count_" <> count, template} ->
          {:vocative, {count, Substitution.parse(template)}}

        {"display_name", display_name} ->
          {"display_name", display_name}

        {"gender", gender} ->
          {"gender", gender}

        {"compound_unit_pattern1" <> rest, template} ->
          {"compound_unit_pattern", compound_unit(rest, template)}

        {type, template} ->
          {type, Substitution.parse(template)}
      end)
      |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
      |> Enum.map(fn
        {k, v} when is_atom(k) ->
          {k, Map.new(v)}

        {k, [v]} ->
          {k, v}

        {k, v} when is_list(v) ->
          {k, map_nested_compounds(v)}
      end)
      |> Map.new()

    %{unit => parsed_formats}
  end

  # Decode compound units which can have
  # a count, a gender and a grammatical case
  # but not necessarily all of them

  # The order is <gender> <count> <case>

  def compound_unit("_" <> rest, template) do
    compound_unit(rest, template)
  end

  def compound_unit("", template) do
    {:nominative, template}
  end

  # Could be count_one or count_one_case_...
  # Followed by a potential "case_"
  def compound_unit("count_" <> rest, template) do
    case String.split(rest, "_", parts: 2) do
      [count] ->
        {count, template}

      [count, rest] ->
        {count, compound_unit(rest, template)}
    end
  end

  # Grammatical case is the terminal clause, nothing
  # after it
  def compound_unit("case_" <> grammatical_case, template) do
    {grammatical_case, template}
  end

  # Could be gender_masculine_count_one or gender_masculine_count_one_case_...
  def compound_unit("gender_" <> rest, template) do
    [gender, rest] = String.split(rest, "_", parts: 2)
    {gender, compound_unit(rest, template)}
  end

  # Take the nested structure and turn it into maps

  def map_nested_compounds(list, acc \\ Map.new())

  def map_nested_compounds([], acc) do
    acc
  end

  def map_nested_compounds(value, %{} = _acc) when is_binary(value) do
    Substitution.parse(value)
  end

  def map_nested_compounds({key, value}, acc) do
    Map.put(acc, key, map_nested_compounds(value))
  end

  def map_nested_compounds([{key, value} | rest], acc) do
    mapped_value = map_nested_compounds(value)

    acc =
      Map.update(acc, key, mapped_value, fn
        current when is_map(current) and is_map(mapped_value) ->
          Map.merge(current, mapped_value)

        current when is_map(current) ->
          Map.put(current, :nominative, mapped_value)

        current when is_list(current) ->
          value
          |> map_nested_compounds()
          |> Map.put(:nominative, current)
      end)

    map_nested_compounds(rest, acc)
  end

  def units_for_locale(locale) do
    if File.exists?(locale_path(locale)) do
      locale
      |> locale_path
      |> File.read!()
      |> Jason.decode!()
    else
      {:error, {:units_file_not_found, locale_path(locale)}}
    end
  end

  defp group_units(units) do
    units
    |> Enum.map(fn {k, v} ->
      [group | key] =
        cond do
          String.starts_with?(k, "10p") -> [k | []]
          String.starts_with?(k, "1024p") -> [k | []]
          true -> String.split(k, "_", parts: 2)
        end

      if key == [] do
        {"compound", group, v}
      else
        [key] = key
        {group, key, v}
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.group_by(
      fn {group, _key, _value} -> group end,
      fn {_group, key, value} -> {key, atomize_gender(value)} end
    )
    |> Enum.map(fn {k, v} -> {k, Map.new(v)} end)
    |> Map.new()
  end

  defp atomize_gender(map) when is_map(map) do
    map
    |> Enum.map(&atomize_gender/1)
    |> Map.new()
  end

  defp atomize_gender({"gender" = key, [gender]}), do: {key, String.to_atom(gender)}
  defp atomize_gender({"gender" = key, gender}), do: {key, String.to_atom(gender)}
  defp atomize_gender(other), do: other

  @spec locale_path(binary) :: String.t()
  def locale_path(locale) when is_binary(locale) do
    Path.join(units_dir(), [locale, "/units.json"])
  end

  @units_dir Path.join(Cldr.Config.download_data_dir(), ["cldr-units-full", "/main"])

  @spec units_dir :: String.t()
  def units_dir do
    @units_dir
  end
end
