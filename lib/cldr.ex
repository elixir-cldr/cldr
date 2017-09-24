defmodule Cldr do
  @moduledoc """
  Cldr provides functions to localise numbers, currencies, lists and
  dates/times to an appropriate locale as defined by the CLDR data
  maintained by the ICU.

  The most commonly used functions are:

  * `Cldr.Number.to_string/2` for formatting numbers

  * `Cldr.Currency.to_string/2` for formatting currencies

  * `Cldr.List.to_string/2` for formatting lists

  * `Cldr.Unit.to_string/2` for formatting SI units
  """

  alias Cldr.Config
  alias Cldr.Locale
  alias Cldr.Install

  @default_region "001"

  if Enum.any?(Config.unknown_locales()) do
    raise Cldr.UnknownLocaleError,
      "Some locales are configured that are not known to CLDR. " <>
      "Compilation cannot continue until the configuration includes only " <>
      "locales known in CLDR.\n\n" <>
      "Configured locales: #{inspect Config.requested_locales()}\n" <>
      "Gettext locales:    #{inspect Config.gettext_locales()}\n" <>
      "Unknown locales:    " <>
      "#{IO.ANSI.red()}#{inspect Config.unknown_locales()}" <>
      "#{IO.ANSI.default_color()}\n"
  end

  @warn_if_greater_than 100
  @known_locale_count Enum.count(Config.known_locales())
  @locale_string if @known_locale_count > 1, do: "locales ", else: "locale "
  IO.puts "Generating Cldr for #{@known_locale_count} " <>
    @locale_string <>
    "#{inspect Config.known_locales, limit: 5} with " <>
    "default locale #{inspect Config.default_locale()}"
  if @known_locale_count > @warn_if_greater_than do
    IO.puts "Please be patient, generating functions for many locales " <>
    "can take some time"
  end

  # Ensure locales are all installed.  We do this once during
  # compilation of `Cldr` because this is the module we define
  # as the root of the dependency tree.
  Install.install_known_locales

  @doc """
  Returns the directory path name where the CLDR json data
  is kept.
  """
  @data_dir Config.client_data_dir()
  def data_dir do
    @data_dir
  end

  @doc """
  Returns the version of the CLDR repository as a tuple

  ## Example

      iex> Cldr.version
      {31, 0, 1}
  """
  @version Config.version()
  |> String.split(".")
  |> Enum.map(&String.to_integer/1)
  |> List.to_tuple

  def version do
    @version
  end

  @doc """
  Return the current locale to be used for `Cldr` functions that
  take an optional locale parameter for which a locale is not supplied.
  """
  @spec get_current_locale :: Locale.t
  def get_current_locale do
    Process.get(:cldr, default_locale())
  end

  @doc """
  Set the current locale to be used for `Cldr` functions that
  take an optional locale parameter for which a locale is not supplied.
  """
  @spec set_current_locale(String.t) :: Map.t
  def set_current_locale(locale) when is_binary(locale) do
    case Cldr.Locale.canonical_language_tag(locale) do
      {:ok, language_tag} -> set_current_locale(language_tag)
      {:error, reason} -> {:error, reason}
    end
  end

  def set_current_locale(%{} = language_tag) do
    Process.put(:cldr, language_tag)
  end

  @doc """
  Returns the default `locale` name.

  ## Example

      iex> Cldr.default_locale()
      %Cldr.LanguageTag{canonical_locale_name: "en-Latn-001",
        cldr_locale_name: "en-001", extensions: %{}, language: "en",
        locale: [], private_use: [], region: "001",
        requested_locale_name: "en-001", script: "Latn", transforms: %{},
        variant: nil}

  """
  @default_locale Config.default_locale() |> Cldr.Config.canonical_language_tag!
  @spec default_locale :: Cldr.LanguageTag.t
  def default_locale do
    @default_locale
  end

  @doc """
  Returns the default region when a locale
  does not specify one and none can be inferred.

  ## Example

      iex> Cldr.default_region()
      "001"

  """
  def default_region do
    @default_region
  end

  @doc """
  Returns a list of all the locales defined in the CLDR
  repository.

  Note that not necessarily all of these locales are
  available since functions are only generated for configured
  locales which is most cases will be a subset of locales
  defined in CLDR.

  See also: `requested_locales/0` and `known_locales/0`
  """
  @all_locales Config.all_locales()
  @spec all_locales :: [Locale.t]
  def all_locales do
    @all_locales
  end

  @doc """
  Returns a list of all requested locales.

  The list is the combination of configured locales,
  `Gettext` locales and the default locale.

  See also `known_locales/0` and `all_locales/0`
  """
  @requested_locales Config.requested_locales()
  @spec requested_locales :: [Locale.t] | []
  def requested_locales do
    @requested_locales
  end

  @doc """
  Returns a list of the known locales.

  Known locales are those locales which
  are the subset of all CLDR locales that
  have been configured for use either
  directly in the `config.exs` file or
  in `Gettext`.
  """
  @known_locales Config.known_locales()
  @spec known_locales :: [Locale.t] | []
  def known_locales do
    @known_locales
  end

  @doc """
  Returns a list of the locales that are configured, but
  not known in CLDR.

  Since we check at compile time for any unknown locales
  and raise and exception this function should always
  return an empty list.
  """
  @unknown_locales Config.unknown_locales()
  @spec unknown_locales :: [Locale.t] | []
  def unknown_locales do
    @unknown_locales
  end

  @doc """
  Returns a boolean indicating if the specified locale
  is configured and available in Cldr.

  ## Examples

      iex> Cldr.known_locale?("en")
      true

      iex> Cldr.known_locale?("!!")
      false

  """
  @spec known_locale?(Locale.t) :: boolean
  def known_locale?(locale) when is_binary(locale) do
    !!Enum.find(known_locales(), &(&1 == locale))
  end

  @doc """
  Get the region part of a locale or the default region
  if it doesn't exist.

  ## Examples

      iex> Cldr.region_from_locale "zh-Hant-TW"
      "TW"

      iex> Cldr.region_from_locale "pt-BR"
      "BR"

      iex> Cldr.region_from_locale "en"
      "US"

      iex> Cldr.region_from_locale "en-001"
      "001"

  """
  def region_from_locale(locale \\ get_current_locale()) do
    Cldr.Locale.canonical_language_tag!(locale).region || default_region()
  end

  @doc """
  Extract the language part from a locale.

  ## Examples

    iex> Cldr.language_from_locale "en"
    "en"

    iex> Cldr.language_from_locale "en-US"
    "en"

    iex> Cldr.language_from_locale "zh-Hant-TW"
    "zh"

  """
  def language_from_locale(locale \\ get_current_locale()) do
    Cldr.Locale.canonical_language_tag!(locale).language
  end

  @doc """
  Returns a boolean indicating if the specified locale
  is available in CLDR.

  The return value depends on whether the locale is
  defined in the CLDR repository.  It does not necessarily
  mean the locale is configured for Cldr.  See also
  `Cldr.known_locale?/1`.

  ## Examples

      iex> Cldr.locale_exists? "en-AU"
      true

      iex> Cldr.locale_exists? "en-SA"
      false

  """
  @spec locale_exists?(Locale.t) :: boolean
  def locale_exists?(locale) when is_binary(locale) do
    locale in Config.all_locales()
  end

  @doc """
  Returns either the locale name or nil based upon
  whether the locale name is configured in `Cldr`.

  ## Examples

      iex> Cldr.known_locale "en-AU"
      "en-AU"

      iex> Cldr.known_locale "en-SA"
      false

  """

  def known_locale(locale) when is_binary(locale) do
    if locale in Config.known_locales do
      locale
    else
      false
    end
  end

  @doc """
  Returns an `{:ok, locale}` or `{:error, {exception, message}}` tuple
  depending on whether the locale is valid and exists in the current
  configuration.

  `valid_locale/1` is like `locale_exists?/1` except that this
  function returns an `:ok` or `:error` tuple which is useful
  when building a `with` cascade.
  """
  def valid_locale?(locale) when is_binary(locale) do
    if known_locale?(locale) do
      {:ok, locale}
    else
      {:error, Locale.locale_error(locale)}
    end
  end

  def valid_locale?(locale) do
    {:error, {Cldr.InvalidLocaleError, "Invalid locale #{inspect locale}"}}
  end

  @doc """
  Returns a list of strings representing the calendars known to `Cldr`.

  ## Example

      iex> Cldr.known_calendars
      ["buddhist", "chinese", "coptic", "dangi", "ethiopic", "ethiopic_amete_alem",
       "gregorian", "hebrew", "indian", "islamic", "islamic_civil", "islamic_rgsa",
       "islamic_tbla", "islamic_umalqura", "japanese", "persian", "roc"]

  """
  @known_calendars Cldr.Config.known_calendars
  def known_calendars do
    @known_calendars
  end

  @doc """
  Returns a list of strings representing the currencies known to `Cldr`.

  ## Example

      iex> Cldr.known_currencies
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
  @known_currencies Cldr.Config.known_currencies
  def known_currencies do
    @known_currencies
  end

  @doc """
  Returns a list of strings representing the number systems known to `Cldr`.

  ## Example

      iex> Cldr.known_number_systems
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
  @known_number_systems Cldr.Config.known_number_systems
  def known_number_systems do
    @known_number_systems
  end
end