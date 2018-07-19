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
    "languages"
  ]

  defmacro is_alphabetic(char) do
    quote do
      unquote(char) in ?a..?z or unquote(char) in ?A..?Z
    end
  end

  # Check that the :cldr compiler is the last in the compiler list
  # if it is configured
  if :cldr in Mix.Project.config()[:compilers] and
       hd(Enum.reverse(Mix.Project.config()[:compilers])) != :cldr do
    raise ArgumentError,
          "If configured, the :cldr compiler must be the last compiler in the list. " <>
            "Found #{inspect(Mix.Project.config()[:compilers])}"
  end

  @doc """
  Return the configured json lib
  """
  Module.put_attribute(
    __MODULE__,
    :poison,
    case Code.ensure_loaded(Poison) do
      {:module, _} -> Poison
      _ -> nil
    end
  )

  Module.put_attribute(
    __MODULE__,
    :jason,
    case Code.ensure_loaded(Jason) do
      {:module, _} -> Jason
      _ -> nil
    end
  )

  @app_name Mix.Project.config()[:app]
  def app_name do
    @app_name
  end

  # Prefer Jason if its confiured over Poison
  @json_lib Application.get_env(@app_name, :json_library) || @jason || @poison

  unless Code.ensure_loaded?(@json_lib) && function_exported?(@json_lib, :decode!, 1) do
    message =
      if is_nil(@json_lib) do
        """
         A json library has not been configured.  Please configure one in
         your `mix.exs` file.  Two common packages are Poison and Jason.
         For example in your `mix.exs`:

           def deps() do
             [
               {:jason, "~> 1.0"},
               ...
             ]
           end
        """
      else
        """
        The json library #{inspect(@json_lib)} is either
        not configured or does not define the function decode!/1
        """
      end

    raise ArgumentError, message
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
  Return the directory where `Cldr` stores its source core data,  This
  directory should not be expected to be available other than when developing
  Cldr since it points to a source directory.
  """
  @cldr_relative_dir "/priv/cldr"
  def source_data_dir do
    Path.join(cldr_home(), @cldr_relative_dir)
  end

  @doc """
  Returns the path of the CLDR data directory for the ex_cldr app
  """
  def cldr_data_dir do
    [:code.priv_dir(app_name()), "/cldr"] |> :erlang.iolist_to_binary()
  end

  @doc """
  Return the path name of the CLDR data directory for a client application.
  """
  def client_data_dir do
    Application.get_env(app_name(), :data_dir, cldr_data_dir())
    |> Path.expand()
  end

  @doc """
  Returns the directory where the CLDR locales files are located.
  """
  def client_locales_dir do
    Path.join(client_data_dir(), "locales")
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
    Path.join(Cldr.Config.cldr_home(), "data")
  end

  @doc """
  Return the configured `Gettext` module name or `nil`.
  """
  @spec gettext :: atom
  def gettext do
    Application.get_env(app_name(), :gettext)
  end

  @doc """
  Return the default locale.

  In order of priority return either:

  * The default locale specified in the `mix.exs` file
  * The `Gettext.get_locale/1` for the current configuration
  * "en"
  """
  @spec default_locale :: Locale.locale_name()
  def default_locale do
    app_default = Application.get_env(app_name(), :default_locale)

    cond do
      app_default ->
        app_default

      gettext_configured?() ->
        Gettext
        |> apply(:get_locale, [gettext()])
        |> locale_name_from_posix()

      true ->
        @default_locale
    end
  end

  @doc """
  Return a list of the locales defined in `Gettext`.

  Return a list of locales configured in `Gettext` or
  `[]` if `Gettext` is not configured.
  """
  @spec gettext_locales :: [Locale.locale_name()]
  def gettext_locales do
    if gettext_configured?() && Application.ensure_all_started(:gettext) do
      otp_app = gettext().__gettext__(:otp_app)

      backend_default =
        otp_app
        |> Application.get_env(gettext())
        |> gettext_default_locale

      global_default = Application.get_env(:gettext, :default_locale)

      locales = apply(Gettext, :known_locales, [gettext()]) ++ [backend_default, global_default]

      locales
      |> Enum.reject(&is_nil/1)
      |> Enum.map(&locale_name_from_posix/1)
      |> Enum.uniq()
      |> Enum.sort()
    else
      []
    end
  end

  defp gettext_default_locale(nil) do
    nil
  end

  defp gettext_default_locale(gettext_config) do
    Keyword.get(gettext_config, :default_locale)
  end

  @doc """
  Returns a list of all locales in the CLDR repository.

  Returns a list of the complete locales list in CLDR, irrespective
  of whether they are configured for use in the application.

  Any configured locales that are not present in this list will
  raise an exception at compile time.
  """
  @spec all_locale_names :: [Locale.locale_name(), ...]
  def all_locale_names do
    Path.join(cldr_data_dir(), "available_locales.json")
    |> File.read!()
    |> json_library().decode!
    |> Enum.sort()
  end

  @doc """
  Returns the map of language tags for all
  available locales
  """
  def all_language_tags do
    Path.join(cldr_data_dir(), "language_tags.ebin")
    |> File.read!()
    |> :erlang.binary_to_term()
  end

  @doc """
  Return the saved language tag for the
  given locale name
  """
  def language_tag(locale_name) do
    Map.get(all_language_tags(), locale_name)
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

  The use of `:all` is not recommended since all 523 locales take
  quite some time (minutes) to compile. It is however
  helpful for testing Cldr.
  """
  @spec configured_locale_names :: [Locale.locale_name()]
  def configured_locale_names do
    locale_names =
      case app_locale_names = Application.get_env(app_name(), :locales) do
        :all -> all_locale_names()
        nil -> expand_locale_names([default_locale()])
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
  @spec known_locale_names :: [Locale.locale_name()]
  def known_locale_names do
    requested_locale_names()
    |> MapSet.new()
    |> MapSet.intersection(MapSet.new(all_locale_names()))
    |> MapSet.to_list()
    |> Enum.sort()
  end

  def known_rbnf_locale_names do
    known_locale_names()
    |> Enum.filter(fn locale -> Map.get(get_locale(locale), :rbnf) != %{} end)
  end

  def known_locale_name(locale_name) do
    if locale_name in known_locale_names() do
      locale_name
    else
      false
    end
  end

  def known_rbnf_locale_name(locale_name) do
    if locale_name in known_rbnf_locale_names() do
      locale_name
    else
      false
    end
  end

  @doc """
  Returns a list of all locales that are configured but not available
  in the CLDR repository.
  """
  @spec unknown_locale_names :: [Locale.locale_name()]
  def unknown_locale_names do
    requested_locale_names()
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
  @spec requested_locale_names :: [Locale.locale_name()]
  def requested_locale_names do
    (configured_locale_names() ++ gettext_locales() ++ [default_locale()])
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
    calendar_info() |> Map.keys() |> Enum.sort()
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
       :SVC, :RON, :BEC, :CUP, :USN, :LBP, :BOP, :BHD, :BAN, :MDC, :VUV, :MGA, :ISK,
       :COP, :BYN, :UAK, :TRL, :SCR, :KRO, :ILS, :ETB, :CAD, :AZN, :VNN, :NIO, :COU,
       :EEK, :KYD, :MNT, :HNL, :WST, :PEI, :YER, :MTL, :STN, :AFA, :ARM, :HKD, :NZD,
       :UYI, :MXV, :GTQ, :BYB, :XXX, :XSU, :HRK, :OMR, :BEL, :MUR, :ESP, :YDD, :MVR,
       :LKR, :XAF]

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
       :cakm, :cham, :cyrl, :deva, :ethi, :fullwide, :geor, :gonm, :grek, :greklow,
       :gujr, :guru, :hanidays, :hanidec, :hans, :hansfin, :hant, :hantfin, :hebr,
       :hmng, :java, :jpan, :jpanfin, :kali, :khmr, :knda, :lana, :lanatham, :laoo,
       :latn, :lepc, :limb, :mathbold, :mathdbl, :mathmono, :mathsanb, :mathsans,
       :mlym, :modi, :mong, :mroo, :mtei, :mymr, :mymrshan, :mymrtlng, :newa, :nkoo,
       :olck, :orya, :osma, :roman, :romanlow, :saur, :shrd, :sind, :sinh, :sora,
       :sund, :takr, :talu, :taml, :tamldec, :telu, :thai, :tibt, :tirh, :vaii, :wara]

  """
  def known_number_systems do
    number_systems() |> Map.keys() |> Enum.sort()
  end

  @max_concurrency System.schedulers_online() * 2
  def known_number_system_types do
    known_locale_names()
    |> Task.async_stream(__MODULE__, :number_systems_for, [], max_concurrency: @max_concurrency)
    |> Enum.to_list()
    |> Enum.flat_map(&elem(&1, 1))
    |> Enum.uniq()
    |> Enum.sort()
  end

  def number_systems_for(locale_name) do
    locale_name
    |> get_locale
    |> Map.get(:number_systems)
    |> Enum.map(&elem(&1, 0))
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
    |> Enum.map(fn {k, v} -> [k, v] end)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.sort()
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

  For locale names that have a Script or Vairant component the base
  language is also configured since plural rules will fall back to the
  language for these locale names.

  ## Examples

      iex> Cldr.Config.expand_locale_names(["en-A+"])
      ["en", "en-AG", "en-AI", "en-AS", "en-AT", "en-AU"]

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
        locale_name
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

  @doc """
  Returns the location of the json data for a locale or `nil`
  if the locale can't be found.

  * `locale` is any locale returned from `Cldr.known_locale_names()`
  """
  @spec locale_path(String.t()) :: {:ok, String.t()} | {:error, :not_found}
  def locale_path(locale) do
    relative_locale_path = ["locales/", "#{locale}.json"]
    client_path = Path.join(client_data_dir(), relative_locale_path)
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
  def get_locale(locale) do
    {:ok, path} =
      case locale_path(locale) do
        {:ok, path} ->
          {:ok, path}

        {:error, :not_found} ->
          raise RuntimeError, message: "Locale definition was not found for #{locale}"

        error ->
          raise RuntimeError,
            message: "Unexpected return from locale_path(#{inspect(locale)}) => #{inspect(error)}"
      end

    do_get_locale(locale, path, Cldr.Locale.Cache.compiling?())
  end

  @doc false
  def do_get_locale(locale, path, compiling? \\ false)

  def do_get_locale(locale, path, false) do
    path
    |> File.read!()
    |> json_library().decode!
    |> assert_valid_keys!(locale)
    |> structure_units
    |> atomize_keys(required_modules() -- ["languages"])
    |> structure_rbnf
    |> atomize_number_systems
    |> atomize_languages
    |> structure_date_formats
    |> Map.put(:name, locale)
  end

  @doc false
  def do_get_locale(locale, path, true) do
    Cldr.Locale.Cache.get_locale(locale, path)
  end

  defp atomize_keys(content, modules) do
    Enum.map(content, fn {module, values} ->
      if module in modules do
        {String.to_atom(module), Cldr.Map.atomize_keys(values)}
      else
        {String.to_atom(module), values}
      end
    end)
    |> Enum.into(%{})
  end

  @doc """
  Returns a map of territory containments
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
  Returns a map of territory info for all territories
  known to CLDR.

  The territory information is independent of the
  `ex_cldr` configuration.

  ## Example

      iex> Cldr.Config.territory_info[:GB]
      %{
        currency: [GBP: %{from: ~D[1694-07-27]}],
        gdp: 2788000000000,
        language_population: %{
          "bn" => %{population_percent: 0.67},
          "cy" => %{
            official_status: "official_regional",
            population_percent: 0.77
          },
          "de" => %{population_percent: 6},
          "el" => %{population_percent: 0.34},
          "en" => %{official_status: "official", population_percent: 99},
          "fr" => %{population_percent: 19},
          "ga" => %{
            official_status: "official_regional",
            population_percent: 0.026
          },
          "gd" => %{
            official_status: "official_regional",
            population_percent: 0.099,
            writing_percent: 5
          },
          "it" => %{population_percent: 0.34},
          "ks" => %{population_percent: 0.19},
          "kw" => %{population_percent: 0.0031},
          "ml" => %{population_percent: 0.035},
          "pa" => %{population_percent: 0.79},
          "sco" => %{population_percent: 2.7, writing_percent: 5},
          "syl" => %{population_percent: 0.51},
          "yi" => %{population_percent: 0.049},
          "zh-Hant" => %{population_percent: 0.54}
        },
        literacy_percent: 99,
        measurement_system: "UK",
        paper_size: "A4",
        population: 64769500,
        telephone_country_code: 44,
        temperature_measurement: "metric"
      }

  """
  def territory_info do
    cldr_data_dir()
    |> Path.join("territory_info.json")
    |> File.read!()
    |> json_library().decode!
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
    |> atomize_territory_keys
    |> adjust_currency_codes
    |> atomize_language_population
    |> Enum.into(%{})
  end

  @doc """
  Get territory info for a specific territory.

  * `territory` is a string, atom or language_tag representation
    of a territory code in the list returned by `Cldr.known_territories`

  Returns:

  * A map of the territory information or
  * `{:error, reason}`

  ## Example

      iex> Cldr.Config.territory_info "au"
      %{
        currency: [AUD: %{from: ~D[1966-02-14]}],
        gdp: 1189000000000,
        language_population: %{
          "en" => %{
            official_status: "de_facto_official",
            population_percent: 96
          },
          "it" => %{population_percent: 1.9},
          "wbp" => %{population_percent: 0.011},
          "zh-Hant" => %{population_percent: 2.1}
        },
        literacy_percent: 99,
        measurement_system: "metric",
        paper_size: "A4",
        population: 23232400,
        telephone_country_code: 61,
        temperature_measurement: "metric"
      }

      iex> Cldr.Config.territory_info "abc"
      {:error, {Cldr.UnknownTerritoryError, "The territory \\"abc\\" is unknown"}}

  """
  @spec territory_info(String.t() | atom() | LanguageTag.t()) ::
          %{} | {:error, {Exception.t(), String.t()}}
  def territory_info(territory) do
    with {:ok, territory_code} <- Cldr.validate_territory(territory) do
      territory_info()
      |> Map.get(territory_code)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp atomize_territory_keys(territories) do
    territories
    |> Enum.map(fn {k, v} ->
      {k, Enum.map(v, fn {k1, v1} -> {String.to_atom(k1), v1} end) |> Enum.into(%{})}
    end)
    |> Enum.into(%{})
  end

  defp atomize_languages(content) do
    languages =
      content
      |> Map.get(:languages)
      |> Enum.map(fn {k, v} -> {k, Cldr.Map.atomize_keys(v)} end)
      |> Enum.into(%{})

    Map.put(content, :languages, languages)
  end

  defp adjust_currency_codes(territories) do
    territories
    |> Enum.map(fn {territory, data} ->
      currencies =
        data
        |> Map.get(:currency)
        |> Cldr.Map.atomize_keys()
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
    |> Enum.into(%{})
  end

  defp into_keyword_list(list) do
    Enum.reduce(list, Keyword.new(), fn map, acc ->
      currency = Map.to_list(map) |> hd
      [currency | acc]
    end)
  end

  defp atomize_language_population(territories) do
    territories
    |> Enum.map(fn {territory, data} ->
      languages =
        data
        |> Map.get(:language_population)
        |> atomize_language_keys
        |> Enum.into(%{})

      {territory, Map.put(data, :language_population, languages)}
    end)
    |> Enum.into(%{})
  end

  defp atomize_language_keys(nil), do: []

  defp atomize_language_keys(lang) do
    Enum.map(lang, fn {language, values} -> {language, Cldr.Map.atomize_keys(values)} end)
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
    |> Enum.into(%{})
    |> structify_languages
  end

  defp structify_languages(map) do
    languages =
      Enum.map(map.language, fn {k, v} ->
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
    cldr_data_dir()
    |> Path.join("likely_subtags.json")
    |> File.read!()
    |> json_library().decode!
    |> Enum.map(fn {k, v} -> {k, struct(Cldr.LanguageTag, Cldr.Map.atomize_keys(v))} end)
    |> Enum.into(%{})
  end

  @doc """
  Returns the data that defines start and end of
  calendar weeks, weekends and years
  """
  def week_info do
    cldr_data_dir()
    |> Path.join("week_data.json")
    |> File.read!()
    |> json_library().decode!
    |> Cldr.Map.underscore_keys()
    |> Enum.map(&upcase_territory_codes/1)
    |> Enum.into(%{})
    |> Cldr.Map.atomize_keys()
    |> Cldr.Map.integerize_values()
    |> Map.take([:weekend_start, :weekend_end, :min_days, :first_day])
  end

  defp upcase_territory_codes({k, content}) do
    content =
      content
      |> Enum.map(fn {territory, rest} -> {String.upcase(territory), rest} end)
      |> Enum.into(%{})

    {k, content}
  end

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

      iex> Cldr.Config.calendar_info |> Map.get(:gregorian)
      %{calendar_system: "solar", eras: %{0 => %{end: 0}, 1 => %{start: 1}}}

  """
  def calendar_info do
    cldr_data_dir()
    |> Path.join("calendar_data.json")
    |> File.read!()
    |> json_library().decode!
    |> Cldr.Map.atomize_keys()
    |> Cldr.Map.integerize_keys()
    |> add_era_end_dates
  end

  @doc """
  Returns the calendars available for a given locale name

  ## Example

      iex> Cldr.Config.calendars_for_locale "en"
      [:buddhist, :chinese, :coptic, :dangi, :ethiopic, :ethiopic_amete_alem,
       :generic, :gregorian, :hebrew, :indian, :islamic, :islamic_civil,
       :islamic_rgsa, :islamic_tbla, :islamic_umalqura, :japanese, :persian, :roc]

  """
  def calendars_for_locale(locale_name) when is_binary(locale_name) do
    locale_name
    |> get_locale()
    |> Map.get(:dates)
    |> Map.get(:calendars)
    |> Map.keys()
  end

  def calendars_for_locale(%{} = locale_data) do
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

  ## Example

      iex> Cldr.Config.get_precompile_number_formats
      []

  """
  def get_precompile_number_formats do
    Application.get_env(app_name(), :precompile_number_formats, [])
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

  def decimal_formats_for(locale) do
    locale
    |> get_locale
    |> Map.get(:number_formats)
    |> Map.values()
    |> Enum.map(&Map.delete(&1, :currency_spacing))
    |> Enum.map(&Map.delete(&1, :currency_long))
    |> Enum.map(&Map.values/1)
    |> List.flatten()
    |> Enum.reject(&is_integer/1)
    |> Enum.map(&extract_formats/1)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.sort()
  end

  def number_systems do
    cldr_data_dir()
    |> Path.join("number_systems.json")
    |> File.read!()
    |> json_library().decode!
    |> Cldr.Map.atomize_keys()
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
          |> String.replace("-", "_")
          |> String.to_atom()

        locale =
          locale
          |> String.replace("_", "-")

        module = Module.concat(Cldr.Rbnf, ruleset_module)
        {module, function, locale}

      [rule] ->
        function =
          rule
          |> String.replace("-", "_")
          |> String.to_atom()

        {Cldr.Rbnf.NumberSystem, function, "root"}
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
  def locale_name_to_posix(name) when is_binary(name), do: String.replace(name, "-", "_")

  # ------ Helpers ------

  # Simple check that the locale content contains what we expect
  # by checking it has the keys we used when the locale was consolidated.
  defp assert_valid_keys!(content, locale) do
    for module <- required_modules() do
      if !Map.has_key?(content, module) and !System.get_env("DEV") do
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

  3. To all conditional inclusion of CLDR content at compile time to help
  manage memory footprint.  This capability is not yet built into `Cldr`.
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
      |> Cldr.Map.integerize_keys()

    Map.put(content, :dates, dates)
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

  def structure_units(content) do
    units =
      content["units"]
      |> Enum.map(fn {style, units} -> {style, group_units(units)} end)
      |> Enum.into(%{})

    Map.put(content, "units", units)
  end

  defp group_units(units) do
    units
    |> Enum.map(fn {k, v} ->
      [group | key] = String.split(k, "_", parts: 2)

      if key == [] do
        nil
      else
        [key] = key
        {group, key, v}
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.group_by(fn {group, _key, _value} -> group end, fn {_group, key, value} ->
      {key, value}
    end)
    |> Enum.map(fn {k, v} -> {k, Enum.into(v, %{})} end)
    |> Enum.into(%{})
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
    |> String.replace("-", "_")
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
