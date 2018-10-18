defmodule Cldr.Consolidate do
  @moduledoc false

  alias Cldr.Normalize
  alias Cldr.LanguageTag

  defdelegate download_data_dir(), to: Cldr.Config
  defdelegate consolidated_output_dir(), to: Cldr.Config, as: :source_data_dir

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
  @max_concurrency System.schedulers_online() * 2
  @spec consolidate_locales :: :ok
  def consolidate_locales do
    ensure_output_dir_exists!(consolidated_output_dir())
    ensure_output_dir_exists!(consolidated_locales_dir())

    save_cldr_version()
    save_plurals()
    save_number_systems()
    save_currencies()
    save_week_data()
    save_calendar_data()
    save_day_periods()
    save_aliases()
    save_likely_subtags()
    save_locales()
    save_territory_containment()

    all_locales()
    |> Task.async_stream(__MODULE__, :consolidate_locale, [], max_concurrency: @max_concurrency)
    |> Enum.to_list()

    :ok
  end

  @doc """
  Consolidates known locales as defined by `Cldr.known_locale_names/0`.
  """
  @spec consolidate_known_locales :: :ok
  def consolidate_known_locales do
    Cldr.known_locale_names()
    |> Task.async_stream(__MODULE__, :consolidate_locale, [], max_concurrency: @max_concurrency)
    |> Enum.to_list()

    :ok
  end

  @doc """
  Consolidates one locale.

  * `locale` is any locale defined by `Cldr.all_locale_names/0`

  """
  def consolidate_locale(locale) do
    IO.puts("Consolidating locale #{locale}")

    cldr_locale_specific_dirs()
    |> consolidate_locale_content(locale)
    |> level_up_locale(locale)
    |> Cldr.Map.underscore_keys()
    |> normalize_content(locale)
    |> Map.take(Cldr.Config.required_modules())
    |> Cldr.Map.atomize_keys()
    |> save_locale(locale)
  end

  def consolidate_locale_content(locale_dirs, locale) do
    locale_dirs
    |> Enum.map(&locale_specific_content(locale, &1))
    |> merge_maps
  end

  defp normalize_content(content, locale) do
    content
    |> Normalize.Number.normalize(locale)
    |> Normalize.Currency.normalize(locale)
    |> Normalize.List.normalize(locale)
    |> Normalize.NumberSystem.normalize(locale)
    |> Normalize.Rbnf.normalize(locale)
    |> Normalize.Units.normalize(locale)
    |> Normalize.DateFields.normalize(locale)
    |> Normalize.DateTime.normalize(locale)
    |> Normalize.TerritoryNames.normalize(locale)
    |> Normalize.LanguageNames.normalize(locale)
  end

  # Remove the top two levels of the map since they add nothing
  # but more levels :-)
  defp level_up_locale(content, locale) do
    get_in(content, ["main", locale])
  end

  defp save_locale(content, locale) do
    output_path = Path.join(consolidated_locales_dir(), "#{locale}.json")
    File.write!(output_path, Cldr.Config.json_library().encode!(content))
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

    with {:ok, files} <- File.ls(dir) do
      Enum.map(files, &Path.join(dir, &1))
      |> Enum.map(&File.read!(&1))
      |> Enum.map(&Poison.decode!(&1))
      |> merge_maps
    else
      {:error, _} -> %{}
    end
  end

  def cldr_locale_specific_dirs do
    cldr_directories()
    |> Enum.filter(&locale_specific_dir?/1)
  end

  defp locale_specific_dir?(filename) do
    String.ends_with?(filename, "-full")
  end

  def cldr_directories do
    download_data_dir()
    |> File.ls!()
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
        raise RuntimeError, message: "Couldn't create #{dir}: #{inspect(code)}"
    end
  end

  # As of CLDR 32 there is an available locale "yue" that has no content and
  # therefore should not be included
  @invalid_locales ["yue"]

  def all_locales() do
    download_data_dir()
    |> Path.join(["cldr-core", "/availableLocales.json"])
    |> File.read!()
    |> Poison.decode!()
    |> get_in(["availableLocales", "full"])
    |> Kernel.--(@invalid_locales)
  end

  defp cldr_version() do
    download_data_dir()
    |> Path.join(["cldr-core", "/package.json"])
    |> File.read!()
    |> Poison.decode!()
    |> get_in(["version"])
  end

  @doc false
  def save_cldr_version do
    path = Path.join(consolidated_output_dir(), "version.json")
    save_file(cldr_version(), path)

    assert_package_file_configured!(path)
  end

  @doc false
  def save_locales do
    path = Path.join(consolidated_output_dir(), "available_locales.json")
    save_file(all_locales(), path)

    assert_package_file_configured!(path)
  end

  @doc false
  def save_plurals do
    cardinal =
      download_data_dir()
      |> Path.join(["cldr-core", "/supplemental", "/plurals.json"])
      |> File.read!()
      |> Poison.decode!()
      |> get_in(["supplemental", "plurals-type-cardinal"])

    ordinal =
      download_data_dir()
      |> Path.join(["cldr-core", "/supplemental", "/ordinals.json"])
      |> File.read!()
      |> Poison.decode!()
      |> get_in(["supplemental", "plurals-type-ordinal"])

    content = %{cardinal: cardinal, ordinal: ordinal}
    path = Path.join(consolidated_output_dir(), "plural_rules.json")
    save_file(content, path)

    assert_package_file_configured!(path)
  end

  @doc false
  def save_number_systems do
    path = Path.join(consolidated_output_dir(), "number_systems.json")

    download_data_dir()
    |> Path.join(["cldr-core", "/supplemental", "/numberingSystems.json"])
    |> File.read!()
    |> Poison.decode!()
    |> get_in(["supplemental", "numberingSystems"])
    |> Cldr.Map.remove_leading_underscores()
    |> save_file(path)

    assert_package_file_configured!(path)
  end

  @doc false
  def save_currencies do
    path = Path.join(consolidated_output_dir(), "currencies.json")

    download_data_dir()
    |> Path.join(["cldr-numbers-full", "/main", "/en", "/currencies.json"])
    |> File.read!()
    |> Poison.decode!()
    |> get_in(["main", "en", "numbers", "currencies"])
    |> Map.keys()
    |> save_file(path)

    assert_package_file_configured!(path)
  end

  @doc false
  def save_territory_containment do
    path = Path.join(consolidated_output_dir(), "territory_containment.json")

    download_data_dir()
    |> Path.join(["cldr-core", "/supplemental", "/territoryContainment.json"])
    |> File.read!()
    |> Poison.decode!()
    |> get_in(["supplemental", "territoryContainment"])
    |> Normalize.TerritoryContainment.normalize()
    |> save_file(path)

    assert_package_file_configured!(path)
  end

  @doc false
  def save_territory_info do
    path = Path.join(consolidated_output_dir(), "territory_info.json")

    download_data_dir()
    |> Path.join(["cldr-core", "/supplemental", "/territoryInfo.json"])
    |> File.read!()
    |> Poison.decode!()
    |> get_in(["supplemental", "territoryInfo"])
    |> Normalize.TerritoryInfo.normalize()
    |> save_file(path)

    assert_package_file_configured!(path)
  end

  @doc false
  def save_week_data do
    path = Path.join(consolidated_output_dir(), "week_data.json")

    download_data_dir()
    |> Path.join(["cldr-core", "/supplemental", "/weekData.json"])
    |> File.read!()
    |> Poison.decode!()
    |> get_in(["supplemental", "weekData"])
    |> save_file(path)

    assert_package_file_configured!(path)
  end

  @doc false
  def save_calendar_data do
    path = Path.join(consolidated_output_dir(), "calendar_data.json")

    download_data_dir()
    |> Path.join(["cldr-core", "/supplemental", "/calendarData.json"])
    |> File.read!()
    |> Poison.decode!()
    |> get_in(["supplemental", "calendarData"])
    |> Map.delete("generic")
    |> Cldr.Map.remove_leading_underscores()
    |> Cldr.Map.underscore_keys()
    |> Cldr.Calendar.Conversion.convert_eras_to_iso_days()
    |> save_file(path)

    assert_package_file_configured!(path)
  end

  @doc false
  def save_day_periods do
    path = Path.join(consolidated_output_dir(), "day_periods.json")

    download_data_dir()
    |> Path.join(["cldr-core", "/supplemental", "/dayPeriods.json"])
    |> File.read!()
    |> Poison.decode!()
    |> get_in(["supplemental", "dayPeriodRuleSet"])
    |> Cldr.Map.remove_leading_underscores()
    |> Cldr.Calendar.Conversion.parse_time_periods()
    |> save_file(path)

    assert_package_file_configured!(path)
  end

  @doc false
  def save_aliases do
    path = Path.join(consolidated_output_dir(), "aliases.json")

    download_data_dir()
    |> Path.join(["cldr-core", "/supplemental", "/aliases.json"])
    |> File.read!()
    |> Poison.decode!()
    |> get_in(["supplemental", "metadata", "alias"])
    |> Cldr.Map.remove_leading_underscores()
    |> Cldr.Map.rename_key("variantAlias", "variant")
    |> Cldr.Map.rename_key("scriptAlias", "script")
    |> Cldr.Map.rename_key("zoneAlias", "zone")
    |> Cldr.Map.rename_key("territoryAlias", "region")
    |> Cldr.Map.rename_key("languageAlias", "language")
    |> Cldr.Map.deep_map(&split_alternates/1)
    |> Enum.map(&simplify_replacements/1)
    |> Enum.into(%{})
    |> parse_language_aliases
    |> save_file(path)

    assert_package_file_configured!(path)
  end

  @doc false
  def save_likely_subtags do
    path = Path.join(consolidated_output_dir(), "likely_subtags.json")

    download_data_dir()
    |> Path.join(["cldr-core", "/supplemental", "/likelySubtags.json"])
    |> File.read!()
    |> Poison.decode!()
    |> get_in(["supplemental", "likelySubtags"])
    |> Enum.map(fn {k, v} -> {k, LanguageTag.parse!(v)} end)
    |> Enum.into(%{})
    |> save_file(path)

    assert_package_file_configured!(path)
  end

  @doc false
  def assert_package_file_configured!(path) do
    [_, path] = String.split(path, "/priv/")
    path = "priv/" <> path

    if path in Mix.Project.config()[:package][:files] do
      :ok
    else
      raise "Path #{path} is not in the package definition"
    end
  end

  defp save_file(content, path) do
    File.write!(path, Cldr.Config.json_library().encode!(content))
  end

  defp parse_language_aliases(map) do
    language_aliases =
      Enum.map(Map.get(map, "language"), fn {k, v} ->
        [language | _rest] = String.split(v, " ")
        {k, LanguageTag.parse!(language)}
      end)
      |> Enum.into(%{})

    Map.put(map, "language", language_aliases)
  end

  defp split_alternates({k, v}) do
    if String.contains?(v, " ") do
      {k, String.split(v, " ")}
    else
      {k, v}
    end
  end

  @replacement "replacement"
  defp simplify_replacements({k, %{} = v}) do
    if Map.get(v, @replacement) do
      {k, Map.get(v, @replacement)}
    else
      replacements = Enum.map(v, &simplify_replacements/1) |> Enum.into(%{})
      {k, replacements}
    end
  end

  defp simplify_replacements({k, v}) do
    {k, Enum.map(v, &simplify_replacements/1)}
  end
end
