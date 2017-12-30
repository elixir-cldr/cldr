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
      if units do
        units
        |> Enum.filter(fn {k, _v} -> k in @unit_types end)
        |> Cldr.Map.delete_in("display_name")
        |> Enum.into(%{})
        |> process_unit_types(@unit_types)
      else
        %{}
      end

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
        {"unit_pattern_count_" <> type, template} ->
          {type, Substitution.parse(template)}

        {type, template} ->
          {type, Substitution.parse(template)}
      end)
      |> Enum.into(%{})

    %{unit => parsed_formats}
  end

  def units_for_locale(locale) do
    if File.exists?(locale_path(locale)) do
      locale
      |> locale_path
      |> File.read!()
      |> Poison.decode!()
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
