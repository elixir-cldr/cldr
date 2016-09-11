defmodule Cldr.Config do
  @moduledoc """
  Locales are configured for use in `Cldr` by either
  specifying them directly or by using a configured
  `Gettext` module.

  Locales are configured in `config.exs` (or any included config).
  For example the following will configure English and French as
  the available locales.  Note that only locales that are contained
  within the CLDR repository will be available for use.  There
  are currently 511 locales defined in CLDR.

      config :ex_cldr,
        locales: ["en", "fr"]

  ## Working with Gettext

  It's also possible to use the locales from a Gettext
  configuration:

      config :ex_cldr,
        locales: ["en", "fr"]
        gettext: App.Gettext

  In which case the combination of locales "en", "fr" and
  whatever is configured for App.Gettext will be generated.

  ## Locale wildcards

  Locales can also be configured by using a `regex` which is most
  useful when dealing with locales that have many regional variants
  like English (over 100!) and French.  For example:

      config :ex_cldr,
        locales: ["fr-*", "en-[A-Z]+"]

  will configure all French locales and all English locales that have
  alphabetic regional variants.  The expansion is made using
  `Regex.match?` so any valid regex can be used.

  ## Configuring all locales

  As a special case, all locales in CLDR can be configured
  by using the keyword `:all`.  For example:

      config :ex_cldr,
        locales: :all

  **Configuring all locales is not recommended*. Doing so
  imposes a significant compilation load as many functions
  are created at compmile time for each locale.**

  The `Cldr` test configuration does configure all locales in order
  to ensure good test coverage.  This is done at the expense
  of significant compile time.

  ## Storage location for the locale definiton files

  Locale files are downloaded and installed at compile time based upon the
  configuration.  These files are only used at compile time, they contain
  the `json` representation of the locale data.

  By default the locale files are stored in `./priv/cldr/locales`.

  The locale of the locales can be changed in the configuration with the
  `:data_dir` key.  For eaxmple:

      config :ex_cldr,
        locales: ["en", "fr"]
        data_dir: "/apps/data/cldr"

  The directory will be created if it does not exist and an
  exception will be raised if the directory cannot be created.
  """

  alias Cldr.Locale

  @type t :: binary

  @default_locale   "en"
  @default_data_dir "./priv/cldr"

  @doc """
  Return the root path of the cldr application
  """
  @app_home_dir Path.join(__DIR__, "/../..") |> Path.expand
  def app_home do
    @app_home_dir
  end

  @doc """
  Return the path name of the CLDR data directory.
  """
  @data_dir (Application.get_env(:cldr, :data_dir) || @default_data_dir)
  |> Path.expand

  def data_dir do
    @data_dir
  end

  @doc """
  Return the configured `Gettext` module name or `nil`.
  """
  @spec gettext :: atom
  def gettext do
    Application.get_env(:ex_cldr, :gettext)
  end

  @doc """
  Return the default locale.

  In order of priority return either:

  * The default locale specified in the `mix.exs` file
  * The `Gettext.get_locale/1` for the current configuratioh
  * "en"
  """
  @spec default_locale :: Locale.t
  def default_locale do
    app_default = Application.get_env(:ex_cldr, :default_locale)
    cond do
      app_default ->
        app_default
      gettext_configured?() ->
        Gettext
        |> apply(:get_locale, [gettext()])
        |> Enum.map(&String.replace(&1,"_","-"))
      true ->
        @default_locale
    end
  end

  @doc """
  Return a list of the lcoales defined in `Gettext`.

  Return a list of locales configured in `Gettext` or
  `[]` if `Gettext` is not configured.
  """
  @spec gettext_locales :: [Locale.t]
  def gettext_locales do
    if gettext_configured?() do
      Gettext
      |> apply(:known_locales, [gettext()])
      |> Enum.map(&String.replace(&1,"_","-"))
    else
      []
    end
  end

  @doc """
  Returns a list of all locales in the CLDR repository.

  Returns a list of the complete locales list in CLDR, irrespective
  of whether they are configured for use in the application.

  Any configured locales that are not present in this list will be
  ignored.
  """
  @locales_path Path.join(@data_dir, "available_locales.json")
  @all_locales @locales_path
  |> File.read!
  |> Poison.decode!
  |> Enum.sort

  @spec all_locales :: [Locale.t]
  def all_locales do
    @all_locales
  end

  @doc """
  Returns a list of all locales configured in the `config.exs`
  file.

  In order of priority return either:

  * The list of locales configured configured in mix.exs if any
  * The default locale

  If the configured locales is `:all` then all locales
  in CLDR are configured.

  This is not recommended since all 511 locales take
  quite some time (minutes) to compile. It is however
  helpful for testing Cldr.
  """
  @spec configured_locales :: [Locale.t]
  def configured_locales do
    case app_locales = Application.get_env(:ex_cldr, :locales) do
      :all  -> @all_locales
      nil   -> [default_locale()]
      _     -> expand_locales(app_locales)
    end |> Enum.sort
  end

  @doc """
  Returns a list of all locales that are configured and available
  in the CLDR repository.
  """
  @spec known_locales :: [Locale.t]
  def known_locales do
    requested_locales()
    |> MapSet.new()
    |> MapSet.intersection(MapSet.new(all_locales()))
    |> MapSet.to_list
    |> Enum.sort
  end

  @doc """
  Returns a list of all locales that are configured but not available
  in the CLDR repository.
  """
  @spec unknown_locales :: [Locale.t]
  def unknown_locales do
    requested_locales()
    |> MapSet.new()
    |> MapSet.difference(MapSet.new(all_locales()))
    |> MapSet.to_list
    |> Enum.sort
  end

  @doc """
  Returns a list of all configured locales.

  The list contains locales configured both in `Gettext` and
  specified in the mix.exs configuration file as well as the
  default locale.
  """
  @lint false
  @spec requested_locales :: [Locale.t]
  def requested_locales do
    (configured_locales() ++ gettext_locales() ++ [default_locale()])
    |> Enum.uniq
    |> Enum.sort
  end

  @doc """
  Returns true if a `Gettext` module is configured in Cldr and
  the `Gettext` module is available.

  ## Example

      iex> Cldr.Config.gettext_configured?
      false
  """
  @spec gettext_configured? :: boolean
  def gettext_configured? do
    gettext() && Code.ensure_loaded?(Gettext) && Code.ensure_loaded?(gettext())
  end

  @doc """
  Expands wildcards in locale names.

  Locales often have region variants (for example en-AU is one of 104
  variants in CLDR).  To make it easier to configure a language and all
  its variants, a locale can be specified as a regex which will
  then do a match against all CLDR locales.

  ## Examples

      iex> Cldr.Config.expand_locales(["en-A+"])
      ["en-AG", "en-AI", "en-AS", "en-AT", "en-AU"]

      iex(15)> Cldr.Config.expand_locales(["fr-*"])
      ["fr", "fr-BE", "fr-BF", "fr-BI", "fr-BJ", "fr-BL", "fr-CA", "fr-CD", "fr-CF",
       "fr-CG", "fr-CH", "fr-CI", "fr-CM", "fr-DJ", "fr-DZ", "fr-GA", "fr-GF",
       "fr-GN", "fr-GP", "fr-GQ", "fr-HT", "fr-KM", "fr-LU", "fr-MA", "fr-MC",
       "fr-MF", "fr-MG", "fr-ML", "fr-MQ", "fr-MR", "fr-MU", "fr-NC", "fr-NE",
       "fr-PF", "fr-PM", "fr-RE", "fr-RW", "fr-SC", "fr-SN", "fr-SY", "fr-TD",
       "fr-TG", "fr-TN", "fr-VU", "fr-WF", "fr-YT"]
  """
  @wildcard_matchers ["*", "+", ".", "["]
  @spec expand_locales([Locale.t]) :: [Locale.t]
  def expand_locales(locales) do
    locale_list = Enum.map(locales, fn locale ->
      if String.contains?(locale, @wildcard_matchers) do
        Enum.filter(@all_locales, &Regex.match?(Regex.compile!(locale), &1))
      else
        locale
      end
    end)
    locale_list |> List.flatten |> Enum.uniq
  end

  @doc """
  Returns the location of the json data for a locale.

  * `locale` is any locale returned from Cldr.known_locales()`
  """
  def locale_path(locale) do
    Path.join(data_dir(), ["locales/", "#{locale}.json"])
  end

  @doc """
  Read the locale json, decode it and make any necessary transformations.

  This is the only place that we read the locale and we only
  read it once.  All other uses of locale data are references
  to this data.

  Additionally the intention is that this is read only at compile time
  and used to construct accessor functions in other modules so that
  during production run there is no file access or decoding.

  If a locale file is not found then it is installed.
  """
  def get_locale(locale) do
    if !File.exists?(locale_path(locale)) do
      Cldr.Install.install_locale(locale)
    end
    locale_path(locale)
    |> File.read!
    |> Poison.decode!
    |> assert_valid_keys!
    |> Cldr.Map.atomize_keys
    |> atomize_number_systems
    |> structure_currencies
    |> structure_symbols
    |> structure_number_formats
  end

  # Simple check that the locale content contains what we expect
  # by checking it has the keys we used when the locale was consolidated.
  defp assert_valid_keys!(content) do
    for module <- Cldr.Consolidate.required_modules do
      if !Map.has_key?(content, module) do
        raise RuntimeError, message: "Locale file is invalid - #{inspect module} is not found."
      end
    end
    content
  end

  # Number systems are stored as atoms, no new
  # number systems are ever added at runtime so
  # risk to overflowing the atom table is very low.
  defp atomize_number_systems(content) do
    number_systems = content
    |> Map.get(:number_systems)
    |> Enum.map(fn {k, v} -> {k, atomize(v)} end)
    |> Enum.into(%{})

    Map.put(content, :number_systems, number_systems)
  end

  # Put the currency data into a %Currency{} struct
  defp structure_currencies(content) do
    alias Cldr.Currency

    currencies = content.currencies
    |> Enum.map(fn {code, currency} -> {code, struct(Currency, currency)} end)
    |> Enum.into(%{})

    Map.put(content, :currencies, currencies)
  end

  # Put the number_formats into a %Format{} struct
  defp structure_number_formats(content) do
    alias Cldr.Number.Format

    formats = content.number_formats
    |> Enum.map(fn {system, format} -> {system, struct(Format, format)} end)
    |> Enum.into(%{})

    Map.put(content, :number_formats, formats)
  end

  # Put the symbols into a %Symbol{} struct
  defp structure_symbols(content) do
    alias Cldr.Number.Symbol

    symbols = content.number_symbols
    |> Enum.map(fn
         {system, nil}    -> {system, nil}
         {system, symbol} -> {system, struct(Symbol, symbol)}
       end)
    |> Enum.into(%{})

    Map.put(content, :number_symbols, symbols)
  end

  # Convert to an atom but only if
  # its a binary.
  defp atomize(nil) do
    nil
  end

  defp atomize(v) when is_binary(v) do
    String.to_atom(v)
  end

  defp atomize(v) do
    v
  end
end
