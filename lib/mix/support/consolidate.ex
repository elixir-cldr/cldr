defmodule Cldr.Consolidate do
  @moduledoc """
  Consolidates all locale-specific information from the CLDR repository into
  one locale-specific file.
  """

  @cldr_modules ["number_formats", "list_formats", "currencies",
                 "number_systems", "number_symbols", "minimum_grouping_digits",
                 "rbnf"
                ]

  @doc """
  Identifies the top level keys in the consolidated locale file.

  These keys represent difference dimensions of content in the CLDR
  repository and serve three purposes:

  1. To structure the content in the locale file

  2. To provide a rudimentary way to validate that some json represents a
  valid locale file

  3. To all conditional inclusion of CLDR content at compile time to help
  manage memory footprint.  This capability is not yet built into `Cldr`.
  """
  @spec required_modules :: [String.t]
  def required_modules do
    @cldr_modules
  end

  @doc """
  Returns the directory where the downloaded CLDR repository files
  are stored.
  """
  def download_data_dir do
    Path.join(Cldr.Config.cldr_home, "data")
  end

  @doc """
  Returns the directory where the consolidated `Cldr` content is stored.

  We store the consolidated files in the `./priv/cldr` directory which
  is part of the github repo and therefore available for download.

  However only the "en" locale is packaged in hex and any other configured
  locales will be downloaded when the client app is compiled.
  """
  def consolidated_output_dir do
    Cldr.Install.cldr_data_dir()
  end

  @doc """
  Returns the directory where the locale-specific json files are stored.
  """
  def consolidated_locales_dir do
    Path.join(consolidated_output_dir(), "/locales")
  end

  @doc """
  Consolidates all available CLDR locale-specific json files into a set of
  locale-specific json files, one per locale.

  Also formats non-locale-specific CLDR data that is core to `Cldr`
  operation.
  """
  @spec consolidate_locales :: :ok
  def consolidate_locales do
    alias Experimental.Flow

    ensure_output_dir_exists!(consolidated_output_dir())
    ensure_output_dir_exists!(consolidated_locales_dir())

    save_plurals()
    save_number_systems()
    save_locales()

    all_locales()
    |> Flow.from_enumerable()
    |> Flow.map(&consolidate_locale/1)
    |> Enum.to_list
    :ok
  end

  @doc """
  Consolidates known locales as defined by `Cldr.known_locales/0`.
  """
  @spec consolidate_known_locales :: :ok
  def consolidate_known_locales do
    for locale <- Cldr.known_locales do
      consolidate_locale(locale)
    end
    :ok
  end

  @doc """
  Consolidates one locale.

  * `locale` is any locale defined by `Cldr.all_locales/0`
  """
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

  defp consolidate_locale_content(locale_dirs, locale) do
    locale_dirs
    |> Enum.map(&locale_specific_content(locale, &1))
    |> merge_maps
  end

  defp normalize_content(content, locale) do
    Cldr.Normalize.Number.normalize(content, locale)
    |> Cldr.Normalize.Currency.normalize(locale)
    |> Cldr.Normalize.List.normalize(locale)
    |> Cldr.Normalize.NumberSystem.normalize(locale)
    |> Cldr.Normalize.Rbnf.normalize(locale)
  end

  # Remove the top two levels of the map since they add nothing
  # but more levels :-)
  defp level_up_locale(content, locale) do
    get_in(content, ["main", locale])
  end

  defp save_locale(content, locale) do
    output_path = Path.join(consolidated_locales_dir(), "#{locale}.json")
    File.write!(output_path, Poison.encode!(content))
  end

  defp merge_maps([file_1]) do
    file_1
  end

  defp merge_maps([file_1, file_2]) do
    Cldr.Map.deep_merge(file_1, file_2)
  end

  defp merge_maps([file | rest]) do
    Cldr.Map.deep_merge(file, merge_maps(rest))
  end

  defp locale_specific_content(locale, directory) do
    dir = Path.join(directory, ["main/", locale])

    dir
    |> File.ls!
    |> Enum.map(&Path.join(dir, &1))
    |> Enum.map(&File.read!(&1))
    |> Enum.map(&Poison.decode!(&1))
    |> merge_maps
  end

  defp cldr_locale_specific_dirs do
    cldr_directories()
    |> Enum.filter(&locale_specific_dir?/1)
  end

  defp locale_specific_dir?(filename) do
    String.ends_with?(filename, "-full")
  end

  defp cldr_directories do
    download_data_dir()
    |> File.ls!
    |> Enum.filter(&cldr_dir?/1)
    |> Enum.map(&Path.join(download_data_dir(), &1))
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
    download_data_dir()
    |> Path.join(["cldr-core", "/availableLocales.json"])
    |> File.read!
    |> Poison.decode!
    |> get_in(["availableLocales", "full"])
  end

  defp save_locales do
    path = Path.join(consolidated_output_dir(), "available_locales.json")
    save_file(all_locales(), path)
  end

  defp save_plurals do
    cardinal = Path.join(download_data_dir(), ["cldr-core", "/supplemental", "/plurals.json"])
    |> File.read!
    |> Poison.decode!
    |> get_in(["supplemental", "plurals-type-cardinal"])

    ordinal = Path.join(download_data_dir(), ["cldr-core", "/supplemental", "/ordinals.json"])
    |> File.read!
    |> Poison.decode!
    |> get_in(["supplemental", "plurals-type-ordinal"])

    content = %{cardinal: cardinal, ordinal: ordinal}
    save_file(content, Path.join(consolidated_output_dir(), "plural_rules.json"))
  end

  defp save_number_systems do
    Path.join(download_data_dir(), ["cldr-core", "/supplemental", "/numberingSystems.json"])
    |> File.read!
    |> Poison.decode!
    |> get_in(["supplemental", "numberingSystems"])
    |> remove_leading_underscores
    |> save_file(Path.join(consolidated_output_dir(), "number_systems.json"))
  end

  defp remove_leading_underscores(%{} = systems) do
    Enum.map(systems, fn {k, v} ->
      {String.replace_prefix(k, "_", ""), remove_leading_underscores(v)} end)
    |> Enum.into(%{})
  end

  defp remove_leading_underscores(v), do: v

  defp save_file(content, path) do
    File.write!(path, Poison.encode!(content))
  end
end