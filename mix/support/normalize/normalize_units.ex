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
      |> Enum.into(%{})
      |> process_unit_types(@unit_types)

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

        {type, template} ->
          {type, Substitution.parse(template)}
      end)
      |> Enum.group_by(&(elem(&1, 0)), &(elem(&1, 1)))
      |> Enum.map(fn
        {k, v} when is_atom(k) -> {k, Map.new(v)}
        {k, [v]} -> {k, v}
      end)
      |> Map.new

    %{unit => parsed_formats}
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
