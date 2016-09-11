defmodule Cldr.Consolidate do
  @moduledoc """
  Consolidates all locale-specific information from the CLDR repository into
  one locale-specific file in the ./cldr directory
  """

  @cldr_modules ["number_formats", "list_formats", "currencies",
    "number_systems", "number_symbols", "minimum_grouping_digits"]

  def required_modules do
    @cldr_modules
  end

  def consolidate_locales do
    ensure_output_dir_exists!(output_dir())
    ensure_output_dir_exists!(locales_dir())

    save_plurals()
    save_number_systems()
    save_locales()

    all_locales()
    |> Enum.chunk(8, 8, [])
    |> Enum.each(fn chunk ->
         Enum.map(chunk, &Task.async(fn -> consolidate_locale(&1) end))
         |> Enum.map(&Task.await(&1, 100_000))
       end)
    :ok
  end

  def consolidate_known_locales do
    for locale <- Cldr.known_locales do
      consolidate_locale(locale)
    end
  end

  def consolidate_locale(locale) do
    cldr_locale_specific_dirs()
    |> consolidate_locale_content(locale)
    |> level_up_locale(locale)
    |> Cldr.Map.underscore_keys
    |> normalize_content(locale)
    |> Map.take(@cldr_modules)
    |> Cldr.Map.atomize_keys
    |> save_locale(locale)
  end

  def consolidate_locale_content(locale_dirs, locale) do
    locale_dirs
    |> Enum.map(&locale_specific_content(locale, &1))
    |> merge_maps
  end

  def normalize_content(content, locale) do
    Cldr.Normalize.Number.normalize(content, locale)
    |> Cldr.Normalize.Currency.normalize(locale)
    |> Cldr.Normalize.List.normalize(locale)
    |> Cldr.Normalize.NumberSystem.normalize(locale)
  end

  # Remove the top two levels of the map since they add nothing
  # but more levels :-)
  def level_up_locale(content, locale) do
    get_in(content, ["main", locale])
  end

  def save_locale(content, locale) do
    output_path = Path.join(locales_dir(), "#{locale}.json")
    File.write!(output_path, Poison.encode!(content))
  end

  def merge_maps([file_1]) do
    file_1
  end

  def merge_maps([file_1, file_2]) do
    Cldr.Map.deep_merge(file_1, file_2)
  end

  def merge_maps([file | rest]) do
    Cldr.Map.deep_merge(file, merge_maps(rest))
  end

  def locale_specific_content(locale, directory) do
    dir = Path.join(directory, ["main/", locale])

    dir
    |> File.ls!
    |> Enum.map(&Path.join(dir, &1))
    |> Enum.map(&File.read!(&1))
    |> Enum.map(&Poison.decode!(&1))
    |> merge_maps
  end

  def cldr_locale_specific_dirs do
    cldr_directories()
    |> Enum.filter(&locale_specific_dir?/1)
  end

  def locale_specific_dir?(filename) do
    String.ends_with?(filename, "-full")
  end

  def cldr_directories do
    data_dir()
    |> File.ls!
    |> Enum.filter(&cldr_dir?/1)
    |> Enum.map(&Path.join(data_dir(), &1))
  end

  defp cldr_dir?("common") do
    true
  end

  defp cldr_dir?(filename) do
    String.starts_with?(filename, "cldr-")
  end

  defp ensure_output_dir_exists!(dir) do
    case File.mkdir(dir) do
      :ok ->
        :ok
      {:error, :eexist} ->
        :ok
      {:error, code} ->
        raise RuntimeError,
          message: "Couldn't create #{dir}: #{inspect code}"
    end
  end

  def all_locales() do
    data_dir()
    |> Path.join(["cldr-core", "/availableLocales.json"])
    |> File.read!
    |> Poison.decode!
    |> get_in(["availableLocales", "full"])
  end

  def data_dir do
    Path.join(Cldr.Config.app_home, "data")
  end

  def output_dir do
    Path.join(data_dir(), "/consolidated")
  end

  def locales_dir do
    Path.join(output_dir(), "/locales")
  end

  def save_locales do
    path = Path.join(output_dir(), "available_locales.json")
    save_file(all_locales(), path)
  end

  def save_plurals do
    cardinal = Path.join(data_dir(), ["cldr-core", "/supplemental", "/plurals.json"])
    |> File.read!
    |> Poison.decode!
    |> get_in(["supplemental", "plurals-type-cardinal"])

    ordinal = Path.join(data_dir(), ["cldr-core", "/supplemental", "/ordinals.json"])
    |> File.read!
    |> Poison.decode!
    |> get_in(["supplemental", "plurals-type-ordinal"])

    content = %{cardinal: cardinal, ordinal: ordinal}
    save_file(content, Path.join(output_dir(), "plural_rules.json"))
  end

  def save_number_systems do
    Path.join(data_dir(), ["cldr-core", "/supplemental", "/numberingSystems.json"])
    |> File.read!
    |> Poison.decode!
    |> get_in(["supplemental", "numberingSystems"])
    |> remove_leading_underscores
    |> save_file(Path.join(output_dir(), "number_systems.json"))
  end

  def remove_leading_underscores(%{} = systems) do
    Enum.map(systems, fn {k, v} ->
      {String.replace_prefix(k, "_", ""), remove_leading_underscores(v)} end)
    |> Enum.into(%{})
  end
  def remove_leading_underscores(v), do: v

  def save_file(content, path) do
    File.write!(path, Poison.encode!(content))
  end
end