defmodule Cldr.Locale.Loader do
  @moduledoc """
  Provides a public interface to read the
  raw JSON locale files and return the
  CLDR data in a consistent format.

  The functions in this module are intended for the
  use of authors writing additional CLDR-based
  libraries.

  In addition, the functions in this module are
  intended for use at compile-time - not runtime -
  since reading, decoding and processing a
  locale file is an expensive operation.

  """

  alias Cldr.Config
  alias Cldr.Locale

  @max_concurrency System.schedulers_online() * 2
  @timeout 10_000

  @doc """
  Returns a list of all locales that are configured and available
  in the CLDR repository.

  ## Examples

      iex> Cldr.Locale.Loader.known_locale_names %Cldr.Config{locales: ["en", "de"]}
      [:de, :en, :und]

  """
  @spec known_locale_names(Config.t() | Cldr.backend()) :: [Locale.locale_name()]
  def known_locale_names(backend) when is_atom(backend) do
    backend.__cldr__(:config)
    |> known_locale_names
  end

  def known_locale_names(%Config{} = config) do
    Cldr.Config.configured_locale_names(config)
  end

  @doc """
  Returns a list of all locales that have RBNF data and that are
  configured and available in the CLDR repository.

  """

  @spec known_rbnf_locale_names(Config.t()) :: [Locale.locale_name()]
  def known_rbnf_locale_names(%Cldr.Config{locales: :all} = config) do
    config
    |> known_locale_names()
    |> Task.async_stream(fn locale_name ->
        rbnf =
          locale_name
          |> get_locale(config)
          |> Map.get(:rbnf)

        if Enum.empty?(rbnf), do: nil, else: locale_name
      end,
      max_concurrency: @max_concurrency,
      timeout: @timeout
      )
    |> Enum.reduce_while([], fn
      {:ok, nil}, acc -> {:cont, acc}
      {:ok, locale_name}, acc -> {:cont, [locale_name | acc]}
    end)
    |> Enum.sort()
  end

  def known_rbnf_locale_names(config) do
    known_locale_names(config)
    |> Enum.filter(fn locale -> Map.get(get_locale(locale, config), :rbnf) != %{} end)
  end

  @doc """
  Read the locale json, decode it and make any necessary transformations.

  This is the only place that we read the locale and we only
  read it once.  All other uses of locale data are references
  to this data.

  Additionally the intention is that this is read only at compile time
  and used to construct accessor functions in other modules so that
  during production run there is no file access or decoding.

  """
  @spec get_locale(Locale.locale_name(), config_or_backend :: Config.t() | Cldr.backend()) ::
          map() | no_return()

  def get_locale(locale, %{data_dir: _} = config) when is_atom(locale) do
    do_get_locale(locale, config)
  end

  def get_locale(locale, backend) when is_atom(locale) and is_atom(backend) do
    do_get_locale(locale, backend.__cldr__(:config))
  end

  @doc false
  def do_get_locale(locale, config) when is_atom(locale) do
    {:ok, path} =
      case Config.locale_path(locale, config) do
        {:ok, path} ->
          {:ok, path}

        {:error, :not_found} ->
          raise RuntimeError, message: "Locale definition was not found for #{inspect locale}"
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
    |> Cldr.Map.atomize_keys(filter: :language, only: @alt_keys)
    |> Cldr.Map.atomize_keys(filter: "languages", only: @alt_keys)
    |> Cldr.Map.atomize_keys(filter: "lenient_parse", only: @lenient_parse_keys)
    |> Cldr.Map.atomize_keys(filter: @remaining_modules)
    |> structure_date_formats()
    |> Cldr.Map.atomize_keys(level: 1..1)
    |> Map.put(:name, locale)
  end

  @doc false
  def do_get_locale(locale, path, true) when is_atom(locale) do
    Cldr.Locale.Cache.get_locale(locale, path)
  end

  # Read the file.
  # TODO remove when :all is deprecated in Elixir 1.17
  @read_flag if Version.compare(System.version(), "1.13.0-dev") == :lt, do: :all, else: :eof

  defp read_locale_file!(path) do
    Cldr.maybe_log("Cldr.Config reading locale file #{inspect(path)}")
    {:ok, contents} = File.open(path, [:read, :binary, :utf8], &IO.read(&1, @read_flag))
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
        {"number_system", value} ->
          {:number_system,
            Cldr.Map.atomize_values(value) |> Cldr.Map.stringify_keys(except: :all)}
        other ->
          other
      end)
      |> Cldr.Map.atomize_keys(only: @date_atoms)
      |> Cldr.Map.atomize_keys(filter: "calendars", skip: :number_system)
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