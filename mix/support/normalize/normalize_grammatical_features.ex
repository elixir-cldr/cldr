defmodule Cldr.Normalize.GrammaticalFeatures do
  @moduledoc false

  def normalize(content) do
    content
    |> Enum.map(fn
      {<< language :: binary-size(2), "-targets-nominal" >>, case_data} ->
        {language, format_case_data(case_data)}

      {<< language :: binary-size(3), "-targets-nominal" >>, case_data} ->
        {language, format_case_data(case_data)}

      { "root" = language, compound_data} ->
        {language, format_compound_data(compound_data)}

      {<< language :: binary-size(2) >>, compound_data} ->
        {language, format_compound_data(compound_data)}
    end)
    |> Enum.group_by(fn {k, _v} -> k end, fn {_k, v} -> v end)
    |> Enum.map(fn {k, v} -> {k, Cldr.Map.merge_map_list(v)} end)
    |> Map.new
  end

  def format_case_data(case_data) do
    data =
      case_data
      |> Map.get("grammaticalCase")

    if is_nil(data), do: %{}, else: %{grammatical_cases: data}
  end

  def format_compound_data(compound_data) do
    compound_data
    |> Enum.map(fn
     {"deriveCompound-feature-gender-structure-" <> compound, value} ->
       {:gender, compound, String.to_integer(value)}

     {"deriveComponent-feature-plural-structure-" <> compound, value} ->
       {:plural, compound, format_values(value)}

     {"deriveComponent-feature-case-structure-" <> compound, value} ->
       {:case, compound, format_values(value)}
    end)
    |> Enum.group_by(
      fn {type, _compound, _values} -> type end,
      fn {_type, compound, values} -> {compound, values}
    end)
    |> Enum.map(fn {k, v} -> {k, Map.new(v)} end)
    |> Map.new
  end

  def format_values(values) do
    values
    |> Enum.map(fn
      {"_value" <> value, v} -> {String.to_integer(value), v}
    end)
    |> Map.new
  end

end
