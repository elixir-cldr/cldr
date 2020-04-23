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
  @timeout 10_000

  @spec consolidate_locales :: :ok
  def consolidate_locales do
    ensure_output_dir_exists!(consolidated_output_dir())
    ensure_output_dir_exists!(consolidated_locales_dir())

    save_cldr_version()
    save_plurals()
    save_number_systems()
    save_currencies()
    save_territory_currencies()
    save_territories()
    save_territory_containers()
    save_territory_containment()
    save_territory_subdivisions()
    save_territory_subdivision_containment()
    save_weeks()
    save_calendars()
    save_calendar_preferences()
    save_day_periods()
    save_aliases()
    save_likely_subtags()
    save_locales()
    save_plural_ranges()
    save_timezones()
    save_units()
    save_measurement_systems()

    all_locales()
    |> Task.async_stream(__MODULE__, :consolidate_locale, [],
      max_concurrency: @max_concurrency,
      timeout: @timeout
    )
    |> Enum.to_list()

    :ok
  end

  @doc """
  Consolidates known locales as defined by `Cldr.known_locale_names/0`.
  """
  @spec consolidate_known_locales(Cldr.backend()) :: :ok
  def consolidate_known_locales(backend) do
    Cldr.known_locale_names(backend)
    |> Task.async_stream(__MODULE__, :consolidate_locale, [], max_concurrency: @max_concurrency)
    |> Enum.to_list()

    :ok
  end

  @doc """
  Consolidates one locale.

  * `locale` is any locale defined by `Cldr.all_locale_names/0`

  """
  def consolidate_locale(locale) do
    IO.puts("Consolidating locale #{inspect(locale)}")

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
    |> Normalize.Calendar.normalize(locale)
    |> Normalize.Delimiter.normalize(locale)
    |> Normalize.Ellipsis.normalize(locale)
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
      |> Enum.map(&Jason.decode!(&1))
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

  # As of CLDR 37 there are available locales that have no content and
  # therefore should not be included
  @invalid_locales [
      "ff-Adlm",
      "ff-Adlm-BF",
      "ff-Adlm-CM",
      "ff-Adlm-GH",
      "ff-Adlm-GM",
      "ff-Adlm-GW",
      "ff-Adlm-LR",
      "ff-Adlm-MR",
      "ff-Adlm-NE",
      "ff-Adlm-NG",
      "ff-Adlm-SL",
      "ff-Adlm-SN",
      "ks-Arab",
      "mai",
      "ms-ID",
      "mni-Beng",
      "mni",
      "pcm",
      "sat",
      "sd-Arab",
      "sat-Olck",
      "sd-Deva",
      "su",
      "su-Latn",
      "yue"
  ]

  def all_locales() do
    download_data_dir()
    |> Path.join(["cldr-core", "/availableLocales.json"])
    |> File.read!()
    |> Jason.decode!()
    |> get_in(["availableLocales", "full"])
    |> Kernel.--(@invalid_locales)
  end

  defp cldr_version() do
    download_data_dir()
    |> Path.join(["cldr-core", "/package.json"])
    |> File.read!()
    |> Jason.decode!()
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
      |> Jason.decode!()
      |> get_in(["supplemental", "plurals-type-cardinal"])

    ordinal =
      download_data_dir()
      |> Path.join(["cldr-core", "/supplemental", "/ordinals.json"])
      |> File.read!()
      |> Jason.decode!()
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
    |> Jason.decode!()
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
    |> Jason.decode!()
    |> get_in(["main", "en", "numbers", "currencies"])
    |> Map.keys()
    |> save_file(path)

    assert_package_file_configured!(path)
  end

  @doc false
  def save_territory_currencies do
    path = Path.join(consolidated_output_dir(), "territory_currencies.json")

    download_data_dir()
    |> Path.join(["cldr-core", "/supplemental", "/currencyData.json"])
    |> File.read!()
    |> Jason.decode!()
    |> get_in(["supplemental", "currencyData", "region"])
    |> Cldr.Map.rename_keys("_from", "from")
    |> Cldr.Map.rename_keys("_to", "to")
    |> Cldr.Map.rename_keys("_tender", "tender")
    |> save_file(path)

    assert_package_file_configured!(path)
  end

  @doc false
  @territory_containers_file "territory_containers.json"
  def save_territory_containers do
    path = Path.join(consolidated_output_dir(), @territory_containers_file)

    download_data_dir()
    |> Path.join(["cldr-core", "/supplemental", "/territoryContainment.json"])
    |> File.read!()
    |> Jason.decode!()
    |> get_in(["supplemental", "territoryContainment"])
    |> Normalize.TerritoryContainers.normalize()
    |> save_file(path)

    assert_package_file_configured!(path)
  end

  def save_territory_containment do
    path = Path.join(consolidated_output_dir(), "territory_containment.json")

    territory_parents =
      consolidated_output_dir()
      |> Path.join(@territory_containers_file)
      |> File.read!()
      |> Jason.decode!
      |> Enum.flat_map(fn {k, v} ->
        Enum.map(v, fn t -> {t, k} end)
      end)

    territory_parents
    |> Enum.map(fn {k, v} -> {k, parents(territory_parents, v)} end)
    |> Enum.group_by(fn {k, _v} -> k end, fn {_k, v} -> v end)
    |> Enum.map(fn {k, v} -> {k, Enum.sort(v, fn x, y -> length(x) > length(y) end)} end)
    |> Map.new
    |> save_file(path)

    assert_package_file_configured!(path)
  end
  @doc false
  def save_territories do
    path = Path.join(consolidated_output_dir(), "territories.json")

    download_data_dir()
    |> Path.join(["cldr-core", "/supplemental", "/territoryInfo.json"])
    |> File.read!()
    |> Jason.decode!()
    |> get_in(["supplemental", "territoryInfo"])
    |> Normalize.Territories.normalize()
    |> save_file(path)

    assert_package_file_configured!(path)
  end

  @doc false
  def save_territory_subdivisions do
    import SweetXml

    path = Path.join(consolidated_output_dir(), "territory_subdivisions.json")

    download_data_dir()
    |> Path.join(["/subdivisions.xml"])
    |> File.read!()
    |> String.replace(~r/<!DOCTYPE.*>\n/, "")
    |> xpath(~x"//subgroup"l,
      type: ~x"./@type"s,
      contains: ~x"./@contains"s
      )
    |> Enum.map(fn map -> {map.type, String.split(map.contains)} end)
    |> Map.new
    |> save_file(path)

    assert_package_file_configured!(path)
  end

  def save_territory_subdivision_containment do
    path = Path.join(consolidated_output_dir(), "territory_subdivision_containment.json")

    territory_parents =
      consolidated_output_dir()
      |> Path.join("territory_subdivisions.json")
      |> File.read!()
      |> Jason.decode!
      |> Enum.flat_map(fn {k, v} ->
        Enum.map(v, fn t -> {t, k} end)
      end)

    territory_parents
    |> Enum.map(fn {k, v} -> {k, parents(territory_parents, v)} end)
    |> Map.new
    |> save_file(path)

    assert_package_file_configured!(path)
  end

  defp parents(_territory_parents, nil) do
    []
  end

  defp parents(territory_parents, territory) when is_atom(territory) do
    [territory | parents(territory_parents, Keyword.get(territory_parents, territory))]
  end

  defp parents(territory_parents, territory) when is_binary(territory) do
    [territory | parents(territory_parents, :proplists.get_value(territory, territory_parents, nil))]
  end

  @doc false
  def save_weeks do
    path = Path.join(consolidated_output_dir(), "weeks.json")

    download_data_dir()
    |> Path.join(["cldr-core", "/supplemental", "/weekData.json"])
    |> File.read!()
    |> Jason.decode!()
    |> get_in(["supplemental", "weekData"])
    |> adjust_day_names
    |> Cldr.Map.integerize_values
    |> Cldr.Map.underscore_keys(only: ["weekendStart", "weekendEnd", "minDays", "firstDay"])
    |> save_file(path)

    assert_package_file_configured!(path)
  end

  defp adjust_day_names(content) do
    content
    |> Cldr.Map.deep_map(fn
      {key, "sun"} -> {key, 7}
      {key, "mon"} -> {key, 1}
      {key, "tue"} -> {key, 2}
      {key, "wed"} -> {key, 3}
      {key, "thu"} -> {key, 4}
      {key, "fri"} -> {key, 5}
      {key, "sat"} -> {key, 6}
      other -> other
    end)
  end

  @doc false
  def save_calendars do
    path = Path.join(consolidated_output_dir(), "calendars.json")

    download_data_dir()
    |> Path.join(["cldr-core", "/supplemental", "/calendarData.json"])
    |> File.read!()
    |> Jason.decode!()
    |> get_in(["supplemental", "calendarData"])
    |> Map.delete("generic")
    |> Cldr.Map.remove_leading_underscores()
    |> Cldr.Map.underscore_keys()
    |> Cldr.Calendar.Conversion.convert_eras_to_iso_days()
    |> save_file(path)

    assert_package_file_configured!(path)
  end

  @doc false
  def save_calendar_preferences do
    path = Path.join(consolidated_output_dir(), "calendar_preferences.json")

    download_data_dir()
    |> Path.join(["cldr-core", "/supplemental", "/calendarPreferenceData.json"])
    |> File.read!()
    |> Jason.decode!()
    |> get_in(["supplemental", "calendarPreferenceData"])
    |> Cldr.Map.remove_leading_underscores()
    |> Enum.map(fn {k, v} -> {k, Cldr.String.to_underscore(v) |> String.split(" ")} end)
    |> Map.new
    |> save_file(path)

    assert_package_file_configured!(path)
  end

  @doc false
  def save_day_periods do
    path = Path.join(consolidated_output_dir(), "day_periods.json")

    download_data_dir()
    |> Path.join(["cldr-core", "/supplemental", "/dayPeriods.json"])
    |> File.read!()
    |> Jason.decode!()
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
    |> Jason.decode!()
    |> get_in(["supplemental", "metadata", "alias"])
    |> Cldr.Map.remove_leading_underscores()
    |> Cldr.Map.rename_keys("variantAlias", "variant")
    |> Cldr.Map.rename_keys("scriptAlias", "script")
    |> Cldr.Map.rename_keys("zoneAlias", "zone")
    |> Cldr.Map.rename_keys("territoryAlias", "region")
    |> Cldr.Map.rename_keys("languageAlias", "language")
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
    |> Jason.decode!()
    |> get_in(["supplemental", "likelySubtags"])
    |> Enum.map(fn {k, v} -> {k, LanguageTag.parse!(v)} end)
    |> Enum.into(%{})
    |> save_file(path)

    assert_package_file_configured!(path)
  end

  def save_plural_ranges do
    import SweetXml
    path = Path.join(consolidated_output_dir(), "plural_ranges.json")

    download_data_dir()
    |> Path.join(["plural_ranges.xml"])
    |> File.read!()
    |> String.replace(~r/<!DOCTYPE.*>\n/, "")
    |> xpath(~x"//pluralRanges"l,
      locales: ~x"./@locales"s,
      ranges: [~x"./pluralRange"l, start: ~x"./@start"s, end: ~x"./@end"s, result: ~x"./@result"s]
    )
    |> Enum.map(fn %{locales: locales} = map ->
      Map.put(map, :locales, String.split(locales, " "))
    end)
    |> save_file(path)

    assert_package_file_configured!(path)
  end

  def save_timezones do
    import SweetXml
    path = Path.join(consolidated_output_dir(), "timezones.json")

    [%{timezones: timezones}] =
      download_data_dir()
      |> Path.join(["timezones.xml"])
      |> File.read!()
      |> String.replace(~r/<!DOCTYPE.*>\n/, "")
      |> xpath(~x"//key"l,
        timezones: [~x"./type"l, name: ~x"./@name"s, alias: ~x"./@alias"s]
      )

    Enum.map(timezones, fn %{alias: aliases, name: name} ->
      {name, String.split(aliases, " ")}
    end)
    |> Map.new()
    |> save_file(path)

    assert_package_file_configured!(path)
  end

  def save_measurement_systems do
    import SweetXml

    path = Path.join(consolidated_output_dir(), "measurement_systems.json")

    download_data_dir()
    |> Path.join(["measurement_systems.xml"])
    |> File.read!()
    |> String.replace(~r/<!DOCTYPE.*>\n/, "")
    |> xpath(
      ~x"//type"l,
      name: ~x"./@name"s,
      description: ~x"./@description"s,
      alias: ~x"./@alias"s
    )
    |> Enum.group_by(& &1.name, &%{alias: &1.alias, description: &1.description})
    |> Enum.map(fn {k, v} -> {k, hd(v)} end)
    |> Map.new()
    |> save_file(path)

    assert_package_file_configured!(path)
  end

  def save_units do
    import SweetXml
    import Cldr.Config, only: [underscore: 1]
    alias Cldr.Unit.{Parser, Expression}

    path = Path.join(consolidated_output_dir(), "units.json")

    units =
      download_data_dir()
      |> Path.join(["units.xml"])
      |> File.read!()
      |> String.replace(~r/<!DOCTYPE.*>\n/, "")

    constants =
      units
      |> xpath(
        ~x"//unitConstant"l,
        constant: ~x"./@constant"s,
        value: ~x"./@value"s
      )
      |> Enum.map(fn %{constant: constant, value: value} ->
        {constant, Parser.parse(value)}
      end)
      |> Map.new()

    constants =
      Enum.map(constants, fn {constant, expression} ->
        {constant, Expression.run(expression, constants)}
      end)
      |> Map.new()

    base_units =
      units
      |> xpath(
        ~x"//unitQuantity"l,
        quantity: ~x"./@quantity"s,
        base_unit: ~x"./@baseUnit"s
      )
      |> Enum.map(fn %{quantity: quantity, base_unit: base_unit} ->
        [underscore(quantity), underscore(base_unit)]
      end)

    conversions =
      units
      |> xpath(
        ~x"//convertUnit"l,
        source: ~x"./@source"s,
        base_unit: ~x"./@baseUnit"s,
        factor: ~x"./@factor"s,
        offset: ~x"./@offset"s,
        systems: ~x"./@systems"s
      )
      |> Enum.map(fn %{
                       source: source,
                       base_unit: target,
                       offset: offset,
                       factor: factor,
                       systems: systems
                     } ->
        {underscore(source),
         %{
           base_unit: underscore(target),
           factor: Parser.parse(factor, 1) |> Expression.run(constants),
           offset: Parser.parse(offset, 0) |> Expression.run(constants),
           systems: Parser.systems(systems)
         }}
      end)
      |> Map.new()


    preferences =
      units
      |> xpath(
        ~x"//unitPreferences"l,
        category: ~x"./@category"s,
        usage: ~x"./@usage"s,
        preferences: [
          ~x"//unitPreference"l,
          regions: ~x"//unitPreference/@regions"s,
          geq: ~x"//unitPreference/@geq"of,
          units: ~x"//unitPreference/text()"s,
          skeleton: ~x"//unitPreference/@skeleton"os
        ]
      )
      |> Enum.map(fn item ->
        preferences =
          Enum.map(item.preferences, fn pref ->
            pref
            |> Map.update!(:regions, &String.split/1)
            |> Map.update!(:units, fn units -> underscore(units) |> String.split("_and_") end)
            |> Map.update!(:skeleton, &(Cldr.String.to_underscore(&1) |> String.split("/")))
          end)

        Map.put(item, :preferences, preferences)
        |> Map.update!(:category, &underscore/1)
        |> Map.update!(:usage, &underscore/1)
      end)
      |> Enum.group_by(&(&1.category), &(%{&1.usage => &1.preferences}))
      |> Enum.map(fn {k, v} -> {k, Cldr.Map.merge_map_list(v)} end)
      |> Map.new

    aliases =
      units
      |> xpath(
        ~x"//unitAlias"l,
        unit: ~x"./@type"s,
        replacement: ~x"./@replacement"s
      )
      |> Enum.map(fn %{unit: unit, replacement: replacement} ->
        {underscore(unit), underscore(replacement)}
      end)
      |> Map.new()

    %{base_units: base_units, conversions: conversions, aliases: aliases, preferences: preferences}
    |> save_file(path)

    assert_package_file_configured!(path)
  end

  # BCP47 uses ussystem, uksystem and netric
  # so we use these as canonical forms
  @doc false
  def canonicalize_measurement_system(data) when is_map(data) do
    Enum.map(data, fn
      {k, "US"} -> {k, "ussystem"}
      {k, "UK"} -> {k, "uksystem"}
      {k, "A4"} -> {k, "a4"}
      {k, "US-Letter"} -> {k, "us_letter"}
      other -> other
    end)
    |> Map.new()
  end

  def canonicalize_measurement_system(data) when is_binary(data) do
    case data do
      "US" -> "ussystem"
      "UK" -> "uksystem"
      "A4" -> "a4"
      "US-Letter" -> "us_letter"
      other -> other
    end
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

  defp split_alternates({k, v}) when is_binary(v) do
    if String.contains?(v, " ") do
      {k, String.split(v, " ")}
    else
      {k, v}
    end
  end

  defp split_alternates(other) do
    other
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
