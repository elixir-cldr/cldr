defmodule Cldr.Config do
  @moduledoc """
  Provides the functions to manage the `Cldr` configuration.

  Locales are configured for use in `Cldr` by either
  specifying them directly or by using a configured
  `Gettext` module.

  Locales are configured in `config.exs` (or any included config).
  For example the following will configure English and French as
  the available locales.  Note that only locales that are contained
  within the CLDR repository will be available for use.  There
  are currently 516 locales defined in CLDR version 31.0.0.

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

  ## Precompiling configured number formats

  If your application heavily relies on one or more particular user-defined
  number formats then there is a performance benefit to having them precompiled
  when your app is compiled (up to double the performance).

  To define the formats to be precompiled specify them in your config file with
  the key `compile_number_formats`.

  For example:

      config :ex_cldr,
        compile_number_formats: ["¤¤#,##0.##"]

  ## Storage location for the locale definiton files

  Locale files are downloaded and installed at compile time based upon the
  configuration.  These files are only used at compile time, they contain
  the `json` representation of the locale data.

  By default the locale files are stored in `./priv/cldr/locales`.

  The locale of the locales can be changed in the configuration with the
  `:data_dir` key.  For example:

      config :ex_cldr,
        locales: ["en", "fr"]
        data_dir: "/apps/data/cldr"

  The directory will be created if it does not exist and an
  exception will be raised if the directory cannot be created.
  """

  alias Cldr.Locale
  alias Cldr.LanguageTag

  @type t :: binary

  @default_locale "en-001"

  @cldr_modules [
    "number_formats", "list_formats", "currencies",
    "number_systems", "number_symbols", "minimum_grouping_digits",
    "rbnf", "units", "date_fields", "dates"
  ]

  @doc """
  Return the root path of the cldr application
  """
  @cldr_home_dir Path.join(__DIR__, "/../..") |> Path.expand
  def cldr_home do
    @cldr_home_dir
  end

  @doc """
  Return the directory where `Cldr` stores its source core data,  This
  directory should not be expected to be available other than when developing
  CLdr since it points to a source directory.
  """
  @cldr_relative_dir "/priv/cldr"
  @source_data_dir Path.join(@cldr_home_dir, @cldr_relative_dir)
  def source_data_dir do
    @source_data_dir
  end

  @doc """
  Returns the path of the CLDR data directory for the ex_cldr app
  """
  @cldr_data_dir [:code.priv_dir(:ex_cldr), "/cldr"] |> :erlang.iolist_to_binary
  def cldr_data_dir do
    @cldr_data_dir
  end

  @doc """
  Return the path name of the CLDR data directory for a client application.
  """
  @client_data_dir Application.get_env(:ex_cldr, :data_dir, @cldr_data_dir)
  |> Path.expand

  def client_data_dir do
    @client_data_dir
  end

  @doc """
  Returns the directory where the CLDR locales files are located.
  """
  @client_locales_dir @client_data_dir <> "/" <> "locales"
  def client_locales_dir do
    @client_locales_dir
  end

  @doc """
  Returns the version string of the CLDR data repository
  """
  @version  @client_data_dir
  |> Path.join("version.json")
  |> File.read!
  |> Poison.decode!

  def version do
    @version
  end

  @doc """
  Returns the filename that contains the json representation of a locale
  """
  def locale_filename(locale) do
    "#{locale}.json"
  end

  @doc """
  Returns the directory where the downloaded CLDR repository files
  are stored.
  """
  def download_data_dir do
    Path.join(Cldr.Config.cldr_home, "data")
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

  Any configured locales that are not present in this list will
  raise an exception at compile time.
  """
  @locales_path Path.join(@cldr_data_dir, "available_locales.json")
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

  The locale "root" is always added to the list of configured locales since it
  is required to support some RBNF functions.

  This is not recommended since all 516 locales take
  quite some time (minutes) to compile. It is however
  helpful for testing Cldr.
  """
  @spec configured_locales :: [Locale.t]
  def configured_locales do
    locales = case app_locales = Application.get_env(:ex_cldr, :locales) do
      :all  -> @all_locales
      nil   -> [default_locale()]
      _     -> expand_locales(app_locales)
    end

    ["root" | locales]
    |> Enum.uniq
    |> Enum.sort
  end

  @doc false
  # This is basically a duplication of `Cldr.Locale.canonical_language_tag` but
  # written to be available at compile time in `Cldr` which is definitely hacky,
  def canonical_language_tag!(locale_name) do
    language_tag = LanguageTag.Parser.parse!(locale_name)
    requested_locale_name = Locale.locale_name_from(language_tag)

    canonical_tag =
      language_tag
      |> Locale.substitute_aliases
      |> Locale.add_likely_subtags

    canonical_tag
      |> Map.put(:requested_locale_name, requested_locale_name)
      |> Map.put(:canonical_locale_name, Locale.locale_name_from(canonical_tag))
      |> set_cldr_locale_name
  end

  @doc false
  def set_cldr_locale_name(%LanguageTag{language: language, script: script, region: region} = language_tag) do
    cldr_locale_name =
      known_locale(Locale.locale_name_from(language, script, region)) ||
      known_locale(Locale.locale_name_from(language, nil, region)) ||
      known_locale(Locale.locale_name_from(language, script, nil)) ||
      known_locale(Locale.locale_name_from(language, nil, nil)) ||
      Locale.locale_name_from(LanguageTag.parse!(default_locale()))

    %{language_tag | cldr_locale_name: cldr_locale_name}
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

  def known_locale(locale_name) do
    if locale_name in known_locales() do
      locale_name
    else
      false
    end
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
  @spec requested_locales :: [Locale.t]
  def requested_locales do
    (configured_locales() ++ gettext_locales() ++ [default_locale()])
    |> Enum.uniq
    |> Enum.sort
  end

  @doc """
  Returns a list of strings representing the calendars known to `Cldr`.

  ## Example

      iex> Cldr.Config.known_calendars
      ["buddhist", "chinese", "coptic", "dangi", "ethiopic", "ethiopic_amete_alem",
       "gregorian", "hebrew", "indian", "islamic", "islamic_civil", "islamic_rgsa",
       "islamic_tbla", "islamic_umalqura", "japanese", "persian", "roc"]

  """
  def known_calendars do
    calendar_data() |> Map.keys |> Enum.map(&Atom.to_string/1) |> Enum.sort
  end

  @doc """
  Returns a list of strings representing the currencies known to `Cldr`.

  ## Example

      iex> Cldr.Config.known_currencies
      ["ADP", "AED", "AFA", "AFN", "ALK", "ALL", "AMD", "ANG", "AOA", "AOK", "AON",
       "AOR", "ARA", "ARL", "ARM", "ARP", "ARS", "ATS", "AUD", "AWG", "AZM", "AZN",
       "BAD", "BAM", "BAN", "BBD", "BDT", "BEC", "BEF", "BEL", "BGL", "BGM", "BGN",
       "BGO", "BHD", "BIF", "BMD", "BND", "BOB", "BOL", "BOP", "BOV", "BRB", "BRC",
       "BRE", "BRL", "BRN", "BRR", "BRZ", "BSD", "BTN", "BUK", "BWP", "BYB", "BYN",
       "BYR", "BZD", "CAD", "CDF", "CHE", "CHF", "CHW", "CLE", "CLF", "CLP", "CNX",
       "CNY", "COP", "COU", "CRC", "CSD", "CSK", "CUC", "CUP", "CVE", "CYP", "CZK",
       "DDM", "DEM", "DJF", "DKK", "DOP", "DZD", "ECS", "ECV", "EEK", "EGP", "ERN",
       "ESA", "ESB", "ESP", "ETB", "EUR", "FIM", "FJD", "FKP", "FRF", "GBP", "GEK",
       "GEL", "GHC", "GHS", "GIP", "GMD", "GNF", "GNS", "GQE", "GRD", "GTQ", "GWE",
       "GWP", "GYD", "HKD", "HNL", "HRD", "HRK", "HTG", "HUF", "IDR", "IEP", "ILP",
       "ILR", "ILS", "INR", "IQD", "IRR", "ISJ", "ISK", "ITL", "JMD", "JOD", "JPY",
       "KES", "KGS", "KHR", "KMF", "KPW", "KRH", "KRO", "KRW", "KWD", "KYD", "KZT",
       "LAK", "LBP", "LKR", "LRD", "LSL", "LTL", "LTT", "LUC", "LUF", "LUL", "LVL",
       "LVR", "LYD", "MAD", "MAF", "MCF", "MDC", "MDL", "MGA", "MGF", "MKD", "MKN",
       "MLF", "MMK", "MNT", "MOP", "MRO", "MTL", "MTP", "MUR", "MVP", "MVR", "MWK",
       "MXN", "MXP", "MXV", "MYR", "MZE", "MZM", "MZN", "NAD", "NGN", "NIC", "NIO",
       "NLG", "NOK", "NPR", "NZD", "OMR", "PAB", "PEI", "PEN", "PES", "PGK", "PHP",
       "PKR", "PLN", "PLZ", "PTE", "PYG", "QAR", "RHD", "ROL", "RON", "RSD", "RUB",
       "RUR", "RWF", "SAR", "SBD", "SCR", "SDD", "SDG", "SDP", "SEK", "SGD", "SHP",
       "SIT", "SKK", "SLL", "SOS", "SRD", "SRG", "SSP", "STD", "SUR", "SVC", "SYP",
       "SZL", "THB", "TJR", "TJS", "TMM", "TMT", "TND", "TOP", "TPE", "TRL", "TRY",
       "TTD", "TWD", "TZS", "UAH", "UAK", "UGS", "UGX", "USD", "USN", "USS", "UYI",
       "UYP", "UYU", "UZS", "VEB", "VEF", "VND", "VNN", "VUV", "WST", "XAF", "XAG",
       "XAU", "XBA", "XBB", "XBC", "XBD", "XCD", "XDR", "XEU", "XFO", "XFU", "XOF",
       "XPD", "XPF", "XPT", "XRE", "XSU", "XTS", "XUA", "XXX", "YDD", "YER", "YUD",
       "YUM", "YUN", "YUR", "ZAL", "ZAR", "ZMK", "ZMW", "ZRN", "ZRZ", "ZWD", "ZWL",
       "ZWR"]

  """
  def known_currencies do
    currency_codes() |> Enum.map(&Atom.to_string/1) |> Enum.sort
  end

  @doc """
  Returns a list of strings representing the number systems known to `Cldr`.

  ## Example

      iex> Cldr.Config.known_number_systems
      ["adlm", "ahom", "arab", "arabext", "armn", "armnlow", "bali", "beng", "bhks",
       "brah", "cakm", "cham", "cyrl", "deva", "ethi", "fullwide", "geor", "grek",
       "greklow", "gujr", "guru", "hanidays", "hanidec", "hans", "hansfin", "hant",
       "hantfin", "hebr", "hmng", "java", "jpan", "jpanfin", "kali", "khmr", "knda",
       "lana", "lanatham", "laoo", "latn", "lepc", "limb", "mathbold", "mathdbl",
       "mathmono", "mathsanb", "mathsans", "mlym", "modi", "mong", "mroo", "mtei",
       "mymr", "mymrshan", "mymrtlng", "newa", "nkoo", "olck", "orya", "osma",
       "roman", "romanlow", "saur", "shrd", "sind", "sinh", "sora", "sund", "takr",
       "talu", "taml", "tamldec", "telu", "thai", "tibt", "tirh", "vaii", "wara"]

  """
  def known_number_systems do
    number_systems() |> Map.keys |> Enum.map(&Atom.to_string/1) |> Enum.sort
  end

  @doc """
  Returns true if a `Gettext` module is configured in Cldr and
  the `Gettext` module is available.

  ## Example

      iex> Cldr.Config.gettext_configured?
      true
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

      iex> Cldr.Config.expand_locales(["fr-*"])
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
  Returns the location of the json data for a locale or `nil`
  if the locale can't be found.

  * `locale` is any locale returned from `Cldr.known_locales()`
  """
  @spec locale_path(String.t) :: {:ok, String.t} | {:error, :not_found}
  def locale_path(locale) do
    relative_locale_path = ["locales/", "#{locale}.json"]
    client_path = Path.join(client_data_dir(), relative_locale_path)
    cldr_path   = Path.join(cldr_data_dir(), relative_locale_path)
    cond do
      File.exists?(client_path) -> {:ok, client_path}
      File.exists?(cldr_path)   -> {:ok, cldr_path}
      true                      -> {:error, :not_found}
    end
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
  def get_locale(locale) do
    {:ok, path} = case locale_path(locale) do
      {:ok, path} ->
        {:ok, path}
      {:error, :not_found} ->
        raise RuntimeError, message: "Locale definition was not found for #{locale}"
      error                ->
        raise RuntimeError, message: "Unexpected return from locale_path(#{inspect locale}) => #{inspect error}"
    end

    do_get_locale(locale, path, Cldr.Locale.Cache.compiling?())
  end

  @doc false
  def do_get_locale(locale, path, compiling? \\ false)
  def do_get_locale(locale, path, false) do
    path
    |> File.read!
    |> Poison.decode!
    |> assert_valid_keys!(locale)
    |> Cldr.Map.atomize_keys
    |> structure_rbnf
    |> atomize_number_systems
    |> structure_date_formats
    |> Map.put(:name, locale)
  end

  @doc false
  def do_get_locale(locale, path, true) do
    Cldr.Locale.Cache.get_locale(locale, path)
  end

  @doc """
  Returns a list of the vaid currency codes in
  upcased atom format
  """
  def currency_codes do
    client_data_dir()
    |> Path.join("currencies.json")
    |> File.read!
    |> Poison.decode!
    |> Enum.map(&String.to_atom/1)
  end

  @doc """
  Returns the map of aliases for languages,
  scripts and regions
  """
  def aliases do
    client_data_dir()
    |> Path.join("aliases.json")
    |> File.read!
    |> Poison.decode!
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
    |> Enum.into(%{})
    |> structify_languages
  end

  defp structify_languages(map) do
    languages = Enum.map(map.language, fn {k, v} ->
      values = Cldr.Map.atomize_keys(v)
      {k, struct(Cldr.LanguageTag, values)}
    end)
    |> Enum.into(%{})

    Map.put(map, :language, languages)
  end

  @doc """
  Returns the likely subtags map which maps a
  locale string to %LaguageTag{} representing
  the likely subtags for that locale string
  """
  def likely_subtags do
    client_data_dir()
    |> Path.join("likely_subtags.json")
    |> File.read!
    |> Poison.decode!
    |> Enum.map(fn {k, v} -> {k, struct(Cldr.LanguageTag, Cldr.Map.atomize_keys(v))} end)
    |> Enum.into(%{})
  end

  @doc """
  Returns the data that defines start and end of
  calendar weeks, weekends and years
  """
  def week_data do
    client_data_dir()
    |> Path.join("week_data.json")
    |> File.read!
    |> Poison.decode!
    |> Cldr.Map.underscore_key("WeekendStart")
    |> Cldr.Map.underscore_key("WeekendEnd")
    |> Cldr.Map.underscore_key("minDays")
    |> Cldr.Map.underscore_key("firstDay")
    |> Cldr.Map.atomize_keys
    |> Cldr.Map.integerize_values
    |> Map.take([:weekend_start, :weekend_end, :min_days, :first_day])
  end

  @doc """
  Returns the data that defines time periods of
  a day for a language.

  Time period rules are used to define the meaning
  of "morning", "evening", "noon", "midnight" and
  potentially other periods on a per-language basis.
  """
  def day_periods do
    client_data_dir()
    |> Path.join("day_periods.json")
    |> File.read!
    |> Poison.decode!
  end

  @doc """
  Returns the data that defines start and end of
  calendar epochs
  """
  def calendar_data do
    client_data_dir()
    |> Path.join("calendar_data.json")
    |> File.read!
    |> Poison.decode!
    |> Cldr.Map.atomize_keys
    |> Cldr.Map.integerize_keys
    |> add_era_end_dates
  end

  @doc """
  Returns the calendars available for a given locale
  """
  def calendars_for_locale(locale_data) do
    locale_data
    |> Map.get(:dates)
    |> Map.get(:calendars)
    |> Map.keys
  end

  def add_era_end_dates(calendars) do
    Enum.map(calendars, fn {calendar, content} ->
      new_content = Enum.map(content, fn
        {:eras, eras} -> {:eras, add_end_dates(eras)}
        {k, v} -> {k, v}
      end)
      |> Enum.into(%{})
      {calendar, new_content}
    end)
    |> Enum.into(%{})
  end

  def add_end_dates(%{} = eras) do
    eras
    |> Enum.sort_by(fn {k, _v} -> k end, fn a, b -> a < b end)
    |> add_end_dates
  end

  def add_end_dates([{_, %{start: _start_1}} = era_1, {_, %{start: start_2}} = era_2]) do
    {era, dates} = era_1
    [{era, Map.put(dates, :end, start_2 - 1)}, era_2]
  end

  def add_end_dates([{_, %{start: _start_1}} = era_1 | [{_, %{start: start_2}} | _] = tail]) do
    {era, dates} = era_1
    [{era, Map.put(dates, :end, start_2 - 1)}] ++ add_end_dates(tail)
  end

  def add_end_dates(other) do
    other
  end

  @doc """
  Get the configured number formats that should be precompiled at application
  compilation time.

  ## Example

      iex> Cldr.Config.get_precompile_number_formats
      []
  """
  def get_precompile_number_formats do
    Application.get_env(:ex_cldr, :precompile_number_formats, [])
  end

  # Extract number formats from short and long lists
  @doc false
  def extract_formats(formats) when is_map(formats) do
    formats
    |> Map.values
    |> Enum.map(&hd/1)
  end

  @doc false
  def extract_formats(format) do
    format
  end

  def decimal_formats_for(locale) do
    locale
    |> get_locale
    |> Map.get(:number_formats)
    |> Map.values
    |> Enum.map(&(Map.delete(&1, :currency_spacing)))
    |> Enum.map(&(Map.delete(&1, :currency_long)))
    |> Enum.map(&Map.values/1)
    |> List.flatten
    |> Enum.reject(&is_integer/1)
    |> Enum.map(&extract_formats/1)
    |> List.flatten
    |> Enum.uniq
    |> Enum.sort
  end

  def number_systems do
    cldr_data_dir()
    |> Path.join("number_systems.json")
    |> File.read!
    |> Poison.decode!
    |> Cldr.Map.atomize_keys
    |> Enum.map(fn {k, v} -> {k, %{v | type: String.to_atom(v.type)}} end)
    |> Enum.into(%{})
  end

  def rbnf_rule_function(rule_name) do
    case String.split(rule_name, "/") do
      [locale, ruleset, rule] ->
        ruleset_module =
          ruleset
          |> String.trim_trailing("Rules")

        function =
          rule
          |> String.replace("-","_")
          |> String.to_atom

        locale =
          locale
          |> String.replace("_","-")

        module = Module.concat(Cldr.Rbnf, ruleset_module)
        {module, function, locale}
      [rule] ->
        function =
          rule
          |> String.replace("-","_")
          |> String.to_atom
        {Cldr.Rbnf.NumberSystem, function, "root"}
    end
  end

  # ------ Helpers ------

  # Simple check that the locale content contains what we expect
  # by checking it has the keys we used when the locale was consolidated.
  defp assert_valid_keys!(content, locale) do
    for module <- required_modules() do
      if !Map.has_key?(content, module) and !System.get_env("DEV") do
        raise RuntimeError, message:
          "Locale file #{inspect locale} is invalid - map key #{inspect module} was not found."
      end
    end
    content
  end

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

  defp structure_date_formats(content) do
    dates = content.dates
    |> Cldr.Map.integerize_keys

    Map.put(content, :dates, dates)
  end

  # Put the rbnf rules into a %Rule{} struct
  defp structure_rbnf(content) do
    rbnf = content[:rbnf]
    |> Enum.map(fn {group, sets} ->
      {group, structure_sets(sets)}
    end)
    |> Enum.into(%{})

    Map.put(content, :rbnf, rbnf)
  end

  defp structure_sets(sets) do
    Enum.map(sets, fn {name, set} ->
      name = underscore(name)
      {underscore(name), Map.put(set, :rules, set[:rules])}
    end)
    |> Enum.into(%{})
  end

  defp underscore(string) when is_binary(string) do
    string
    |> String.replace("-","_")
  end
  defp underscore(other), do: other

  # Convert to an atom but only if
  # its a binary.
  defp atomize(nil), do: nil
  defp atomize(v) when is_binary(v), do: String.to_atom(v)
  defp atomize(v), do: v

  @doc false
  def true_false() do
    ["true", "false"]
  end

  @doc false
  def days_of_week() do
    ["sun", "mon", "tue", "wed", "thu", "fri", "sat", "sun"]
  end

  @doc false
  def collations() do
    [
      "big5han",
      "dict",
      "direct",
      "gb2312",
      "phonebk",
      "pinyin",
      "reformed",
      "standard",
      "stroke",
      "trad",
      "unihan"
    ]
  end
end
