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

  @doc false
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

  @alt_keys ["default", "menu", "short", "long", "variant", "standard"]
  @lenient_parse_keys ["date", "general", "number"]
  @language_keys ["language", "language_variants"]

  @remaining_modules Cldr.Config.required_modules() --
    [
       "locale_display_names", "languages", "lenient_parse", "dates"
    ]

  @doc false
  def do_get_locale(locale, path, false) do
    path
    |> read_locale_file!
    |> Config.json_library().decode!
    |> assert_valid_keys!(locale)
    |> Cldr.Map.integerize_keys(filter: "list_formats")
    |> Cldr.Map.integerize_keys(filter: "number_formats")
    |> Cldr.Map.atomize_values(filter: "number_systems")
    |> Cldr.Map.atomize_keys(filter: "locale_display_names", skip: @language_keys)
    |> Cldr.Map.atomize_keys(filter: "locale_display_names", only: @alt_keys)
    |> Cldr.Map.atomize_keys(filter: "languages", only: @alt_keys)
    |> Cldr.Map.atomize_keys(filter: "lenient_parse", only: @lenient_parse_keys)
    |> Cldr.Map.atomize_keys(filter: @remaining_modules)
    |> structure_date_formats()
    |> Cldr.Map.atomize_keys(level: 1..1)
    |> Map.put(:name, locale)
  end

  @doc false
  def do_get_locale(locale, path, true) do
    Cldr.Locale.Cache.get_locale(locale, path)
  end

  # Read the file.
  defp read_locale_file!(path) do
    Cldr.maybe_log("Cldr.Config reading locale file #{inspect(path)}")
    {:ok, contents} = File.open(path, [:read, :binary, :utf8], &IO.read(&1, :all))
    contents
  end

  @date_atoms [
    "exemplar_city", "long", "standard", "generic",
    "short", "daylight", "formal",
    "daylight_savings", "generic"
  ]

  defp structure_date_formats(content) do
    dates =
      content
      |> Map.get("dates")
      |> Cldr.Map.integerize_keys(only: Cldr.Config.keys_to_integerize())
      |> Cldr.Map.deep_map(fn
        {:number_system, value} ->
          {:number_system,
            Cldr.Map.atomize_values(value) |> Cldr.Map.stringify_keys(except: :all)}
        other ->
          other
      end)
      |> Cldr.Map.atomize_keys(only: @date_atoms)
      |> Cldr.Map.atomize_keys(filter: "calendars")
      |> Cldr.Map.atomize_keys(filter: "time_zone_names", level: 1..2)
      |> Cldr.Map.atomize_keys(level: 1..1)

    Map.put(content, :dates, dates)
  end

  @doc false
  def underscore(string) when is_binary(string) do
    string
    |> Cldr.String.to_underscore()
  end

  def underscore(other), do: other

  # Simple check that the locale content contains what we expect
  # by checking it has the keys we used when the locale was consolidated.

  # Set the environment variable DEV to bypass this check. That is
  # only required if adding new content modules to a locale - which is
  # an uncommon activity.

  defp assert_valid_keys!(content, locale) do
    for module <- Config.required_modules() do
      if !Map.has_key?(content, module) and !Elixir.System.get_env("DEV") do
        raise RuntimeError,
          message:
            "Locale file #{inspect(locale)} is invalid - map key #{inspect(module)} was not found."
      end
    end

    content
  end
end