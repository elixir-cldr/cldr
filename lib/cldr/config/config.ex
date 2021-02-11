defmodule Cldr.Config do
  @moduledoc false

  # The functions in this module are considered
  # private use.

  alias Cldr.Locale
  alias Cldr.LanguageTag

  defstruct default_locale: "en-001",
            locales: ["en-001"],
            backend: nil,
            gettext: nil,
            data_dir: "cldr",
            providers: nil,
            precompile_number_formats: [],
            precompile_transliterations: [],
            precompile_date_time_formats: [],
            precompile_interval_formats: [],
            otp_app: nil,
            generate_docs: true,
            supress_warnings: false,
            message_formats: [],
            force_locale_download: false

  @type t :: %__MODULE__{
          default_locale: binary(),
          locales: [binary(), ...],
          backend: module(),
          gettext: module() | nil,
          data_dir: binary(),
          precompile_number_formats: [binary(), ...],
          precompile_transliterations: [{atom(), atom()}, ...],
          precompile_date_time_formats: [binary(), ...],
          precompile_interval_formats: [binary(), ...],
          otp_app: atom() | nil,
          providers: [atom(), ...],
          generate_docs: boolean(),
          supress_warnings: boolean(),
          message_formats: map(),
          force_locale_download: boolean
        }

  @type number_system :: atom() | String.t()

  @default_locale_name "en-001"

  @cldr_modules [
    "number_formats",
    "list_formats",
    "currencies",
    "number_systems",
    "number_symbols",
    "minimum_grouping_digits",
    "rbnf",
    "units",
    "date_fields",
    "dates",
    "territories",
    "languages",
    "delimiters",
    "ellipsis",
    "lenient_parse"
  ]

  def include_module_docs?(false) do
    false
  end

  def include_module_docs?(_flag) do
    true
  end

  @doc false
  @non_language_locale_names []
  def non_language_locale_names do
    @non_language_locale_names
  end

  @doc false
  defmacro is_alphabetic(char) do
    quote do
      unquote(char) in ?a..?z or unquote(char) in ?A..?Z
    end
  end

  @doc """
  Return the configured application name
  for cldr

  Note this is probably `:ex_cldr` which is
  what this app is called on `hex.pm`

  """
  @app_name Mix.Project.config()[:app]
  def app_name do
    @app_name
  end

  @doc """
  Return the configured json lib
  """
  @json_lib_error """
   A JSON library has not been configured.\n
   Please configure a JSON lib in your `mix.exs`
   file. The suggested library is `:jason`.

   For example in your `mix.exs`:

     def deps() do
       [
         {:jason, "~> 1.0"},
         ...
       ]
     end

   You can then configure this library for `ex_cldr`
   in your `config.exs` as follows:

   config :ex_cldr,
      json_library: Jason

   If no configuration is provided, `ex_cldr` will
   attempt to detect any JSON library configured
   for Phoenix or Ecto then it will try to detect
   if Jason or Poison are configured.

  """
  @poison if(Code.ensure_loaded?(Poison), do: Poison, else: nil)
  @jason if(Code.ensure_loaded?(Jason), do: Jason, else: nil)
  @phoenix_json Application.get_env(:phoenix, :json_library)
  @ecto_json Application.get_env(:ecto, :json_library)
  @default_json_lib @phoenix_json || @ecto_json || @jason || @poison
  @json_lib Application.get_env(:ex_cldr, :json_library, @default_json_lib)

  _ = @poison
  _ = @jason
  _ = @phoenix_json
  _ = @ecto_json
  _ = @json_lib_error

  unless Code.ensure_loaded?(@json_lib) and function_exported?(@json_lib, :decode!, 1) do
    raise ArgumentError, @json_lib_error
  end

  def json_library do
    @json_lib
  end

  @doc """
  Return the root path of the cldr application
  """
  def cldr_home do
    Path.join(__DIR__, "/../../..") |> Path.expand()
  end

  @doc """
  Returns the directory where the downloaded CLDR repository files
  are stored.

  These are the real CLDR data files that are used only for the
  development of ex_cldr.  They are not included in the hex
  package.

  """
  def download_data_dir do
    System.get_env("CLDR_PRODUCTION") || raise(ArgumentError, """
    The environment variable $CLDR_PRODUCTION must be set to the
    directory where the CLDR json data is stored.

    See DEVELOPMENT.md for more information about CLDR data
    and generating the json files.
    """)
  end

  @doc """
  Return the directory where `Cldr` stores its source core data,

  This directory should not be expected to be available
  other than when developing Cldr since it points to a source
  directory.

  These are the json files that result from the normalization
  of the original CLDR data.

  """
  @cldr_source_dir "/priv/cldr" |> Path.expand()
  def source_data_dir do
    Path.join(cldr_home(), @cldr_source_dir)
  end

  @doc """
  Returns the path of the CLDR data directory for the ex_cldr app.

  This is the directory where base CLDR data files are stored
  incuding included locale files.

  """
  def cldr_data_dir do
    [:code.priv_dir(app_name()), "/cldr"] |> :erlang.iolist_to_binary()
  end

  @doc """
  Return the path name of the CLDR data directory for a client
  application.

  The order of priority to determine where the client data
  directory is located is:

  * A specified `:data_dir` of a backend configuration
  * The specified `:data_dir` of the backend's `:otp_app` configuration
  * The specified `:data_dir` of the global configuration
  * The `priv_dir()` of a specified `:otp_app`
  * The `priv_dir()` of `ex_cldr`

  Note that `config_from_opts/1` merges the global config,
  the otp_app config and the module config together so
  that `:data_dir` already resolves this priority in most
  cases.

  The remaining cases are for when no `:data_dir` is
  specified.

  """
  @spec client_data_dir(map()) :: String.t()

  def client_data_dir(%{data_dir: data_dir}) when not is_nil(data_dir) do
    data_dir
  end

  def client_data_dir(%{otp_app: nil}) do
    cldr_data_dir()
  end

  def client_data_dir(%{otp_app: otp_app}) do
    case :code.priv_dir(otp_app) do
      {:error, :bad_name} ->
        raise Cldr.UnknownOTPAppError, "The configured OTP app #{inspect(otp_app)} is not known"

      priv_dir ->
        [priv_dir, "/cldr"] |> :erlang.iolist_to_binary()
    end
  end

  def client_data_dir(config) when is_map(config) do
    client_data_dir(%{data_dir: nil, otp_app: nil})
  end

  def client_data_dir(backend) when is_atom(backend) do
    client_data_dir(backend.__cldr__(:config))
  end

  @doc """
  Returns the directory where downloaded ex_cldr locales files
  are located.

  """
  def client_locales_dir(config) do
    Path.join(client_data_dir(config), "locales")
  end

  @doc """
  Returns the version string of the CLDR data repository
  """
  def version do
    cldr_data_dir()
    |> Path.join("version.json")
    |> File.read!()
    |> json_library().decode!
  end

  @doc """
  Returns the filename that contains the json representation
  of a locale.

  """
  def locale_filename(locale) do
    "#{locale}.json"
  end

  @doc """
  Return the configured `Gettext` module name or `nil`.

  """
  @spec gettext(t() | map()) :: module() | nil
  def gettext(%{} = config) do
    Map.get(config, :gettext)
  end

  @doc """
  Return the default locale name for a given backend
  configuration.

  In order of priority return either:

  * The default locale for a given backend configuration
  * The global default locale speficied in `mix.exs` under
    the `ex_cldr` key
  * The `Gettext.get_locale/1` for the current configuration
  * The system-wide default locale which is currently
    #{inspect(@default_locale_name)}

  """
  @spec default_locale_name(t() | map()) :: Locale.locale_name()
  def default_locale_name(%{} = config) do
    Map.get(config, :default_locale) ||
      Application.get_env(
        app_name(),
        :default_locale,
        gettext_default_locale(config) || @default_locale_name
      )
  end

  @doc """
  Return the system-wide default locale.

  """
  def default_locale do
    Application.get_env(app_name(), :default_locale, @default_locale_name)
  end

  @doc """
  Return the system-wide default backend

  """
  def default_backend do
    Application.get_env(app_name(), :default_backend) ||
      raise(Cldr.NoDefaultBackendError, "No default #{inspect(app_name())} backend is configured")
  end

  @doc """
  Return the default gettext locale for a CLDR
  config.

  """
  def gettext_default_locale(config) do
    if gettext_configured?(config) do
      Gettext
      |> apply(:get_locale, [gettext(config)])
      |> locale_name_from_posix()
    else
      nil
    end
  end

  @doc """
  Return a list of the locales defined in `Gettext`.

  Return a list of locales configured in `Gettext` or
  `[]` if `Gettext` is not configured.

  """
  @spec known_gettext_locale_names(t()) :: [Locale.locale_name()]
  def known_gettext_locale_names(config) do
    if gettext_configured?(config) && Application.ensure_all_started(:gettext) do
      otp_app = gettext(config).__gettext__(:otp_app)
      gettext_backend = gettext(config)

      backend_default =
        if backend_config = Application.get_env(otp_app, gettext_backend) do
          Keyword.get(backend_config, :default_locale)
        else
          nil
        end

      global_default = Application.get_env(:gettext, :default_locale)

      locales =
        apply(Gettext, :known_locales, [gettext_backend]) ++
          [backend_default, global_default]

      locales
      |> Enum.reject(&is_nil/1)
      |> Enum.map(&locale_name_from_posix/1)
      |> Enum.uniq()
      |> Enum.sort()
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
  @available_locales_file "available_locales.json"
  @spec all_locale_names :: [Locale.locale_name(), ...]
  def all_locale_names do
    Path.join(cldr_data_dir(), @available_locales_file)
    |> File.read!()
    |> json_library().decode!
    |> Enum.sort()
  end

  @doc """
  Returns the map of language tags for all
  available locales
  """
  @tag_file "language_tags.ebin"
  def all_language_tags do
    Path.join(cldr_data_dir(), @tag_file)
    |> File.read!()
    |> :erlang.binary_to_term()
  rescue
    _e in File.Error -> %{}
  end

  @doc """
  Return a map of plural ranges

  """
  @plural_range_file "plural_ranges.json"
  def plural_ranges do
    Path.join(cldr_data_dir(), @plural_range_file)
    |> File.read!()
    |> json_library().decode!
    |> Enum.map(fn
      %{"locales" => locales, "ranges" => ranges} ->
        %{
          locales: locales,
          ranges:
            Enum.map(ranges, fn
              range -> Cldr.Map.atomize_keys(range) |> Cldr.Map.atomize_values()
            end)
        }
    end)
  end

  @doc """
  Return a map of measurement systems

  """
  @measurement_systems_file "measurement_systems.json"
  def measurement_systems do
    Path.join(cldr_data_dir(), @measurement_systems_file)
    |> File.read!()
    |> json_library().decode!
    |> Cldr.Map.atomize_keys()
    |> Cldr.Map.deep_map(fn
      {:description, description} -> {:description, description}
      {:alias, ""} -> {:alias, nil}
      {k, v} when is_binary(v) -> {k, String.to_atom(v)}
      other -> other
    end)
    |> Map.new()
  end

  @doc """
  Returns a boolean indicating whether the language_tags.ebin
  file exists

  """
  def all_language_tags? do
    cldr_data_dir()
    |> Path.join(@tag_file)
    |> File.exists?()
  end

  @doc """
  Return the saved language tag for the
  given locale name
  """
  @spec language_tag(Locale.locale_name()) :: Cldr.LanguageTag.t() | no_return()
  def language_tag(locale_name) do
    Map.fetch!(all_language_tags(), locale_name)
  end

  @doc """
  Returns a list of all locales configured in a
  `Cldr.Config.t` struct.

  In order of priority return either:

  * The list of locales configured configured in mix.exs if any

  * The default locale

  If the configured locales is `:all` then all locales
  in CLDR are configured.

  The locale "root" is always added to the list of configured locales since it
  is required to support some RBNF functions.

  The use of `:all` is not recommended since all 541 locales take
  quite some time (minutes) to compile. It is however
  helpful for testing Cldr.

  """
  @spec configured_locale_names(t()) :: [Locale.locale_name()]
  def configured_locale_names(config) do
    locale_names =
      case app_locale_names = Map.get(config, :locales) do
        :all -> all_locale_names()
        nil -> expand_locale_names([default_locale_name(config)])
        _ -> expand_locale_names(app_locale_names)
      end

    ["root" | locale_names]
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Returns a list of all locales that are configured and available
  in the CLDR repository.

  """
  @spec known_locale_names(t() | Cldr.backend()) :: [Locale.locale_name()]
  def known_locale_names(backend) when is_atom(backend) do
    backend.__cldr__(:config)
    |> known_locale_names
  end

  def known_locale_names(%__MODULE__{locales: :all}) do
    all_locale_names()
    |> Enum.sort
  end

  def known_locale_names(%__MODULE__{locales: locales}) do
    Enum.sort(locales)
  end

  def known_rbnf_locale_names(config) do
    known_locale_names(config)
    |> Enum.filter(fn locale -> Map.get(get_locale(locale, config), :rbnf) != %{} end)
  end

  @doc """
  Returns either the locale name (if its known)
  or `false` if the locale name is not known.

  """
  def known_locale_name(locale_name, config) do
    if locale_name in known_locale_names(config) do
      locale_name
    else
      false
    end
  end

  @doc """
  Returns either the locale name (if its known
  and has an rbnf configuration)
  or `false`.

  """
  def known_rbnf_locale_name(locale_name, config) do
    if locale_name in known_rbnf_locale_names(config) do
      locale_name
    else
      false
    end
  end

  @doc """
  Returns a list of all locales that are configured but not available
  in the CLDR repository.

  """
  @spec unknown_locale_names(t()) :: [Locale.locale_name()]
  def unknown_locale_names(%__MODULE__{locales: :all}) do
    []
  end

  def unknown_locale_names(%__MODULE__{locales: locales}) do
    locales
    |> MapSet.new()
    |> MapSet.difference(MapSet.new(all_locale_names()))
    |> MapSet.to_list()
    |> Enum.sort()
  end

  @doc """
  Returns a list of all configured locales.

  The list contains locales configured both in `Gettext` and
  specified in the mix.exs configuration file as well as the
  default locale.

  """
  @spec requested_locale_names(t()) :: [Locale.locale_name()]
  def requested_locale_names(config) do
    locales =
      configured_locale_names(config) ++
        known_gettext_locale_names(config) ++
        [default_locale_name(config)]

    locales
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Returns a list of strings representing the calendars known to `Cldr`.

  ## Example

      iex> Cldr.Config.known_calendars
      [:buddhist, :chinese, :coptic, :dangi, :ethiopic, :ethiopic_amete_alem,
       :gregorian, :hebrew, :indian, :islamic, :islamic_civil, :islamic_rgsa,
       :islamic_tbla, :islamic_umalqura, :japanese, :persian, :roc]

  """
  def known_calendars do
    calendars() |> Map.keys() |> Enum.sort()
  end

  @doc """
  Returns a list of the currencies known in `Cldr` in
  upcased atom format.

  ## Example

      iex> Cldr.Config.known_currencies
      [:XBB, :XEU, :SKK, :AUD, :CZK, :ISJ, :BRC, :IDR, :UYP, :VEF, :UAH, :KMF, :NGN,
       :NAD, :LUC, :AWG, :BRZ, :AOK, :SHP, :DEM, :UGS, :ECS, :BRR, :HUF, :INR, :TPE,
       :GYD, :MCF, :USS, :ALK, :TJR, :BGO, :BUK, :DKK, :LSL, :AZM, :ZRN, :MKN, :GHC,
       :JMD, :NOK, :GWP, :CVE, :RUR, :BDT, :NIC, :LAK, :XFO, :KHR, :SRD, :ESB, :PGK,
       :YUD, :BRN, :MAD, :PYG, :QAR, :MOP, :BOB, :CHW, :PHP, :SDG, :SEK, :KZT, :SDP,
       :ZWD, :XTS, :SRG, :ANG, :CLF, :BOV, :XBA, :TMT, :TJS, :CUC, :SUR, :MAF, :BRL,
       :PLZ, :PAB, :AOA, :ZWR, :UGX, :PTE, :NPR, :BOL, :MRO, :MXN, :ATS, :ARP, :KWD,
       :CLE, :NLG, :TMM, :SAR, :PEN, :PKR, :RUB, :AMD, :MDL, :XRE, :AOR, :MZN, :ESA,
       :XOF, :CNX, :ILR, :KRW, :CDF, :VND, :DJF, :FKP, :BIF, :FJD, :MYR, :BBD, :GEK,
       :PES, :CNY, :GMD, :SGD, :MTP, :ZMW, :MWK, :BGN, :GEL, :TTD, :LVL, :XCD, :ARL,
       :EUR, :UYU, :ZAL, :CSD, :ECV, :GIP, :CLP, :KRH, :CYP, :TWD, :SBD, :SZL, :IRR,
       :LRD, :CRC, :XDR, :SYP, :YUM, :SIT, :DOP, :MVP, :BWP, :KPW, :GNS, :ZMK, :BZD,
       :TRY, :MLF, :KES, :MZE, :ALL, :JOD, :HTG, :TND, :ZAR, :LTT, :BGL, :XPD, :CSK,
       :SLL, :BMD, :BEF, :FIM, :ARA, :ZRZ, :CHF, :SOS, :KGS, :GWE, :LTL, :ITL, :DDM,
       :ERN, :BAM, :BRB, :ARS, :RHD, :STD, :RWF, :GQE, :HRD, :ILP, :YUR, :AON, :BYR,
       :RSD, :ZWL, :XBD, :XFU, :GBP, :VEB, :BTN, :UZS, :BGM, :BAD, :MMK, :XBC, :LUF,
       :BSD, :XUA, :GRD, :CHE, :JPY, :EGP, :XAG, :LYD, :XAU, :USD, :BND, :XPT, :BRE,
       :ROL, :PLN, :MZM, :FRF, :MGF, :LUL, :SSP, :DZD, :IEP, :SDD, :ADP, :AFN, :IQD,
       :GHS, :TOP, :LVR, :YUN, :MRU, :MKD, :GNF, :MXP, :THB, :CNH, :TZS, :XPF, :AED,
       :SVC, :RON, :BEC, :CUP, :USN, :LBP, :BOP, :BHD, :UYW, :BAN, :MDC, :VUV, :MGA,
       :ISK, :COP, :BYN, :UAK, :TRL, :SCR, :KRO, :ILS, :ETB, :CAD, :AZN, :VNN, :NIO,
       :COU, :EEK, :KYD, :MNT, :HNL, :WST, :PEI, :YER, :MTL, :STN, :AFA, :ARM, :HKD,
       :NZD, :VES, :UYI, :MXV, :GTQ, :BYB, :XXX, :XSU, :HRK, :OMR, :BEL, :MUR, :ESP,
       :YDD, :MVR, :LKR, :XAF]

  """
  def known_currencies do
    cldr_data_dir()
    |> Path.join("currencies.json")
    |> File.read!()
    |> json_library().decode!
    |> Enum.map(&String.to_atom/1)
  end

  @doc """
  Returns a list of strings representing the number systems known to `Cldr`.

  ## Example

      iex> Cldr.Config.known_number_systems
      [:adlm, :ahom, :arab, :arabext, :armn, :armnlow, :bali, :beng, :bhks, :brah,
       :cakm, :cham, :cyrl, :deva, :diak, :ethi, :fullwide, :geor, :gong, :gonm, :grek,
       :greklow, :gujr, :guru, :hanidays, :hanidec, :hans, :hansfin, :hant, :hantfin,
       :hebr, :hmng, :hmnp, :java, :jpan, :jpanfin, :jpanyear, :kali, :khmr, :knda, :lana, :lanatham,
       :laoo, :latn, :lepc, :limb, :mathbold, :mathdbl, :mathmono, :mathsanb,
       :mathsans, :mlym, :modi, :mong, :mroo, :mtei, :mymr, :mymrshan, :mymrtlng,
       :newa, :nkoo, :olck, :orya, :osma, :rohg, :roman, :romanlow, :saur, :segment, :shrd,
       :sind, :sinh, :sora, :sund, :takr, :talu, :taml, :tamldec, :telu, :thai, :tibt,
       :tirh, :vaii, :wara, :wcho]

  """
  def known_number_systems do
    number_systems()
    |> Map.keys()
    |> Enum.sort()
  end

  @doc """
  Returns locale and number systems that have the same digits and
  separators as the supplied one.

  Transliterating between locale & number systems is expensive.  To avoid
  unncessary transliteration we look for locale and number systems that have
  the same digits and separators.  Typically we are comparing to locale "en"
  and number system "latn" since this is what the number formatting routines use
  as placeholders.

  This function is intended for use at compile time only and is
  used to help optimise the generation of transliteration functions.

  """
  @spec known_number_systems_like(Locale.locale_name(), number_system(), t()) ::
          {:ok, list()} | {:error, {module(), String.t()}}

  def known_number_systems_like(locale_name, number_system, config) do
    with {:ok, %{digits: digits}} <- number_system_for(locale_name, number_system, config),
         {:ok, symbols} <- number_symbols_for(locale_name, number_system, config),
         {:ok, names} <- number_system_names_for(locale_name, config) do
      likes = do_number_systems_like(digits, symbols, names, config)
      {:ok, likes}
    end
  end

  defp do_number_systems_like(digits, symbols, names, config) do
    Enum.map(known_locale_names(config), fn this_locale ->
      Enum.reduce(names, [], fn this_system, acc ->
        case number_system_for(this_locale, this_system, config) do
          {:error, {_, _}} ->
            acc

          {:ok, %{digits: these_digits}} ->
            {:ok, these_symbols} = number_symbols_for(this_locale, this_system, config)

            if digits == these_digits && symbols == these_symbols do
              acc ++ {this_locale, this_system}
            end
        end
      end)
    end)
    |> Enum.reject(&(is_nil(&1) || &1 == []))
  end

  @doc """
  Returns the number system types that
  are known.

  """
  @max_concurrency :"Elixir.System".schedulers_online() * 2
  def known_number_system_types(config) do
    config
    |> known_locale_names()
    |> Task.async_stream(__MODULE__, :number_systems_for, [config],
      max_concurrency: @max_concurrency,
      timeout: :infinity
    )
    |> Enum.to_list()
    |> Enum.flat_map(fn {:ok, {:ok, systems}} -> Map.keys(systems) end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Returns the number systems for a locale

  ## Example

      iex> Cldr.Config.number_systems_for("en", %Cldr.Config{locales: ["en", "de"]})
      {:ok, %{default: :latn, native: :latn}}
  """
  @spec number_systems_for(Locale.locale_name(), t()) ::
          {:ok, map()} | {:error, {module(), String.t()}}

  def number_systems_for(locale_name, %__MODULE__{} = config) do
    if known_locale_name(locale_name, config) do
      number_systems =
        locale_name
        |> get_locale(config)
        |> Map.get(:number_systems)

      {:ok, number_systems}
    else
      {:error, Cldr.Locale.locale_error(locale_name)}
    end
  end

  @doc """
  Returns the number systems for a locale
  or raises if there is an error

  ## Example

      iex> Cldr.Config.number_systems_for!("de", %Cldr.Config{locales: ["en", "de"]})
      %{default: :latn, native: :latn}

  """
  @spec number_systems_for!(Locale.locale_name(), t()) :: map() | no_return
  def number_systems_for!(locale_name, config) do
    case number_systems_for(locale_name, config) do
      {:ok, systems} -> systems
      {:error, {exception, reason}} -> raise exception, reason
    end
  end

  @doc """
  Returns the number system for a given
  locale and number system name.

  ## Example

      iex> Cldr.Config.number_system_for("th", :thai, %Cldr.Config{locales: ["th", "de"]})
      {:ok, %{digits: "๐๑๒๓๔๕๖๗๘๙", type: :numeric}}

  """
  @spec number_system_for(Locale.locale_name(), number_system(), t()) ::
          {:ok, map()} | {:error, {module(), String.t()}}

  def number_system_for(locale_name, number_system, config) do
    with {:ok, system_name} <- system_name_from(number_system, locale_name, config) do
      {:ok, Map.get(number_systems(), system_name)}
    end
  end

  @doc """
  Returns the number system names for a locale

  ## Example

      iex> Cldr.Config.number_system_names_for("th", %Cldr.Config{locales: ["en", "th"]})
      {:ok, [:latn, :thai]}

  """
  @spec number_system_names_for(Locale.locale_name(), t()) ::
          {:ok, [atom(), ...]} | {:error, {module(), String.t()}}

  def number_system_names_for(locale_name, config) do
    with {:ok, number_systems} <- number_systems_for(locale_name, config) do
      names =
        number_systems
        |> Enum.map(&elem(&1, 1))
        |> Enum.uniq()

      {:ok, names}
    end
  end

  @doc """
  Returns the number system types for a locale

  """
  def number_system_types_for(locale_name, config) do
    with {:ok, number_systems} <- number_systems_for(locale_name, config) do
      types =
        number_systems
        |> Enum.map(&elem(&1, 0))

      {:ok, types}
    end
  end

  @doc """
  Returns a number system name for a given locale and number system reference.

  ## Arguments

  * `system_name` is any number system name returned by
    `Cldr.known_number_systems/0` or a number system type
    returned by `Cldr.known_number_system_types/1`

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/1`
    or a `Cldr.LanguageTag` struct returned by `Cldr.Locale.new!/2`

  * `config` is a `Config.Cldr.t()` struct or a `Cldr.backend()` module

  Number systems can be referenced in one of two ways:

  * As a number system type such as `:default`, `:native`, `:traditional` and
    `:finance`. This allows references to a number system for a locale in a
    consistent fashion for a given use

  * With the number system name directly, such as :latn, :arab or any name
    returned by `Cldr.known_number_systems/0`

  This function dereferences the supplied `system_name` and returns the
  actual system name.

  ## Examples

      iex> Cldr.Config.system_name_from(:default, "en", TestBackend.Cldr)
      {:ok, :latn}

      iex> Cldr.Config.system_name_from("latn", "en", TestBackend.Cldr)
      {:ok, :latn}

      iex> Cldr.Config.system_name_from(:native, "en", TestBackend.Cldr)
      {:ok, :latn}

      iex> Cldr.Config.system_name_from(:nope, "en", TestBackend.Cldr)
      {
        :error,
        {Cldr.UnknownNumberSystemError, "The number system :nope is unknown"}
      }

  """
  @spec system_name_from(String.t(), Locale.locale_name() | LanguageTag.t(), t() | Cldr.backend()) ::
          {:ok, atom()} | {:error, {module(), String.t()}}

  def system_name_from(number_system, locale_name, backend) when is_atom(backend) do
    system_name_from(number_system, locale_name, backend.__cldr__(:config))
  end

  def system_name_from(number_system, locale_name, %__MODULE__{} = config) do
    with {:ok, number_systems} <- number_systems_for(locale_name, config),
         {:ok, number_system} <-
           validate_number_system_or_type(number_system, locale_name, config) do
      cond do
        Map.has_key?(number_systems, number_system) ->
          {:ok, Map.get(number_systems, number_system)}

        number_system in Map.values(number_systems) ->
          {:ok, number_system}

        true ->
          {:error, Cldr.unknown_number_system_error(number_system)}
      end
    end
  end

  defp validate_number_system_or_type(number_system, locale_name, config) do
    with {:ok, number_system} <- Cldr.validate_number_system(number_system) do
      {:ok, number_system}
    else
      {:error, _} ->
        with {:ok, number_system} <-
               validate_number_system_type(number_system, locale_name, config) do
          {:ok, number_system}
        else
          {:error, _reason} -> {:error, Cldr.unknown_number_system_error(number_system)}
        end
    end
  end

  defp validate_number_system_type(number_system_type, locale_name, config)
       when is_atom(number_system_type) do
    {:ok, known_types} = number_system_types_for(locale_name, config)

    if number_system_type in known_types do
      {:ok, number_system_type}
    else
      {:error, Cldr.unknown_number_system_type_error(number_system_type)}
    end
  end

  defp validate_number_system_type(number_system_type, locale_name, config)
       when is_binary(number_system_type) do
    number_system_type
    |> String.downcase()
    |> String.to_existing_atom()
    |> validate_number_system_type(locale_name, config)
  rescue
    ArgumentError ->
      {:error, Cldr.unknown_number_system_type_error(number_system_type)}
  end

  @doc """
  Get the number symbol definitions
  for a locale

  """
  def number_symbols_for(locale_name, config) do
    if known_locale_name(locale_name, config) do
      symbols =
        locale_name
        |> get_locale(config)
        |> Map.get(:number_symbols)
        |> Enum.map(fn
          {k, nil} -> {k, nil}
          {k, v} -> {k, struct(Cldr.Number.Symbol, v)}
        end)

      {:ok, symbols}
    else
      {:error, Locale.locale_error(locale_name)}
    end
  end

  def number_symbols_for(locale, number_system, config) do
    with {:ok, symbols} <- number_symbols_for(locale, config) do
      {:ok, Keyword.get(symbols, number_system)}
    end
  end

  @doc """
  Get the number symbol definitions
  for a locale or raises if an error

  """
  def number_symbols_for!(locale_name, config) do
    case number_symbols_for(locale_name, config) do
      {:ok, symbols} -> symbols
      {:error, {exception, reason}} -> raise exception, reason
    end
  end

  def number_symbols_for!(locale_name, number_system, config) do
    case number_symbols_for(locale_name, number_system, config) do
      {:ok, symbols} -> symbols
      {:error, {exception, reason}} -> raise exception, reason
    end
  end

  @doc """
  Returns a list of atoms representing the territories known to `Cldr`.

  ## Example

      iex> Cldr.Config.known_territories
      [:"001", :"002", :"003", :"005", :"009", :"011", :"013", :"014", :"015", :"017",
       :"018", :"019", :"021", :"029", :"030", :"034", :"035", :"039", :"053", :"054",
       :"057", :"061", :"142", :"143", :"145", :"150", :"151", :"154", :"155", :"202",
       :"419", :AC, :AD, :AE, :AF, :AG, :AI, :AL, :AM, :AO, :AQ, :AR, :AS, :AT, :AU,
       :AW, :AX, :AZ, :BA, :BB, :BD, :BE, :BF, :BG, :BH, :BI, :BJ, :BL, :BM, :BN, :BO,
       :BQ, :BR, :BS, :BT, :BV, :BW, :BY, :BZ, :CA, :CC, :CD, :CF, :CG, :CH, :CI, :CK,
       :CL, :CM, :CN, :CO, :CP, :CR, :CU, :CV, :CW, :CX, :CY, :CZ, :DE, :DG, :DJ, :DK,
       :DM, :DO, :DZ, :EA, :EC, :EE, :EG, :EH, :ER, :ES, :ET, :EU, :EZ, :FI, :FJ, :FK,
       :FM, :FO, :FR, :GA, :GB, :GD, :GE, :GF, :GG, :GH, :GI, :GL, :GM, :GN, :GP, :GQ,
       :GR, :GS, :GT, :GU, :GW, :GY, :HK, :HM, :HN, :HR, :HT, :HU, :IC, :ID, :IE, :IL,
       :IM, :IN, :IO, :IQ, :IR, :IS, :IT, :JE, :JM, :JO, :JP, :KE, :KG, :KH, :KI, :KM,
       :KN, :KP, :KR, :KW, :KY, :KZ, :LA, :LB, :LC, :LI, :LK, :LR, :LS, :LT, :LU, :LV,
       :LY, :MA, :MC, :MD, :ME, :MF, :MG, :MH, :MK, :ML, :MM, :MN, :MO, :MP, :MQ, :MR,
       :MS, :MT, :MU, :MV, :MW, :MX, :MY, :MZ, :NA, :NC, :NE, :NF, :NG, :NI, :NL, :NO,
       :NP, :NR, :NU, :NZ, :OM, :PA, :PE, :PF, :PG, :PH, :PK, :PL, :PM, :PN, :PR, :PS,
       :PT, :PW, :PY, :QA, :QO, :RE, :RO, :RS, :RU, :RW, :SA, :SB, :SC, :SD, :SE, :SG,
       :SH, :SI, :SJ, :SK, :SL, :SM, :SN, :SO, :SR, :SS, :ST, :SV, :SX, :SY, :SZ, :TA,
       :TC, :TD, :TF, :TG, :TH, :TJ, :TK, :TL, :TM, :TN, :TO, :TR, :TT, :TV, :TW, :TZ,
       :UA, :UG, :UM, :UN, :US, :UY, :UZ, :VA, :VC, :VE, :VG, :VI, :VN, :VU, :WF, :WS,
       :XK, :YE, :YT, :ZA, :ZM, :ZW]

  """
  def known_territories do
    territory_containment()
    |> Enum.map(&Tuple.to_list/1)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Returns the currency metadata for a locale.

  ## Arguments

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/1`
    or a `Cldr.LanguageTag` struct returned by `Cldr.Locale.new!/2`

  * `config` is a `Config.Cldr.t()` struct or a `Cldr.backend()` module

  """
  @reg Regex.compile!(
         "(?<currency>[^\\(]+)(?<annotation>\\([^0-9].+\\))?(.*\\((?<from>[0-9]{4}))?(–(?<to>[0-9]{4}))?"
       )
  def currencies_for(locale_name, config) do
    if known_locale_name(locale_name, config) do
      currencies =
        locale_name
        |> get_locale(config)
        |> Map.get(:currencies)
        |> Enum.map(fn {k, v} ->
          name_and_range = Regex.named_captures(@reg, Map.get(v, :name))

          name =
            (Map.get(name_and_range, "currency") <> Map.get(name_and_range, "annotation"))
            |> String.trim()

          from = convert_or_nilify(Map.get(name_and_range, "from"))
          to = convert_or_nilify(Map.get(name_and_range, "to"))

          count =
            Enum.map(Map.get(v, :count), fn {k, v} ->
              {k, String.replace(v, ~r/ \([0-9]{4}.*/, "")}
            end)
            |> Map.new()

          currency =
            v
            |> Map.put(:name, name)
            |> Map.put(:from, from)
            |> Map.put(:to, to)
            |> Map.put(:count, count)

          {k, currency}
        end)
        |> Enum.into(%{})

      {:ok, currencies}
    else
      {:error, Locale.locale_error(locale_name)}
    end
  end

  def currencies_for!(locale_name, config) do
    case currencies_for(locale_name, config) do
      {:ok, currencies} -> currencies
      {:error, {exception, reason}} -> raise exception, reason
    end
  end

  defp convert_or_nilify("") do
    nil
  end

  defp convert_or_nilify(other) do
    String.to_integer(other)
  end

  @doc """
  Returns the currency mapping data for
  territories.

  """
  @territory_currencies_file "territory_currencies.json"
  @spec territory_currency_data :: map()
  def territory_currency_data do
    Path.join(cldr_data_dir(), @territory_currencies_file)
    |> File.read!()
    |> json_library().decode!
    |> Enum.map(&convert_dates/1)
    |> Cldr.Map.merge_map_list()
    |> Cldr.Map.atomize_keys(level: 1)
  end

  defp convert_dates({territory, currency_dates}) do
    currency_dates =
      Enum.map(currency_dates, fn map ->
        currency = Map.keys(map) |> hd
        dates = Map.values(map) |> hd

        parsed_dates =
          Enum.flat_map(dates, fn
            [{"from", from}, {"to", to}] ->
              [{:from, Date.from_iso8601!(from)}, {:to, Date.from_iso8601!(to)}]

            {"from", from} ->
              [{:from, Date.from_iso8601!(from)}, {:to, nil}]

            {"to", to} ->
              [{:from, nil}, {:to, Date.from_iso8601!(to)}]

            {"tender", "false"} ->
              [{:tender, false}]

            other ->
              raise inspect(other)
          end)
          |> Map.new()

        %{String.to_atom(currency) => parsed_dates}
      end)

    %{territory => Cldr.Map.merge_map_list(currency_dates)}
  end

  @doc """
  Returns true if a `Gettext` module is configured in Cldr and
  the `Gettext` module is available.

  ## Example

      iex> test_config = TestBackend.Cldr.__cldr__(:config)
      iex> Cldr.Config.gettext_configured?(test_config)
      true

  """
  @spec gettext_configured?(t()) :: boolean
  def gettext_configured?(config) do
    gettext(config) && ensure_compiled?(Gettext) && ensure_compiled?(gettext(config))
  end

  @doc """
  Expands wildcards in locale names.

  Locales often have region variants (for example en-AU is one of 104
  variants in CLDR).  To make it easier to configure a language and all
  its variants, a locale can be specified as a regex which will
  then do a match against all CLDR locales.

  For locale names that have a Script or Vairant component the base
  language is also configured since plural rules will fall back to the
  language for these locale names.

  ## Examples

      iex> Cldr.Config.expand_locale_names(["en-A+"])
      ["en", "en-AE", "en-AG", "en-AI", "en-AS", "en-AT", "en-AU"]

      iex> Cldr.Config.expand_locale_names(["fr-*"])
      ["fr", "fr-BE", "fr-BF", "fr-BI", "fr-BJ", "fr-BL", "fr-CA", "fr-CD", "fr-CF",
       "fr-CG", "fr-CH", "fr-CI", "fr-CM", "fr-DJ", "fr-DZ", "fr-GA", "fr-GF",
       "fr-GN", "fr-GP", "fr-GQ", "fr-HT", "fr-KM", "fr-LU", "fr-MA", "fr-MC",
       "fr-MF", "fr-MG", "fr-ML", "fr-MQ", "fr-MR", "fr-MU", "fr-NC", "fr-NE",
       "fr-PF", "fr-PM", "fr-RE", "fr-RW", "fr-SC", "fr-SN", "fr-SY", "fr-TD",
       "fr-TG", "fr-TN", "fr-VU", "fr-WF", "fr-YT"]
  """
  @wildcard_matchers ["*", "+", ".", "["]
  @spec expand_locale_names([Locale.locale_name(), ...]) :: [Locale.locale_name(), ...]
  def expand_locale_names(locale_names) do
    Enum.map(locale_names, fn locale_name ->
      if String.contains?(locale_name, @wildcard_matchers) do
        case Regex.compile(locale_name) do
          {:ok, regex} ->
            Enum.filter(all_locale_names(), &Regex.match?(regex, &1))

          {:error, reason} ->
            raise ArgumentError,
                  "Invalid regex in locale name #{inspect(locale_name)}: #{inspect(reason)}"
        end
      else
        canonical_name(locale_name)
      end
    end)
    |> List.flatten()
    |> Enum.map(fn locale_name ->
      case String.split(locale_name, "-") do
        [language] -> language
        [language | _rest] -> [language, locale_name]
      end
    end)
    |> List.flatten()
    |> Enum.uniq()
  end

  def canonical_name(locale_name) do
    name =
      locale_name
      |> locale_name_from_posix
      |> String.downcase

    Map.get(known_locales_map(), name, locale_name)
  end

  defp known_locales_map do
    all_locale_names()
    |> Enum.map(fn x -> {String.downcase(x), x} end)
    |> Map.new
  end

  @doc """
  Returns the location of the json data for a locale or `nil`
  if the locale can't be found.

  * `locale` is any locale returned from `Cldr.known_locale_names/1`

  """
  @spec locale_path(String.t(), Cldr.backend() | t()) ::
          {:ok, String.t()} | {:error, :not_found}

  def locale_path(locale, %{data_dir: _} = config) do
    do_locale_path(locale, config)
  end

  def locale_path(locale, backend) when is_atom(backend) do
    do_locale_path(locale, backend.__cldr__(:config))
  end

  defp do_locale_path(locale, config) do
    relative_locale_path = ["locales/", "#{locale}.json"]
    client_path = Path.join(client_data_dir(config), relative_locale_path)
    cldr_path = Path.join(cldr_data_dir(), relative_locale_path)

    cond do
      File.exists?(client_path) -> {:ok, client_path}
      File.exists?(cldr_path) -> {:ok, cldr_path}
      true -> {:error, :not_found}
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
  @spec get_locale(Cldr.Locale.locale_name(), config_or_backend :: t() | Cldr.backend()) ::
          map() | no_return()

  def get_locale(locale, %{data_dir: _} = config) do
    do_get_locale(locale, config)
  end

  def get_locale(locale, backend) when is_atom(backend) do
    do_get_locale(locale, backend.__cldr__(:config))
  end

  def do_get_locale(locale, config) do
    {:ok, path} =
      case locale_path(locale, config) do
        {:ok, path} ->
          {:ok, path}

        {:error, :not_found} ->
          raise RuntimeError, message: "Locale definition was not found for #{locale}"
      end

    do_get_locale(locale, path, Cldr.Locale.Cache.compiling?())
  end

  @doc false
  @keys_to_integerize ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
  @dont_atomize_keys ["languages", "lenient_parse"]
  def do_get_locale(locale, path, false) do
    path
    |> read_locale_file
    |> json_library().decode!
    |> assert_valid_keys!(locale)
    |> structure_units
    |> atomize_keys(required_modules() -- @dont_atomize_keys, except: @keys_to_integerize)
    |> structure_rbnf
    |> atomize_number_systems
    |> atomize_languages
    |> structure_date_formats
    |> structure_list_formats
    |> Map.put(:name, locale)
  end

  @doc false
  def do_get_locale(locale, path, true) do
    Cldr.Locale.Cache.get_locale(locale, path)
  end

  # Read the file.
  defp read_locale_file(path) do
    Cldr.maybe_log("Cldr.Config reading locale file #{inspect path}")
    {:ok, file} = File.open(path, [:read, :binary, :utf8])
    contents = IO.read(file, :all)
    File.close(file)
    contents
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

  @doc """
  Returns a map of territory containers

  """
  def territory_containers do
    cldr_data_dir()
    |> Path.join("territory_containers.json")
    |> File.read!()
    |> json_library().decode!
    |> Cldr.Map.atomize_keys()
    |> Cldr.Map.atomize_values()
  end

  @doc """
  Returns a map of territory containment

  """
  def territory_containment do
    cldr_data_dir()
    |> Path.join("territory_containment.json")
    |> File.read!()
    |> json_library().decode!
    |> Cldr.Map.atomize_keys()
    |> Cldr.Map.atomize_values()
  end

  @doc """
  Return the territory subdivisions

  """
  def territory_subdivisions do
    cldr_data_dir()
    |> Path.join("territory_subdivisions.json")
    |> File.read!()
    |> json_library().decode!
  end

  @doc """
  Return a mapping between a subdivision and its
  containing parents

  """
  def territory_subdivision_containment do
    cldr_data_dir()
    |> Path.join("territory_subdivision_containment.json")
    |> File.read!()
    |> json_library().decode!
  end

  @doc """
  Returns a map of territory info for all territories
  known to CLDR.

  The territory information is independent of the
  `ex_cldr` configuration.

  ## Example

      iex> Cldr.Config.territories[:GB]
      %{
        currency: [GBP: %{from: ~D[1694-07-27]}],
        gdp: 2925000000000,
        language_population: %{
          "bn" => %{population_percent: 0.67},
          "cy" => %{official_status: "official_regional", population_percent: 0.77},
          "de" => %{population_percent: 6},
          "el" => %{population_percent: 0.33},
          "en" => %{official_status: "official", population_percent: 99},
          "fr" => %{population_percent: 19},
          "ga" => %{official_status: "official_regional", population_percent: 0.026},
          "gd" => %{official_status: "official_regional", population_percent: 0.099, writing_percent: 5},
          "it" => %{population_percent: 0.33},
          "ks" => %{population_percent: 0.19},
          "kw" => %{population_percent: 0.003},
          "ml" => %{population_percent: 0.035},
          "pa" => %{population_percent: 0.79},
          "sco" => %{population_percent: 2.7, writing_percent: 5},
          "syl" => %{population_percent: 0.51},
          "yi" => %{population_percent: 0.049},
          "zh-Hant" => %{population_percent: 0.54}
        },
        literacy_percent: 99,
        measurement_system: %{default: :uksystem, paper_size: :a4, temperature: :uksystem},
        population: 65761100
      }

  """
  def territories do
    cldr_data_dir()
    |> Path.join("territories.json")
    |> File.read!()
    |> json_library().decode!
    |> Cldr.Map.atomize_keys(
      except: fn
        {_k, %{population_percent: _}} -> true
        _other -> false
      end
    )
    |> Cldr.Map.atomize_values(only: [:default, :paper_size, :temperature])
    |> adjust_currency_codes
    |> Map.new()
  end

  @deprecated "Use Cldr.Config.territories/0"
  defdelegate territory_info, to: __MODULE__, as: :territories

  defp adjust_currency_codes(territories) do
    territories
    |> Enum.map(fn {territory, data} ->
      currencies =
        data
        |> Map.get(:currency)
        |> into_keyword_list
        |> Enum.map(fn {currency, data} ->
          data =
            if data[:tender] == "false" do
              Map.put(data, :tender, false)
            else
              data
            end

          data =
            if data[:from] do
              Map.put(data, :from, Date.from_iso8601!(data[:from]))
            else
              data
            end

          data =
            if data[:to] do
              Map.put(data, :to, Date.from_iso8601!(data[:to]))
            else
              data
            end

          {currency, data}
        end)

      {territory, Map.put(data, :currency, currencies)}
    end)
    |> Map.new()
  end

  defp into_keyword_list(list) do
    Enum.reduce(list, Keyword.new(), fn map, acc ->
      currency = Map.to_list(map) |> hd
      [currency | acc]
    end)
  end

  @doc """
  Get territory info for a specific territory.

  * `territory` is a string, atom or language_tag representation
    of a territory code in the list returned by `Cldr.known_territories`

  Returns:

  * A map of the territory information or
  * `{:error, reason}`

  ## Example

      iex> Cldr.Config.territory "au"
      %{
        currency: [AUD: %{from: ~D[1966-02-14]}],
        gdp: 1248000000000,
        language_population: %{
          "en" => %{official_status: "de_facto_official", population_percent: 96},
          "it" => %{population_percent: 1.9},
          "wbp" => %{population_percent: 0.0098},
          "zh-Hant" => %{population_percent: 2.1}
        },
        literacy_percent: 99,
        measurement_system: %{default: :metric, paper_size: :a4, temperature: :metric},
        population: 25466500
      }

      iex> Cldr.Config.territory "abc"
      {:error, {Cldr.UnknownTerritoryError, "The territory \\"abc\\" is unknown"}}

  """
  @spec territory(Cldr.territory() | String.t()) :: %{} | {:error, {module(), String.t()}}
  def territory(territory) do
    with {:ok, territory_code} <- Cldr.validate_territory(territory) do
      territories()
      |> Map.fetch!(territory_code)
    end
  end

  @deprecated "Use Cldr.Config.territories/1"
  defdelegate territory_info(territory), to: __MODULE__, as: :territory

  defp atomize_languages(content) do
    languages =
      content
      |> Map.get(:languages)
      |> Enum.map(fn {k, v} -> {k, Cldr.Map.atomize_keys(v)} end)
      |> Map.new()

    Map.put(content, :languages, languages)
  end

  @doc """
  Returns the map of aliases for languages,
  scripts and regions

  """
  def aliases do
    cldr_data_dir()
    |> Path.join("aliases.json")
    |> File.read!()
    |> json_library().decode!
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
    |> Map.new()
    |> Cldr.Map.atomize_keys(level: 1..1)
    |> Cldr.Map.deep_map(&Cldr.Map.atomize_keys/1, only: :region)
    |> Cldr.Map.deep_map(&Cldr.Map.atomize_values/1, only: :region)
    |> Map.new()
    |> structify_languages
  end

  defp structify_languages(map) do
    languages =
      Enum.map(map.language, fn {k, v} ->
        {k, struct(Cldr.LanguageTag, normalize_territory(v))}
      end)
      |> Map.new()

    Map.put(map, :language, languages)
  end

  @doc """
  Returns the likely subtags map which maps a
  locale string to %LaguageTag{} representing
  the likely subtags for that locale string

  """
  def likely_subtags do
    cldr_data_dir()
    |> Path.join("likely_subtags.json")
    |> File.read!()
    |> json_library().decode!
    |> Enum.map(fn {k, v} ->
      {k, struct(Cldr.LanguageTag, normalize_territory(v))}
    end)
    |> Map.new()
  end

  defp normalize_territory(map) do
    map
    |> Cldr.Map.atomize_keys()
    |> Cldr.Map.atomize_values(only: :territory)
  end

  @doc """
  Returns the data that defines start and end of
  calendar weeks, weekends and years

  """
  def weeks do
    cldr_data_dir()
    |> Path.join("weeks.json")
    |> File.read!()
    |> json_library().decode!
    |> Map.take(["weekend_start", "min_days", "first_day", "weekend_end"])
    |> Cldr.Map.atomize_keys()
  end

  @deprecated "Use Cldr.Config.weeks/0"
  defdelegate week_info(), to: __MODULE__, as: :weeks

  @doc """
  Returns the data that defines time periods of
  a day for a language.

  Time period rules are used to define the meaning
  of "morning", "evening", "noon", "midnight" and
  potentially other periods on a per-language basis.

  ## Example

      iex> Cldr.Config.day_period_info |> Map.get("fr")
      %{"afternoon1" => %{"before" => [18, 0], "from" => [12, 0]},
        "evening1" => %{"before" => [24, 0], "from" => [18, 0]},
        "midnight" => %{"at" => [0, 0]},
        "morning1" => %{"before" => [12, 0], "from" => [4, 0]},
        "night1" => %{"before" => [4, 0], "from" => [0, 0]},
        "noon" => %{"at" => [12, 0]}}

  """
  def day_period_info do
    cldr_data_dir()
    |> Path.join("day_periods.json")
    |> File.read!()
    |> json_library().decode!
  end

  @doc """
  Returns the data that defines start and end of
  calendar epochs.

  ## Example

      iex> Cldr.Config.calendars |> Map.get(:gregorian)
      %{calendar_system: "solar", eras: %{0 => %{end: 0}, 1 => %{start: 1}}}

  """
  def calendars do
    cldr_data_dir()
    |> Path.join("calendars.json")
    |> File.read!()
    |> json_library().decode!
    |> Cldr.Map.atomize_keys(except: &Regex.match?(~r/[0-9]+/, elem(&1, 0)))
    |> Cldr.Map.integerize_keys()
    |> add_era_end_dates
  end

  @deprecated "Use Cldr.Config.calendars/0"
  defdelegate calendar_data, to: __MODULE__, as: :calendars

  @doc """
  Returns unit conversion data,

  ## Example

      iex> Cldr.Config.units |> get_in([:conversions, :quart])
      %{
        base_unit: :cubic_meter,
        factor: %{
          denominator: 13469199089641601294165159418313264309149074316066816,
          numerator: 12746616238742849396626455585282990375683527307233
        },
        offset: 0,
        systems: [:ussystem]
      }

  """
  @units_file "units.json"
  def units do
    data =
      cldr_data_dir()
      |> Path.join(@units_file)
      |> File.read!()
      |> json_library().decode!(keys: :atoms)

    base_units =
      data.base_units
      |> Cldr.Map.atomize_keys()
      |> Cldr.Map.atomize_values()
      |> Enum.map(&List.to_tuple/1)

    conversions =
      data.conversions
      |> Enum.map(fn {k, v} ->
        new_unit =
          v
          |> Map.update!(:base_unit, fn current_value ->
            String.to_atom(current_value)
          end)
          |> Map.update!(:systems, fn current_value ->
            Enum.map(current_value, &String.to_atom/1)
          end)

        {k, new_unit}
      end)

    preferences =
      data.preferences
      |> Enum.map(fn {category, cat_prefs} ->
        new_cat_prefs =
          Enum.map(cat_prefs, fn {type, list} ->
            new_list =
              Enum.map(list, fn pref ->
                regions = Map.get(pref, :regions) |> Enum.map(&String.to_atom/1)
                geq = Map.get(pref, :geq) |> set_default(1.0)
                skeleton = Map.get(pref, :skeleton) |> set_skeleton()
                units = Map.get(pref, :units) |> Cldr.Map.atomize_values()
                %{regions: regions, geq: geq, skeleton: skeleton, units: units}
              end)

            {type, new_list}
          end)
          |> Map.new()

        {category, new_cat_prefs}
      end)
      |> Map.new()

    aliases =
      data.aliases
      |> Enum.map(fn {k, v} -> {k, String.to_atom(v)} end)
      |> Map.new()

    data
    |> Map.put(:conversions, conversions)
    |> Map.put(:base_units, base_units)
    |> Map.put(:aliases, aliases)
    |> Map.put(:preferences, preferences)
    |> Cldr.Map.atomize_keys()
  end

  defp set_default(nil, default), do: default
  defp set_default(value, _default), do: value

  # TODO Review with each CLDR release
  # Note that this assume there is only one option provided
  # which in the initial realease is true but may not be
  # later
  defp set_skeleton([""]),
    do: []

  defp set_skeleton(["precision_increment", value]), do: [round_nearest: String.to_integer(value)]

  defp set_skeleton([key, value]),
    do: [{String.to_atom(key), String.to_integer(value)}]

  #######################################################################

  # TODO Remove for ex_cldr version 3.0
  # TODO Remove the supporting files too

  @doc false
  @unit_preference_file "deprecated/unit_preference.json"
  def unit_preferences do
    Path.join(cldr_data_dir(), @unit_preference_file)
    |> File.read!()
    |> json_library().decode!
    |> Cldr.Map.atomize_keys()
    |> Enum.map(fn {k, v} -> {k, Cldr.Map.atomize_values(v)} end)
    |> Map.new()
  end

  @doc false
  @measurement_system_file "deprecated/measurement_system.json"
  def measurement_system do
    Path.join(cldr_data_dir(), @measurement_system_file)
    |> File.read!()
    |> json_library().decode!
    |> Cldr.Map.atomize_keys()
    |> Enum.map(fn {k, v} -> {k, Cldr.Map.atomize_values(v)} end)
    |> Map.new()
  end

  #######################################################################

  @doc """
  Return the map of calendar preferences by territory

  """
  @calendar_preferences_file "calendar_preferences.json"
  def calendar_preferences do
    cldr_data_dir()
    |> Path.join(@calendar_preferences_file)
    |> File.read!()
    |> json_library().decode!(keys: :atoms)
    |> Cldr.Map.atomize_values()
  end

  @doc """
  Returns the calendars available for a given locale name

  ## Example

      iex> Cldr.Config.calendars_for_locale "en", TestBackend.Cldr
      [:buddhist, :chinese, :coptic, :dangi, :ethiopic, :ethiopic_amete_alem,
       :generic, :gregorian, :hebrew, :indian, :islamic, :islamic_civil,
       :islamic_rgsa, :islamic_tbla, :islamic_umalqura, :japanese, :persian, :roc]

  """
  def calendars_for_locale(locale_name, %{} = config) when is_binary(locale_name) do
    locale_name
    |> get_locale(config)
    |> Map.get(:dates)
    |> Map.get(:calendars)
    |> Map.keys()
  end

  def calendars_for_locale(locale_name, backend) when is_atom(backend) do
    calendars_for_locale(locale_name, backend.__cldr__(:config))
  end

  def calendars_for_locale(%{} = locale_data, %{} = _config) do
    locale_data
    |> Map.get(:dates)
    |> Map.get(:calendars)
    |> Map.keys()
  end

  defp add_era_end_dates(calendars) do
    Enum.map(calendars, fn {calendar, content} ->
      new_content =
        Enum.map(content, fn
          {:eras, eras} -> {:eras, add_end_dates(eras)}
          {k, v} -> {k, v}
        end)
        |> Enum.into(%{})

      {calendar, new_content}
    end)
    |> Enum.into(%{})
  end

  defp add_end_dates(%{} = eras) do
    eras
    |> Enum.sort_by(fn {k, _v} -> k end, fn a, b -> a < b end)
    |> add_end_dates
    |> Enum.into(%{})
  end

  defp add_end_dates([{_, %{start: _start_1}} = era_1, {_, %{start: start_2}} = era_2]) do
    {era, dates} = era_1
    [{era, Map.put(dates, :end, start_2 - 1)}, era_2]
  end

  defp add_end_dates([{_, %{start: _start_1}} = era_1 | [{_, %{start: start_2}} | _] = tail]) do
    {era, dates} = era_1
    [{era, Map.put(dates, :end, start_2 - 1)}] ++ add_end_dates(tail)
  end

  defp add_end_dates(other) do
    other
  end

  @doc """
  Get the configured number formats that should be precompiled at application
  compilation time.

  """
  def get_precompile_number_formats(config) do
    Map.get(config, :precompile_number_formats, [])
  end

  # Extract number formats from short and long lists
  @doc false
  def extract_formats(formats) when is_map(formats) do
    formats
    |> Map.values()
    |> Enum.map(&hd/1)
  end

  @doc false
  def extract_formats(format) do
    format
  end

  @doc false
  def decimal_format_list(config) do
    config
    |> known_locale_names
    |> Enum.map(&decimal_formats_for(&1, config))
    |> Kernel.++(get_precompile_number_formats(config))
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.reject(&is_nil/1)
    |> Enum.sort()
  end

  @doc false
  def decimal_formats_for(locale, config) do
    locale
    |> get_locale(config)
    |> Map.get(:number_formats)
    |> Map.values()
    |> Enum.map(&Map.delete(&1, :currency_spacing))
    |> Enum.map(&Map.delete(&1, :currency_long))
    |> Enum.map(&Map.delete(&1, :other))
    |> Enum.map(&Map.values/1)
    |> List.flatten()
    |> Enum.reject(&is_integer/1)
    |> Enum.map(&extract_formats/1)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc false
  def number_systems do
    cldr_data_dir()
    |> Path.join("number_systems.json")
    |> File.read!()
    |> json_library().decode!
    |> Cldr.Map.atomize_keys()
    |> Enum.map(fn {k, v} -> {k, %{v | type: String.to_atom(v.type)}} end)
    |> Map.new
  end

  @doc false
  def time_preferences do
    cldr_data_dir()
    |> Path.join("time_preferences.json")
    |> File.read!()
    |> json_library().decode!
    |> Cldr.Map.atomize_keys(only: fn
        {k, _v} -> not String.contains?(k, "_")
        _ -> false
    end)
    |> Cldr.Map.deep_map(fn
      {k, v} when is_binary(k) -> {String.replace(k, "_", "-"), v}
      other -> other
    end)
  end

  @doc false
  def rbnf_rule_function(rule_name, backend) do
    case String.split(rule_name, "/") do
      [locale_name, ruleset, rule] ->
        ruleset_module =
          ruleset
          |> String.trim_trailing("Rules")

        function =
          rule
          |> locale_name_to_posix
          |> String.to_atom()

        locale_name =
          locale_name
          |> locale_name_from_posix

        module = Module.concat(backend, Rbnf) |> Module.concat(ruleset_module)
        {module, function, locale_name}

      [rule] ->
        function =
          rule
          |> locale_name_to_posix
          |> String.to_atom()

        {Module.concat(backend, Rbnf.NumberSystem), function, "root"}
    end
  end

  @doc """
  Transforms a locale name from the Posix format to the Cldr format

  """
  def locale_name_from_posix(nil), do: nil
  def locale_name_from_posix(name) when is_binary(name), do: String.replace(name, "_", "-")

  @doc """
  Transforms a locale name from the CLDR format to the Posix format

  """
  def locale_name_to_posix(nil), do: nil
  def locale_name_to_posix(name) when is_binary(name), do: Cldr.String.to_underscore(name)

  @doc false
  def structify(map, module) do
    struct(module, map)
  end

  # ------ Helpers ------

  # Simple check that the locale content contains what we expect
  # by checking it has the keys we used when the locale was consolidated.

  # Set the environment variable DEV to bypass this check. That is
  # only required if adding new content modules to a locale - which is
  # an uncommon activity.

  defp assert_valid_keys!(content, locale) do
    for module <- required_modules() do
      if !Map.has_key?(content, module) and !:"Elixir.System".get_env("DEV") do
        raise RuntimeError,
          message:
            "Locale file #{inspect(locale)} is invalid - map key #{inspect(module)} was not found."
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

  """
  @spec required_modules :: [String.t()]
  def required_modules do
    @cldr_modules
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

  defp structure_date_formats(content) do
    dates =
      content.dates
      |> Cldr.Map.integerize_keys(only: @keys_to_integerize)

    Map.put(content, :dates, dates)
  end

  defp structure_list_formats(content) do
    dates =
      content.list_formats
      |> Cldr.Map.atomize_keys()

    Map.put(content, :list_formats, dates)
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

  @doc false
  # Since this uses Mix it is only valid at compile
  # time
  def config_from_opts(module_config) do
    config =
      global_config()
      |> Keyword.merge(otp_config(module_config))
      |> Keyword.merge(module_config)
      |> Map.new()

    config =
      config
      |> Map.put(:default_locale, default_locale_name(config))
      |> Map.put(:data_dir, client_data_dir(config))
      |> merge_locales_with_default
      |> remove_gettext_only_locales()
      |> sort_locales
      |> dedup_provider_modules

    struct(__MODULE__, config)
  end

  defp sort_locales(%{locales: :all} = config) do
    config
  end

  defp sort_locales(%{locales: locales} = config) do
    %{config | locales: Enum.sort(locales)}
  end

  # If a locale comes from Gettext but has no CLDR counterpart
  # then omit it with a warning (but don't raise)
  defp remove_gettext_only_locales(%{gettext: nil} = config) do
    config
  end

  defp remove_gettext_only_locales(%{locales: locales, gettext: gettext} = config) do
    gettext_locales = known_gettext_locale_names(config)
    unknown_locales = Enum.filter(gettext_locales, &(&1 not in all_locale_names()))

    case unknown_locales do
      [] ->
        config

      [unknown_locale] ->
        IO.warn(
          "The locale #{inspect unknown_locale} is configured in the #{gettext} " <>
          "gettext backend but is unknown to CLDR. It will be ignored by CLDR.", []
        )
        Map.put(config, :locales, locales -- [unknown_locale])

      unknown_locales ->
        IO.warn(
          "The locales #{inspect unknown_locales} are configured in the #{gettext} " <>
          "gettext backend but are unknown to CLDR. They will be ignored by CLDR.", []
        )
        Map.put(config, :locales, locales -- unknown_locales)
    end
  end

  defp remove_gettext_only_locales(config) do
    config
  end

  @doc false
  def dedup_provider_modules(%{providers: []} = config) do
    config
  end

  def dedup_provider_modules(%{providers: providers, backend: backend} = config) do
    groups = Enum.group_by(providers, &(&1))
    config = Map.put(config, :providers, Map.keys(groups))
    duplicates =
      groups
      |> Enum.filter(fn {_k, v} -> length(v) > 1 end)
      |> Enum.map(&elem(&1, 0))

    if length(duplicates) > 0 do
      IO.warn(
        "Duplicate Cldr backend providers #{inspect providers} for " <>
        "backend #{inspect backend} have been ignored", []
      )
    end

    config
  end

  def dedup_provider_modules(config) do
    config
  end

  # Returns the AST of any configured plugins
  @doc false
  def define_provider_modules(config) do
    for {module, function, args} <- Cldr.Config.Dependents.cldr_provider_modules(config) do
      if Code.ensure_loaded?(module) && function_exported?(module, function, 1) do
        apply(module, function, args)
      else
        log_provider_warning(module, function, args, config)
      end
    end
  end

  defp log_provider_warning(module, function, args, %{supress_warnings: false} = config) do
    require Logger

    cond do
      !Code.ensure_loaded?(module) ->
        Logger.warn(
          "#{inspect(config.backend)}: The CLDR provider module #{inspect(module)} " <>
            "was not found"
        )

      !function_exported?(module, function, 1) ->
        Logger.warn(
          "#{inspect(config.backend)}: The CLDR provider module #{inspect(module)} " <>
            "does not implement the function #{function}/#{length(args)}"
        )

      true ->
        Logger.warn(
          "#{inspect(config.backend)}: Could not execute the CLDR provider " <>
            "#{inspect(module)}.#{function}/#{length(args)}"
        )
    end
  end

  defp log_provider_warning(_module, _function, _args, %{supress_warnings: true}) do
    :ok
  end

  @doc false
  def loaded_apps do
    Application.loaded_applications()
    |> Enum.map(&elem(&1, 0))
    |> Kernel.++([Mix.Project.config()[:app]])
  end

  def raise_if_otp_app_not_loaded!(config) do
    if config[:otp_app] && config[:otp_app] not in loaded_apps() do
      raise ArgumentError, "The :otp_app #{inspect(config[:otp_app])} is not known"
    end
  end

  @doc false
  def global_config do
    Application.get_all_env(app_name())
    |> Keyword.delete(:otp_app)
  end

  @doc false
  def otp_config(config) do
    if otp_app = config[:otp_app] do
      raise_if_otp_app_not_loaded!(config)

      Application.get_env(otp_app, config[:backend], [])
      |> Keyword.delete(:otp_app)
    else
      []
    end
  end

  @non_deprecated_keys [
    :json_library,
    :default_locale,
    :default_backend,
    :cacertfile,
    :data_dir,
    :force_locale_download
  ]

  @doc false
  def maybe_deprecate_global_config! do
    remaining_config =
      global_config()
      |> Enum.reject(&(elem(&1, 0) in @non_deprecated_keys))
      |> Keyword.delete(:_default_locale)
      |> Enum.map(&elem(&1, 0))

    if length(remaining_config) > 0 do
      IO.warn(
        "Using the global configuration is deprecated.  Global configuration " <>
          "only supports the #{inspect(@non_deprecated_keys)} keys. The keys " <>
          "#{inspect(remaining_config)} should be configured in a backend module or " <>
          "via the :otp_app configuration of a backend module.  See the readme for " <>
          "further information.", []
      )
    end
  end

  @root_locale "root"
  def merge_locales_with_default(%{locales: :all} = config) do
    config
  end

  def merge_locales_with_default(config) do
    gettext = known_gettext_locale_names(config)
    locales = config[:locales] || [config[:default_locale] || @default_locale_name]
    default = config[:default_locale] || hd(locales)

    locales =
      (locales ++ gettext ++ [default, @root_locale])
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()
      |> Enum.map(&canonical_name/1)

    Map.put(config, :locales, locales)
  end

  def normalize_plural_rules(rules) do
    Enum.map(rules, &normalize_rules_for_locale/1)
  end

  defp normalize_rules_for_locale({locale, rules}) do
    sorted_rules =
      Enum.map(rules, fn {"pluralRule-count-" <> category, rule} ->
        {:ok, definition} = Cldr.Number.PluralRule.Compiler.parse(rule)
        {String.to_atom(category), definition}
      end)
      |> Enum.sort(&plural_sorter/2)

    {locale, sorted_rules}
  end

  defp plural_sorter({:zero, _}, _), do: true
  defp plural_sorter({:one, _}, {other, _}) when other in [:two, :few, :many, :other], do: true
  defp plural_sorter({:two, _}, {other, _}) when other in [:few, :many, :other], do: true
  defp plural_sorter({:few, _}, {other, _}) when other in [:many, :other], do: true
  defp plural_sorter({:many, _}, {other, _}) when other in [:other], do: true
  defp plural_sorter(_, _), do: false

  @doc false
  def ensure_compiled?(module) do
    case Code.ensure_compiled(module) do
      {:module, _} -> true
      {:error, _} -> false
    end
  end
end
