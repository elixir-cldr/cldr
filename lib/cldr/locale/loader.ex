defmodule Cldr.Locale.Loader do
  @moduledoc false

  # Encapsulate only the code that loads a
  # locale from a .json file

  # The intent is to isolate all the code that
  # loads a locale so that eventually this can be
  # shifted from here to the data consolidation phase
  # if/when we choose to store locales in erlang
  # term format rather than json.

  # One intermediate step will be to shift the data
  # structure manipulation into the consolidation phase
  # leaving only the requirement to form atom and integer
  # keys in the appropriate place.

  alias Cldr.Config

  @doc """
  Read the locale json, decode it and make any necessary transformations.

  This is the only place that we read the locale and we only
  read it once.  All other uses of locale data are references
  to this data.

  Additionally the intention is that this is read only at compile time
  and used to construct accessor functions in other modules so that
  during production run there is no file access or decoding.

  """
  @spec get_locale(Cldr.Locale.locale_name(), config_or_backend :: Config.t() | Cldr.backend()) ::
          map() | no_return()

  def get_locale(locale, %{data_dir: _} = config) do
    do_get_locale(locale, config)
  end

  def get_locale(locale, backend) when is_atom(backend) do
    do_get_locale(locale, backend.__cldr__(:config))
  end

  def do_get_locale(locale, config) do
    {:ok, path} =
      case Config.locale_path(locale, config) do
        {:ok, path} ->
          {:ok, path}

        {:error, :not_found} ->
          raise RuntimeError, message: "Locale definition was not found for #{locale}"
      end

    do_get_locale(locale, path, Cldr.Locale.Cache.compiling?())
  end

  @dont_atomize_keys ["languages", "lenient_parse", "locale_display_names", "subdivisions"]
  @skip_keys ["zone"]

  def do_get_locale(locale, path, false) do
    path
    |> read_locale_file
    |> Config.json_library().decode!
    |> assert_valid_keys!(locale)
    |> structure_number_formats()
    |> structure_units()
    |> atomize_keys(Config.required_modules() -- @dont_atomize_keys,
        skip: @skip_keys, except: Cldr.Config.keys_to_integerize())
    |> structure_rbnf()
    |> atomize_number_systems()
    |> atomize_languages()
    |> structure_date_formats()
    |> structure_list_formats()
    |> structure_locale_display_names()
    |> Map.put(:name, locale)
  end

  @doc false
  def do_get_locale(locale, path, true) do
    Cldr.Locale.Cache.get_locale(locale, path)
  end

  # Read the file.
  defp read_locale_file(path) do
    Cldr.maybe_log("Cldr.Config reading locale file #{inspect(path)}")
    {:ok, file} = File.open(path, [:read, :binary, :utf8])
    contents = IO.read(file, :all)
    File.close(file)
    contents
  end

  @date_atoms ["exemplar_city", "long", "standard", "generic", "daylight", "formal"]
  defp structure_date_formats(content) do
    dates =
      content.dates
      |> Cldr.Map.integerize_keys(only: Cldr.Config.keys_to_integerize())
      |> Cldr.Map.deep_map(fn
        {:number_system, value} ->
          {:number_system, Cldr.Map.atomize_values(value) |> Cldr.Map.stringify_keys(except: :all)}
        other ->
          other
      end)

    zones =
      get_in(dates, [:time_zone_names, :zone])
      |> Cldr.Map.rename_keys("exemplar_city_alt_formal", "formal")
      |> Cldr.Map.atomize_keys(only: @date_atoms)

    dates =
      put_in(dates, [:time_zone_names, :zone], zones)

    Map.put(content, :dates, dates)
  end

  defp structure_list_formats(content) do
    dates =
      content.list_formats
      |> Cldr.Map.atomize_keys()

    Map.put(content, :list_formats, dates)
  end

  @alt_keys ["default", "menu", "short", "long", "variant"]

  defp structure_locale_display_names(content) do
    locale_display_names =
      content
      |> Map.get(:locale_display_names)
      |> Cldr.Map.rename_keys("variants", "language_variants")
      |> Cldr.Map.atomize_keys(skip: ["language", "language_variants"])
      |> Cldr.Map.atomize_keys(only: @alt_keys)

    Map.put(content, :locale_display_names, locale_display_names)
  end

  # Put the rbnf rules into a %Rule{} struct
  defp structure_rbnf(content) do
    rbnf =
      content[:rbnf]
      |> Enum.map(fn {group, sets} ->
        {group, structure_sets(sets)}
      end)
      |> Enum.into(%{})

    Map.put(content, :rbnf, rbnf)
  end

  defp structure_number_formats(content) do
    number_formats =
      content["number_formats"]
      |> Cldr.Map.integerize_keys()

    Map.put(content, "number_formats", number_formats)
  end

  defp structure_units(content) do
    units =
      content["units"]
      |> Enum.map(fn {style, units} -> {style, group_units(units)} end)
      |> Map.new()
      |> Cldr.Map.atomize_keys()

    Map.put(content, "units", units)
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

  defp structure_sets(sets) do
    Enum.map(sets, fn {name, set} ->
      name = underscore(name)
      {underscore(name), Map.put(set, :rules, set[:rules])}
    end)
    |> Enum.into(%{})
  end

  # Number systems are stored as atoms, no new
  # number systems are ever added at runtime so
  # risk to overflowing the atom table is very low.
  defp atomize_number_systems(content) do
    number_systems =
      content
      |> Map.get(:number_systems)
      |> Enum.map(fn {k, v} -> {k, atomize(v)} end)
      |> Enum.into(%{})

    Map.put(content, :number_systems, number_systems)
  end

  @doc false
  def underscore(string) when is_binary(string) do
    string
    |> Cldr.String.to_underscore()
  end

  def underscore(other), do: other


  # Convert to an atom but only if
  # its a binary.
  defp atomize(nil), do: nil
  defp atomize(v) when is_binary(v), do: String.to_atom(v)
  defp atomize(v), do: v

  defp atomize_languages(content) do
    languages =
      content
      |> Map.get(:languages)
      |> Enum.map(fn {k, v} -> {k, Cldr.Map.atomize_keys(v)} end)
      |> Map.new()

    Map.put(content, :languages, languages)
  end

  defp atomize_keys(content, modules, options) do
    Enum.map(content, fn {module, values} ->
      if module in modules && is_map(values) do
        {String.to_atom(module), Cldr.Map.atomize_keys(values, options)}
      else
        {String.to_atom(module), values}
      end
    end)
    |> Map.new()
  end

  # Simple check that the locale content contains what we expect
  # by checking it has the keys we used when the locale was consolidated.

  # Set the environment variable DEV to bypass this check. That is
  # only required if adding new content modules to a locale - which is
  # an uncommon activity.

  defp assert_valid_keys!(content, locale) do
    for module <- Config.required_modules() do
      if !Map.has_key?(content, module) and !:"Elixir.System".get_env("DEV") do
        raise RuntimeError,
          message:
            "Locale file #{inspect(locale)} is invalid - map key #{inspect(module)} was not found."
      end
    end

    content
  end
end