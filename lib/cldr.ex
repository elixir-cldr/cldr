defmodule Cldr do
  @moduledoc """
  Cldr provides the core functions to retrieve and manage
  the CLDR data that supports formatting and localisation.

  This module provides the core functions to access formatted
  CLDR data, set and retrieve a current locale and validate
  certain core data types such as locales, currencies and
  territories.

  `Cldr` functionality is packaged into a several
  packages that each depend on this one.  These additional
  modules are:

  * `Cldr.Number.to_string/2` for formatting numbers and
    `Cldr.Currency.to_string/2` for formatting currencies.
    These functions are contained in the hex package
    [ex_cldr_numbers](https://hex.pm/packages/ex_cldr_numbers).

  * `Cldr.List.to_string/2` for formatting lists.
    These function is contained in the hex package
    [ex_cldr_lists](https://hex.pm/packages/ex_cldr_lists).

  * `Cldr.Unit.to_string/2` for formatting SI units.
    These function is contained in the hex package
    [ex_cldr_units](https://hex.pm/packages/ex_cldr_units).

  * `Cldr.DateTime.to_string/2` for formatting of dates,
    times and datetimes. This function is contained in the
    hex package [ex_cldr_dates_times](https://hex.pm/packages/ex_cldr_dates_times).

  """

  alias Cldr.Config
  alias Cldr.Locale
  alias Cldr.Install
  alias Cldr.LanguageTag
  require Config

  # Ensure locales are all installed.  We do this once during
  # compilation of `Cldr` because this is the module we define
  # as the root of the dependency tree.
  Install.install_known_locale_names()

  if Enum.any?(Config.unknown_locale_names()) do
    raise Cldr.UnknownLocaleError,
          "Some locale names are configured that are not known to CLDR. " <>
            "Compilation cannot continue until the configuration includes only " <>
            "locales names known in CLDR.\n\n" <>
            "Configured locales names: #{inspect(Config.requested_locale_names())}\n" <>
            "Gettext locales names:    #{inspect(Config.gettext_locales())}\n" <>
            "Unknown locales names:    " <>
            "#{IO.ANSI.red()}#{inspect(Config.unknown_locale_names())}" <>
            "#{IO.ANSI.default_color()}\n"
  end

  @warn_if_greater_than 100
  @known_locale_count Enum.count(Config.known_locale_names())
  @locale_string if @known_locale_count > 1, do: "locales named ", else: "locale named "
  IO.puts(
    "Generating Cldr for #{@known_locale_count} " <>
      @locale_string <>
      "#{inspect(Config.known_locale_names(), limit: 5)} with " <>
      "a default locale named #{inspect(Config.default_locale())}"
  )

  if @known_locale_count > @warn_if_greater_than do
    IO.puts("Please be patient, generating functions for many locales " <> "can take some time")
  end

  @doc """
  Returns the directory path name where the CLDR json data
  is kept.
  """
  @data_dir Config.client_data_dir()
  @spec data_dir :: String.t()
  def data_dir do
    @data_dir
  end

  @doc """
  Returns the version of the CLDR repository as a tuple

  ## Example

      iex> Cldr.version
      {33, 0, 0}

  """
  @version Config.version()
           |> String.split(".")
           |> Enum.map(&String.to_integer/1)
           |> List.to_tuple()

  @spec version :: {non_neg_integer, non_neg_integer, non_neg_integer}
  def version do
    @version
  end

  @doc """
  Return the current locale to be used for `Cldr` functions that
  take an optional locale parameter for which a locale is not supplied.

  ## Example

      iex> Cldr.set_current_locale("pl")
      iex> Cldr.get_current_locale
      %Cldr.LanguageTag{
         canonical_locale_name: "pl-Latn-PL",
         cldr_locale_name: "pl",
         extensions: %{},
         language: "pl",
         locale: %{},
         private_use: [],
         rbnf_locale_name: "pl",
         territory: "PL",
         requested_locale_name: "pl",
         script: "Latn",
         transform: %{},
         variant: nil
       }

  """
  @spec get_current_locale :: LanguageTag.t()
  def get_current_locale do
    Process.get(:cldr, default_locale())
  end

  @doc """
  Set the current locale to be used for `Cldr` functions that
  take an optional locale parameter for which a locale is not supplied.

  ## Arguments

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/0`
    or a `Cldr.LanguageTag` struct returned by `Cldr.Locale.new!/1`

  See [rfc5646](https://tools.ietf.org/html/rfc5646) for the specification
  of a language tag and consult `./priv/cldr/rfc5646.abnf` for the
  specification as implemented that includes the CLDR extensions for
  "u" (locales) and "t" (transforms).

  ## Examples

      iex> Cldr.set_current_locale("en")
      {
        :ok,
        %Cldr.LanguageTag{
          canonical_locale_name: "en-Latn-US",
          cldr_locale_name: "en",
          extensions: %{},
          gettext_locale_name: "en",
          language: "en",
          locale: %{},
          private_use: [],
          rbnf_locale_name: "en",
          territory: "US",
          requested_locale_name: "en",
          script: "Latn",
          transform: %{},
          variant: nil
        }
      }

      iex> Cldr.set_current_locale("zzz")
      {:error, {Cldr.UnknownLocaleError, "The locale \\"zzz\\" is not known."}}

  """
  @spec set_current_locale(Locale.locale_name() | LanguageTag.t()) ::
          {:ok, LanguageTag.t()} | {:error, {Exception.t(), String.t()}}

  def set_current_locale(locale_name) when is_binary(locale_name) do
    case Cldr.Locale.canonical_language_tag(locale_name) do
      {:ok, language_tag} -> set_current_locale(language_tag)
      {:error, reason} -> {:error, reason}
    end
  end

  def set_current_locale(%LanguageTag{cldr_locale_name: nil} = language_tag) do
    {:error, Cldr.Locale.locale_error(language_tag)}
  end

  def set_current_locale(%LanguageTag{} = language_tag) do
    Process.put(:cldr, language_tag)
    {:ok, language_tag}
  end

  @doc """
  Returns the default `locale`.

  ## Example

      iex> Cldr.default_locale()
      %Cldr.LanguageTag{canonical_locale_name: "en-Latn-001",
        cldr_locale_name: "en-001", extensions: %{}, language: "en",
        locale: %{}, private_use: [], rbnf_locale_name: "en", territory: "001",
        requested_locale_name: "en-001", script: "Latn", transform: %{},
        variant: nil}

  """
  @default_locale Config.default_locale() |> Cldr.Config.language_tag()
  @spec default_locale :: LanguageTag.t()
  def default_locale do
    @default_locale
  end

  @doc """
  Returns the default territory when a locale
  does not specify one and none can be inferred.

  ## Example

      iex> Cldr.default_territory()
      :"001"

  """
  @default_territory @default_locale
                     |> Map.get(:territory)
                     |> String.to_atom()

  @spec default_territory :: atom()
  def default_territory do
    @default_territory
  end

  @doc """
  Returns a list of all the locale names defined in
  the CLDR repository.

  Note that not necessarily all of these locales are
  available since functions are only generated for configured
  locales which is most cases will be a subset of locales
  defined in CLDR.

  See also: `requested_locales/0` and `known_locales/0`
  """
  @all_locale_names Config.all_locale_names()
  @spec all_locale_names :: [Locale.locale_name(), ...]
  def all_locale_names do
    @all_locale_names
  end

  @doc """
  Returns a list of all requested locale names.

  The list is the combination of configured locales,
  `Gettext` locales and the default locale.

  See also `known_locales/0` and `all_locales/0`
  """
  @requested_locale_names Config.requested_locale_names()
  @spec requested_locale_names :: [Locale.locale_name(), ...] | []
  def requested_locale_names do
    @requested_locale_names
  end

  @doc """
  Returns a list of the known locale names.

  Known locales are those locales which
  are the subset of all CLDR locales that
  have been configured for use either
  directly in the `config.exs` file or
  in `Gettext`.
  """
  @known_locale_names Config.known_locale_names()
  @spec known_locale_names :: [Locale.locale_name(), ...] | []
  def known_locale_names do
    @known_locale_names
  end

  @doc """
  Returns a list of the locales names that are configured,
  but not known in CLDR.

  Since there is a compile-time exception raise if there are
  any unknown locales this function should always
  return an empty list.
  """
  @unknown_locale_names Config.unknown_locale_names()
  @spec unknown_locale_names :: [Locale.locale_name(), ...] | []
  def unknown_locale_names do
    @unknown_locale_names
  end

  @doc """
  Returns a list of locale names which have rules based number
  formats (RBNF).
  """
  @known_rbnf_locale_names Cldr.Config.known_rbnf_locale_names()
  @spec known_rbnf_locale_names :: [Locale.locale_name(), ...] | []
  def known_rbnf_locale_names do
    @known_rbnf_locale_names
  end

  @doc """
  Returns a list of GetText locale names but in CLDR format with
  underscore replaces by hyphen in order to facilitate comparisons
  with Cldr locale names.
  """
  @spec known_gettext_locale_names :: [Locale.locale_name(), ...] | []
  def known_gettext_locale_names do
    Config.gettext_locales()
  end

  @doc """
  Returns a boolean indicating if the specified locale
  name is configured and available in Cldr.

  ## Arguments

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/0`

  ## Examples

      iex> Cldr.known_locale_name?("en")
      true

      iex> Cldr.known_locale_name?("!!")
      false

  """
  @spec known_locale_name?(Locale.locale_name()) :: boolean
  def known_locale_name?(locale_name) when is_binary(locale_name) do
    locale_name in known_locale_names()
  end

  @doc """
  Returns a boolean indicating if the specified locale
  name is configured and available in Cldr and supports
  rules based number formats (RBNF).

  ## Arguments

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/0`

  ## Examples

      iex> Cldr.known_rbnf_locale_name?("en")
      true

      iex> Cldr.known_rbnf_locale_name?("!!")
      false

  """
  @spec known_rbnf_locale_name?(Locale.locale_name()) :: boolean
  def known_rbnf_locale_name?(locale_name) when is_binary(locale_name) do
    locale_name in known_rbnf_locale_names()
  end

  @doc """
  Returns a boolean indicating if the specified locale
  name is configured and available in Gettext.

  ## Arguments

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/0`

  ## Examples

      iex> Cldr.known_gettext_locale_name?("en")
      true

      iex> Cldr.known_gettext_locale_name?("!!")
      false

  """
  @spec known_gettext_locale_name?(Locale.locale_name()) :: boolean
  def known_gettext_locale_name?(locale_name) when is_binary(locale_name) do
    locale_name in known_gettext_locale_names()
  end

  @doc """
  Returns either the `locale_name` or `false` based upon
  whether the locale name is configured in `Cldr`.

  This is helpful when building a list of `or` expressions
  to return the first known locale name from a list.

  ## Arguments

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/0`

  ## Examples

      iex> Cldr.known_locale_name "en-AU"
      "en-AU"

      iex> Cldr.known_locale_name "en-SA"
      false

  """
  @spec known_locale_name(Locale.locale_name()) :: String.t() | false
  def known_locale_name(locale_name) when is_binary(locale_name) do
    if known_locale_name?(locale_name) do
      locale_name
    else
      false
    end
  end

  @doc """
  Returns either the RBNF `locale_name` or `false` based upon
  whether the locale name is configured in `Cldr`
  and has RBNF rules defined.

  ## Arguments

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/0`

  ## Examples

      iex> Cldr.known_rbnf_locale_name "en"
      "en"

      iex> Cldr.known_rbnf_locale_name "en-SA"
      false

  """
  @spec known_rbnf_locale_name(Locale.locale_name()) :: String.t() | false
  def known_rbnf_locale_name(locale_name) when is_binary(locale_name) do
    if known_rbnf_locale_name?(locale_name) do
      locale_name
    else
      false
    end
  end

  @doc """
  Returns either the Gettext `locale_name` in Cldr format or
  `false` based upon whether the locale name is configured in
  `GetText`.

  ## Arguments

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/0`

  ## Examples

      iex> Cldr.known_gettext_locale_name "en"
      "en"

      iex> Cldr.known_gettext_locale_name "en-SA"
      false

  """
  @spec known_gettext_locale_name(Locale.locale_name()) :: String.t() | false
  def known_gettext_locale_name(locale_name) when is_binary(locale_name) do
    Cldr.Locale.known_gettext_locale_name(locale_name)
  end

  @doc """
  Returns a boolean indicating if the specified locale
  is available in CLDR.

  The return value depends on whether the locale is
  defined in the CLDR repository.  It does not necessarily
  mean the locale is configured for Cldr.  See also
  `Cldr.known_locale?/1`.

  ## Arguments

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/0`
    or a `Cldr.LanguageTag` struct returned by `Cldr.Locale.new!/1`

  ## Examples

      iex> Cldr.available_locale_name? "en-AU"
      true

      iex> Cldr.available_locale_name? "en-SA"
      false

  """
  @spec available_locale_name?(Locale.locale_name() | LanguageTag.t()) :: boolean
  def available_locale_name?(locale_name) when is_binary(locale_name) do
    locale_name in Config.all_locale_names()
  end

  def available_locale_name?(%LanguageTag{cldr_locale_name: cldr_locale_name}) do
    available_locale_name?(cldr_locale_name)
  end

  @doc """
  Normalise and validate a locale name.

  ## Arguments

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/0`
    or a `Cldr.LanguageTag` struct returned by `Cldr.Locale.new!/1`

  ## Returns

  * `{:ok, language_tag}`

  * `{:error, reason}`

  ## Examples

      iex> Cldr.validate_locale "en"
      {:ok,
      %Cldr.LanguageTag{
        canonical_locale_name: "en-Latn-US",
        cldr_locale_name: "en",
        extensions: %{},
        gettext_locale_name: "en",
        language: "en",
        locale: %{},
        private_use: [],
        rbnf_locale_name: "en",
        requested_locale_name: "en",
        script: "Latn",
        territory: "US",
        transform: %{},
        variant: nil
      }}


      iex> Cldr.validate_locale Cldr.default_locale
      {:ok,
      %Cldr.LanguageTag{
        canonical_locale_name: "en-Latn-001",
        cldr_locale_name: "en-001",
        extensions: %{},
        gettext_locale_name: nil,
        language: "en",
        locale: %{},
        private_use: [],
        rbnf_locale_name: "en",
        requested_locale_name: "en-001",
        script: "Latn",
        territory: "001",
        transform: %{},
        variant: nil
      }}

      iex> Cldr.validate_locale "zzz"
      {:error, {Cldr.UnknownLocaleError, "The locale \\"zzz\\" is not known."}}

  """
  @spec validate_locale(Locale.locale_name() | LanguageTag.t()) ::
          {:ok, String.t()} | {:error, {Exception.t(), String.t()}}

  # Precompile the known locales.  In benchmarking this
  # is 20x faster.
  @language_tags Cldr.Config.all_language_tags()

  for locale_name <- Cldr.Config.known_locale_names() do
    language_tag =
      Map.get(@language_tags, locale_name)
      |> Cldr.Locale.set_gettext_locale_name()

    def validate_locale(unquote(locale_name)) do
      {:ok, unquote(Macro.escape(language_tag))}
    end
  end

  def validate_locale(locale_name) when is_binary(locale_name) do
    case Cldr.Locale.new(locale_name) do
      {:ok, locale} -> validate_locale(locale)
      {:error, reason} -> {:error, reason}
    end
  end

  def validate_locale(%LanguageTag{cldr_locale_name: nil} = locale) do
    {:error, Locale.locale_error(locale)}
  end

  def validate_locale(%LanguageTag{} = language_tag) do
    {:ok, language_tag}
  end

  def validate_locale(locale) do
    {:error, Locale.locale_error(locale)}
  end

  @doc """
  Normalise and validate a gettext locale name.

  ## Arguments

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/0`
    or a `Cldr.LanguageTag` struct returned by `Cldr.Locale.new!/1`

  ## Returns

  * `{:ok, language_tag}`

  * `{:error, reason}`

  ## Examples


  """
  def validate_gettext_locale(locale_name) when is_binary(locale_name) do
    case Cldr.Locale.new(locale_name) do
      {:ok, locale} -> validate_gettext_locale(locale)
      {:error, reason} -> {:error, reason}
    end
  end

  def validate_gettext_locale(%LanguageTag{gettext_locale_name: nil} = locale) do
    {:error, Locale.gettext_locale_error(locale)}
  end

  def validate_gettext_locale(%LanguageTag{} = language_tag) do
    {:ok, language_tag}
  end

  def validate_gettext_locale(locale) do
    {:error, Locale.gettext_locale_error(locale)}
  end

  @doc """
  Returns a list of strings representing the calendars known to `Cldr`.

  ## Example

      iex> Cldr.known_calendars
      [:buddhist, :chinese, :coptic, :dangi, :ethiopic, :ethiopic_amete_alem,
       :gregorian, :hebrew, :indian, :islamic, :islamic_civil, :islamic_rgsa,
       :islamic_tbla, :islamic_umalqura, :japanese, :persian, :roc]

  """
  @known_calendars Cldr.Config.known_calendars()
  @spec known_calendars :: [atom(), ...]
  def known_calendars do
    @known_calendars
  end

  @doc """
  Normalise and validate a calendar name.

  ## Arguments

  * `calendar` is any calendar name returned by `Cldr.known_calendars/0`

  ## Returns

  * `{:ok, normalized_calendar_name}` or

  * `{:error, {Cldr.UnknownCalendarError, message}}`

  ## Examples

      iex> Cldr.validate_calendar :gregorian
      {:ok, :gregorian}

      iex> Cldr.validate_calendar :invalid
      {:error, {Cldr.UnknownCalendarError, "The calendar name :invalid is invalid"}}

  """
  @spec validate_calendar(atom() | String.t()) ::
          {:ok, atom()} | {:error, {Exception.t(), String.t()}}

  def validate_calendar(calendar) when is_atom(calendar) and calendar in @known_calendars do
    {:ok, calendar}
  end

  # "gregory" is the name used for the locale "u" extension
  def validate_calendar("gregory"), do: {:ok, :gregorian}

  def validate_calendar(calendar) when is_atom(calendar) do
    {:error, unknown_calendar_error(calendar)}
  end

  def validate_calendar(calendar) when is_binary(calendar) do
    calendar
    |> String.downcase()
    |> String.to_existing_atom()
    |> validate_calendar
  rescue
    ArgumentError ->
      {:error, unknown_calendar_error(calendar)}
  end

  @doc """
  Returns an error tuple for an invalid calendar.

  ## Arguments

    * `calendar` is any calendar name **not** returned by `Cldr.known_calendars/0`

  ## Returns

  * `{:error, {Cldr.UnknownCalendarError, message}}`

  ## Examples

      iex> Cldr.unknown_calendar_error "invalid"
      {Cldr.UnknownCalendarError, "The calendar name \\"invalid\\" is invalid"}

  """
  def unknown_calendar_error(calendar) do
    {Cldr.UnknownCalendarError, "The calendar name #{inspect(calendar)} is invalid"}
  end

  @doc """
  Returns a list of the territories known to `Cldr`.

  The territories codes are defined in [UN M.49](https://en.wikipedia.org/wiki/UN_M.49)
  which defines both individual territories and enclosing territories. These enclosing
  territories are defined for statistical purposes and do not relate to political
  alignment.

  For example, the territory `:"001"` is defined as "the world".

  ## Example

      iex> Cldr.known_territories
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
  @known_territories Cldr.Config.known_territories()
  @spec known_territories :: [atom(), ...]
  def known_territories do
    @known_territories
  end

  @doc """
  Normalise and validate a territory code.

  ## Arguments

  * `territory` is any territory code returned by `Cldr.known_territories/0`

  ## Returns:

  * `{:ok, normalized_territory_code}` or

  * `{:error, {Cldr.UnknownTerritoryError, message}}`

  ## Examples

      iex> Cldr.validate_territory "en"
      {:error, {Cldr.UnknownTerritoryError, "The territory \\"en\\" is unknown"}}

      iex> Cldr.validate_territory "gb"
      {:ok, :GB}

      iex> Cldr.validate_territory "001"
      {:ok, :"001"}

      iex> Cldr.validate_territory Cldr.Locale.new!("en")
      {:ok, :US}

      iex> Cldr.validate_territory %{}
      {:error, {Cldr.UnknownTerritoryError, "The territory %{} is unknown"}}

  """
  @spec validate_territory(atom() | String.t()) ::
          {:ok, atom()} | {:error, {Exception.t(), String.t()}}

  def validate_territory(territory) when is_atom(territory) and territory in @known_territories do
    {:ok, territory}
  end

  def validate_territory(territory) when is_atom(territory) do
    {:error, unknown_territory_error(territory)}
  end

  def validate_territory(territory) when is_binary(territory) do
    territory
    |> String.upcase()
    |> String.to_existing_atom()
    |> validate_territory
  rescue
    ArgumentError ->
      {:error, unknown_territory_error(territory)}
  end

  def validate_territory(%LanguageTag{territory: nil} = locale) do
    {:error, unknown_territory_error(locale)}
  end

  def validate_territory(%LanguageTag{territory: territory}) do
    validate_territory(territory)
  end

  def validate_territory(territory) do
    {:error, unknown_territory_error(territory)}
  end

  @doc """
  Returns an error tuple for an unknown territory.

  ## Arguments

  * `territory` is any territory code **not** returned by `Cldr.known_territories/0`

  ## Returns

  * `{:error, {Cldr.UnknownTerritoryError, message}}`

  ## Examples

      iex> Cldr.unknown_territory_error "invalid"
      {Cldr.UnknownTerritoryError, "The territory \\"invalid\\" is unknown"}

  """
  @spec unknown_territory_error(any()) :: {Cldr.UnknownTerritoryError, String.t()}
  def unknown_territory_error(territory) do
    {Cldr.UnknownTerritoryError, "The territory #{inspect(territory)} is unknown"}
  end

  @doc """
  Returns a list of strings representing the currencies known to `Cldr`.

  ## Example

      iex> Cldr.known_currencies
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
  @known_currencies Cldr.Config.known_currencies()
  @spec known_currencies :: [atom(), ...] | []
  def known_currencies do
    @known_currencies
  end

  @doc """
  Normalize and validate a currency code.

  ## Arguments

  * `currency` is any ISO 4217 currency code as returned by `Cldr.known_currencies/0`
    or any valid private use ISO4217 code which is a three-letter alphabetic code that
    starts with "X".

  ## Returns

  * `{:ok, normalized_currency_code}` or

  * `{:error, {Cldr.UnknownCurrencyError, message}}`

  ## Examples

      iex> Cldr.validate_currency :USD
      {:ok, :USD}

      iex> Cldr.validate_currency "USD"
      {:ok, :USD}

      iex> Cldr.validate_currency :XTC
      {:ok, :XTC}

      iex> Cldr.validate_currency "xtc"
      {:ok, :XTC}

      iex> Cldr.validate_currency "invalid"
      {:error, {Cldr.UnknownCurrencyError, "The currency \\"invalid\\" is invalid"}}

      iex> Cldr.validate_currency :invalid
      {:error, {Cldr.UnknownCurrencyError, "The currency :invalid is invalid"}}

  """
  @spec validate_currency(atom() | String.t()) ::
          {:ok, atom()} | {:error, {Exception.t(), String.t()}}

  def validate_currency(currency) when is_atom(currency) and currency in @known_currencies do
    {:ok, currency}
  end

  def validate_currency(currency) when is_atom(currency) do
    currency
    |> Atom.to_string()
    |> validate_currency
    |> case do
      {:error, _} -> {:error, unknown_currency_error(currency)}
      ok -> ok
    end
  end

  def validate_currency(
        <<char_1::integer-size(8), char_2::integer-size(8), char_3::integer-size(8)>> = currency
      )
      when Config.is_alphabetic(char_1) and Config.is_alphabetic(char_2) and
             Config.is_alphabetic(char_3) and char_1 in [?x, ?X] do
    {:ok, String.to_atom(String.upcase(currency))}
  end

  def validate_currency(
        <<char_1::integer-size(8), char_2::integer-size(8), char_3::integer-size(8)>> = currency
      )
      when Config.is_alphabetic(char_1) and Config.is_alphabetic(char_2) and
             Config.is_alphabetic(char_3) do
    currency_code =
      currency
      |> String.upcase()
      |> String.to_existing_atom()

    if currency_code in @known_currencies do
      {:ok, currency_code}
    else
      {:error, unknown_currency_error(currency)}
    end
  rescue
    ArgumentError ->
      {:error, unknown_currency_error(currency)}
  end

  def validate_currency(invalid_currency) do
    {:error, unknown_currency_error(invalid_currency)}
  end

  @doc """
  Returns an error tuple for an invalid currency.

  ## Arguments

  * `currency` is any currency code **not** returned by `Cldr.known_currencies/0`

  ## Returns

  * `{:error, {Cldr.UnknownCurrencyError, message}}`

  ## Examples

      iex> Cldr.unknown_currency_error "invalid"
      {Cldr.UnknownCurrencyError, "The currency \\"invalid\\" is invalid"}

  """
  @spec unknown_currency_error(any()) :: {Cldr.UnknownCurrencyError, String.t()}
  def unknown_currency_error(currency) do
    {Cldr.UnknownCurrencyError, "The currency #{inspect(currency)} is invalid"}
  end

  @doc """
  Returns a list of atoms representing the number systems known to `Cldr`.

  ## Example

      iex> Cldr.known_number_systems
      [:adlm, :ahom, :arab, :arabext, :armn, :armnlow, :bali, :beng, :bhks, :brah,
       :cakm, :cham, :cyrl, :deva, :ethi, :fullwide, :geor, :gonm, :grek, :greklow,
       :gujr, :guru, :hanidays, :hanidec, :hans, :hansfin, :hant, :hantfin, :hebr,
       :hmng, :java, :jpan, :jpanfin, :kali, :khmr, :knda, :lana, :lanatham, :laoo,
       :latn, :lepc, :limb, :mathbold, :mathdbl, :mathmono, :mathsanb, :mathsans,
       :mlym, :modi, :mong, :mroo, :mtei, :mymr, :mymrshan, :mymrtlng, :newa, :nkoo,
       :olck, :orya, :osma, :roman, :romanlow, :saur, :shrd, :sind, :sinh, :sora,
       :sund, :takr, :talu, :taml, :tamldec, :telu, :thai, :tibt, :tirh, :vaii, :wara]

  """
  @known_number_systems Cldr.Config.known_number_systems()
  @spec known_number_systems :: [atom(), ...] | []
  def known_number_systems do
    @known_number_systems
  end

  @doc """
  Normalize and validate a number system name.

  ## Arguments

  * `number_system` is any number system name returned by
    `Cldr.known_number_systems/0`

  ## Returns

  * `{:ok, normalized_number_system_name}` or

  * `{:error, {exception, message}}`

  ## Examples

      iex> Cldr.validate_number_system :latn
      {:ok, :latn}

      iex> Cldr.validate_number_system "latn"
      {:ok, :latn}

      iex> Cldr.validate_number_system "invalid"
      {
        :error,
        {Cldr.UnknownNumberSystemError, "The number system :invalid is unknown"}
      }

  """
  @spec validate_number_system(atom() | binary()) ::
          {:ok, String.t()} | {:error, {Exception.t(), String.t()}}

  def validate_number_system(number_system)
      when is_atom(number_system) and number_system in @known_number_systems do
    {:ok, number_system}
  end

  def validate_number_system(number_system) when is_binary(number_system) do
    number_system
    |> String.downcase()
    |> String.to_existing_atom()
    |> validate_number_system
  rescue
    ArgumentError ->
      {:error, unknown_number_system_error(number_system)}
  end

  def validate_number_system(number_system) do
    {:error, unknown_number_system_error(number_system)}
  end

  @doc """
  Returns an error tuple for an unknown number system.

  ## Arguments

  * `number_system` is any number system name **not** returned by `Cldr.known_number_systems/0`

  ## Returns

  * `{:error, {Cldr.UnknownNumberSystemError, message}}`

  ## Examples

      iex> Cldr.unknown_number_system_error "invalid"
      {Cldr.UnknownNumberSystemError, "The number system \\"invalid\\" is invalid"}

      iex> Cldr.unknown_number_system_error :invalid
      {Cldr.UnknownNumberSystemError, "The number system :invalid is unknown"}

  """
  @spec unknown_currency_error(any()) :: {Cldr.UnknownCurrencyError, String.t()}
  def unknown_number_system_error(number_system) when is_atom(number_system) do
    {Cldr.UnknownNumberSystemError, "The number system #{inspect(number_system)} is unknown"}
  end

  def unknown_number_system_error(number_system) do
    {Cldr.UnknownNumberSystemError, "The number system #{inspect(number_system)} is invalid"}
  end

  @doc """
  Returns a list of atoms representing the number systems types known to `Cldr`.

  ## Example

      iex> Cldr.Config.known_number_system_types
      [:default, :finance, :native, :traditional]

  """
  @known_number_system_types Cldr.Config.known_number_system_types()
  def known_number_system_types do
    @known_number_system_types
  end

  @doc """
  Normalise and validate a number system type.

  ## Arguments

  * `number_system_type` is any number system type returned by
    `Cldr.known_number_system_types/0`

  ## Returns

  * `{:ok, normalized_number_system_type}` or

  * `{:error, {exception, message}}`

  ## Examples

      iex> Cldr.validate_number_system_type :default
      {:ok, :default}

      iex> Cldr.validate_number_system_type :traditional
      {:ok, :traditional}

      iex> Cldr.validate_number_system_type :latn
      {
        :error,
        {Cldr.UnknownNumberSystemTypeError, "The number system type :latn is unknown"}
      }

  """
  @spec validate_number_system_type(String.t() | atom()) ::
          {:ok, String.t()} | {:error, {Exception.t(), String.t()}}

  def validate_number_system_type(number_system_type)
      when is_atom(number_system_type) and number_system_type in @known_number_system_types do
    {:ok, number_system_type}
  end

  def validate_number_system_type(number_system_type) when is_binary(number_system_type) do
    number_system_type
    |> String.downcase()
    |> String.to_existing_atom()
    |> validate_number_system_type
  rescue
    ArgumentError ->
      {:error, unknown_number_system_type_error(number_system_type)}
  end

  def validate_number_system_type(number_system_type) do
    {:error, unknown_number_system_type_error(number_system_type)}
  end

  @doc """
  Returns an error tuple for an unknown number system type.

  ## Options

  * `number_system_type` is any number system type name **not** returned
      by `Cldr.known_number_system_types/0`

  ## Returns

  * `{:error, {Cldr.UnknownNumberSystemTypeError, message}}`

  ## Examples

      iex> Cldr.unknown_number_system_type_error "invalid"
      {Cldr.UnknownNumberSystemTypeError, "The number system type \\"invalid\\" is invalid"}

      iex> Cldr.unknown_number_system_type_error :invalid
      {Cldr.UnknownNumberSystemTypeError, "The number system type :invalid is unknown"}

  """
  @spec unknown_number_system_type_error(any()) :: {Cldr.UnknownNumberSystemTypeError, String.t()}

  def unknown_number_system_type_error(number_system_type) when is_atom(number_system_type) do
    {
      Cldr.UnknownNumberSystemTypeError,
      "The number system type #{inspect(number_system_type)} is unknown"
    }
  end

  def unknown_number_system_type_error(number_system_type) do
    {
      Cldr.UnknownNumberSystemTypeError,
      "The number system type #{inspect(number_system_type)} is invalid"
    }
  end

  def locale_name(%LanguageTag{cldr_locale_name: locale_name}), do: inspect(locale_name)
  def locale_name(locale) when is_binary(locale), do: inspect(locale)
end
