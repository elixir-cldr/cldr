defmodule Cldr.Locale do
  @moduledoc """
  Functions to parse and normalize locale names into a structure
  locale represented by a `Cldr.LanguageTag`.

  CLDR represents localisation data organized into locales, with
  each locale being identified by a locale name that is formatted
  according to [RFC5646](https://tools.ietf.org/html/rfc5646).

  In practise, the CLDR data utilizes a simple subset of locale name
  formats being:

  * a Language code such as `en` or `fr`

  * a Language code and Tertitory code such as `en-GB`

  * a Language code and Script such as `zh-Hant`

  * and in only two cases a Language code, Territory code and Variant
    such as `ca-ES-valencia` and `en-US-posix`.

  The RFC defines a language tag as:

  > A language tag is composed from a sequence of one or more "subtags",
    each of which refines or narrows the range of language identified by
    the overall tag.  Subtags, in turn, are a sequence of alphanumeric
    characters (letters and digits), distinguished and separated from
    other subtags in a tag by a hyphen ("-", [Unicode] U+002D)

  Therefore `Cldr` uses the hyphen ("-", [Unicode] U+002D) as the subtag
  separator.  On certain platforms, including POSIX platforms, the
  subtag separator is a "_" (underscore) rather than a "-" (hyphen). Where
  appropriate, `Cldr` will transliterate any underscore into a hyphen before
  parsing or processing.

  ### Locale name validity

  When validating a locale name, `Cldr` will attempt to match the requested
  locale name to a configured locale. Therefore `Cldr.Locale.new/2` may
  return an `{:ok, language_tag}` tuple even when the locale returned does
  not exactly match the requested locale name.  For example, the following
  attempts to create a locale matching the non-existent "english as spoken
  in Spain" local name.  Here `Cldr` will match to the nearest configured
  locale, which in this case will be "en".

      iex> Cldr.Locale.new("en-ES", TestBackend.Cldr)
      {:ok, %Cldr.LanguageTag{
        backend: TestBackend.Cldr,
        canonical_locale_name: "en-ES",
        cldr_locale_name: "en",
        extensions: %{},
        gettext_locale_name: "en",
        language: "en",
        locale: %{},
        private_use: [],
        rbnf_locale_name: "en",
        requested_locale_name: "en-ES",
        script: "Latn",
        territory: :ES,
        transform: %{},
        language_variants: []
      }}

  ### Matching locales to requested locale names

  When attempting to match the requested locale name to a configured
  locale, `Cldr` attempt to match against a set of reductions in the
  following order and will return the first match:

  * language, script, territory, [variants]
  * language, territory, [variants]
  * language, script, [variants]
  * language, [variants]
  * language, script, territory
  * language, territory
  * language, script
  * language
  * requested locale name
  * nil

  Therefore matching is tolerant of a request for unknown scripts,
  territories and variants.  Only the requested language is a
  requirement to be matched to a configured locale.

  ### Substitutions for Obsolete and Deprecated locale names

  CLDR provides data to help manage the transition from obsolete
  or deprecated locale names to current names.  For example, the
  following requests the locale name "mo" which is the deprecated
  code for "Moldovian".  The replacement code is "ro" (Romanian).

      iex> Cldr.Locale.new("mo", TestBackend.Cldr)
      {:ok, %Cldr.LanguageTag{
        backend: TestBackend.Cldr,
        extensions: %{},
        gettext_locale_name: nil,
        language: "ro",
        language_subtags: [],
        language_variants: [],
        locale: %{}, private_use: [],
        rbnf_locale_name: "ro",
        requested_locale_name: "mo",
        script: "Latn",
        transform: %{},
        canonical_locale_name: "ro",
        cldr_locale_name: "ro",
        territory: :RO
      }}

  ### Likely subtags

  CLDR also provides data to indetify the most likely subtags for a
  requested locale name.  This data is based on the default content data,
  the population data, and the the suppress-script data in [BCP47]. It is
  heuristically derived, and may change over time. For example, when
  requesting the locale "en", the following is returned:

      iex> Cldr.Locale.new("en", TestBackend.Cldr)
      {:ok, %Cldr.LanguageTag{
        backend: TestBackend.Cldr,
        canonical_locale_name: "en",
        cldr_locale_name: "en",
        extensions: %{},
        gettext_locale_name: "en",
        language: "en",
        locale: %{},
        private_use: [],
        rbnf_locale_name: "en",
        requested_locale_name: "en",
        script: "Latn",
        territory: :US,
        transform: %{},
        language_variants: []
      }}

  Which shows that a the likely subtag for the script is "Latn" and the likely
  territory is "US".

  Using the example for Substitutions above, we can see the
  result of combining substitutions and likely subtags for locale name "mo"
  returns the current language code of "ro" as well as the likely
  territory code of "MD" (Moldova).

  ### Unknown territory codes

  Whilst `Cldr` is tolerant of invalid territory codes, it is also important
  that such invalid codes not shadow the potential replacement of deprecated
  codes nor the insertion of likely subtags.  Therefore invalid territory
  codes are ignored during this process.  For example requesting a locale
  name "en-XX" which requests the invalid territory "XX", the following
  will be returned:

      iex> Cldr.Locale.new("en-XX", TestBackend.Cldr)
      {:ok, %Cldr.LanguageTag{
        backend: TestBackend.Cldr,
        canonical_locale_name: "en-US",
        cldr_locale_name: "en",
        extensions: %{},
        gettext_locale_name: "en",
        language: "en",
        locale: %{},
        private_use: [],
        rbnf_locale_name: "en",
        requested_locale_name: "en",
        script: "Latn",
        territory: :US,
        transform: %{},
        language_variants: []
      }}

  ### Locale extensions

  Unicode defines the [U extension](https://unicode.org/reports/tr35/#Locale_Extension_Key_and_Type_Data)
  which support defining the requested treatment of CLDR data formats. For example, a locale name
  can configure the requested:

  * calendar to be used for dates
  * collation
  * currency
  * currency format
  * number system
  * first day of the week
  * 12-hour or 24-hour time
  * time zone
  * and many other items

  For example, the following locale name will request the use of the timezone `Australia/Sydney`,
  and request the use of `accounting` format when formatting currencies:

      iex> MyApp.Cldr.validate_locale "en-AU-u-tz-ausyd-cf-account"
      {
        :ok,
        %Cldr.LanguageTag{
          backend: MyApp.Cldr,
          canonical_locale_name: "en-AU-u-cf-accounting-tz-ausyd",
          cldr_locale_name: "en-AU",
          extensions: %{},
          gettext_locale_name: "en",
          language: "en",
          language_subtags: [],
          language_variants: [],
          locale: %Cldr.LanguageTag.U{
            alternative_collation: nil,
            backward_level2: nil,
            calendar: nil,
            case_first: nil,
            case_level: nil,
            collation: nil,
            currency: nil,
            currency_format: :accounting,
            emoji_style: nil,
            first_day_of_week: nil,
            hiragana_quarternary: nil,
            hour_cycle: nil,
            line_break_style: nil,
            line_break_word: nil,
            measurement_system: nil,
            normalization: nil,
            number_system: nil,
            numeric: nil,
            region_override: nil,
            reorder: nil,
            sentence_break_supression: nil,
            strength: nil,
            subdivision: nil,
            timezone: "ausyd",
            variable_top: nil,
            variant: nil
          },
          private_use: '',
          rbnf_locale_name: "en",
          requested_locale_name: "en-AU",
          script: "Latn",
          territory: :AU,
          transform: %{}
        }
      }

  """
  alias Cldr.LanguageTag
  import Cldr.Helpers, only: [empty?: 1]

  @typedoc "The name of a locale in a string format"
  @type locale_name() :: String.t()
  @type language :: String.t() | nil
  @type script :: String.t() | nil
  @type territory :: String.t() | nil
  @type variants :: [String.t()] | []
  @type subtags :: [String.t(), ...] | []

  @root_locale "root"

  @doc false
  def define_locale_new(config) do
    quote location: :keep do
      defmodule Locale do
        @moduledoc false
        if Cldr.Config.include_module_docs?(unquote(config.generate_docs)) do
          @moduledoc """
          Backend module that provides functions
          to define new locales.
          """
        end

        def new(locale_name), do: Cldr.Locale.new(locale_name, unquote(config.backend))
        def new!(locale_name), do: Cldr.Locale.new!(locale_name, unquote(config.backend))

        @doc """
        Returns the territory from a language tag or
        locale name.

        ## Arguments

        * `locale` is any language tag returned be `Cldr.Locale.new/2`
          or a locale name in the list returned by `Cldr.known_locale_names/1`

        ## Returns

        * A territory code as an atom

        ## Examples

            iex> #{inspect(__MODULE__)}.territory_from_locale "en-US"
            :US

            iex> #{inspect(__MODULE__)}.territory_from_locale "en-US-u-rg-GBzzzz"
            :GB

        """
        @spec territory_from_locale(Cldr.LanguageTag.t() | Cldr.Locale.locale_name()) ::
                Cldr.territory()

        @doc since: "2.18.2"

        def territory_from_locale(locale) when is_binary(locale) do
          Cldr.Locale.territory_from_locale(locale, unquote(config.backend))
        end

        def territory_from_locale(%LanguageTag{} = locale) do
          Cldr.Locale.territory_from_locale(locale)
        end

        @doc """
        Returns the time zone from a language tag or
        locale name.

        ## Arguments

        * `locale` is any language tag returned be `Cldr.Locale.new/2`
          or a locale name in the list returned by `Cldr.known_locale_names/1`

        ## Returns

        * A time zone ID as a string or

        * `:error` if no time zone can be determined

        ## Examples

            iex> #{inspect(__MODULE__)}.timezone_from_locale "en-US-u-tz-ausyd"
            "Australia/Sydney"

        """
        @doc since: "2.19.0"

        @spec timezone_from_locale(LanguageTag.t() | Cldr.Locale.locale_name()) ::
                String.t() | {:error, {module(), String.t()}}

        def timezone_from_locale(locale) when is_binary(locale) do
          Cldr.Locale.timezone_from_locale(locale, unquote(config.backend))
        end

        def timezone_from_locale(%LanguageTag{} = locale) do
          Cldr.Locale.timezone_from_locale(locale)
        end
      end
    end
  end

  defdelegate new(locale_name, backend), to: __MODULE__, as: :canonical_language_tag
  defdelegate new!(locale_name, backend), to: __MODULE__, as: :canonical_language_tag!

  defdelegate new(locale_name), to: __MODULE__, as: :canonical_language_tag
  defdelegate new!(locale), to: __MODULE__, as: :canonical_language_tag!

  defdelegate locale_name_to_posix(locale_name), to: Cldr.Config
  defdelegate locale_name_from_posix(locale_name), to: Cldr.Config

  @doc """
  Mapping of language data to known
  scripts and territories

  """
  @language_data Cldr.Config.language_data()

  def language_data do
    @language_data
  end

  @doc """
  Returns mappings between a locale
  and its parent.

  The mappings exist only where normal
  inheritance rules are not applied.

  """
  @parent_locales Cldr.Config.parent_locales()

  def parent_locale_map do
    @parent_locales
  end

  @doc """
  Returns a list of all the parent locales
  for a given locale.

  """
  @spec parents(LanguageTag.t()) :: list(LanguageTag.t())
  def parents(%LanguageTag{} = locale, acc \\ []) do
    case parent(locale) do
      {:error, _} -> Enum.reverse(acc)
      {:ok, locale} -> parents(locale, [locale | acc])
    end
  end

  @doc """
  Returns the parent for a given locale.

  The function implements locale inheritance
  in accordance with [CLDR's inheritance rules](https://unicode.org/reports/tr35/#Locale_Inheritance).

  Only locales that are configured are returned.
  That is, there may be a different parent locale in CLDR
  but unless those locales are configured they are not
  candidates to be parents in this context. The contract
  is to return either a known locale or an error.

  ### Inheritance

  * Inheritance starts by looking for a parent locale via
   `Cldr.Config.parent_locales/0`.

  * If not found, strip in turn the variant, script and territory
    while checking to see if a base locale for the given language
    exists.

  * If no parent language exists then move to the default
    locale and its inheritance chain.

  * As a last resort, use the `root` locale.

  """
  @spec parent(LanguageTag.t()) ::
          {:ok, LanguageTag.t()} | {:error, {module(), binary()}}

  def parent(%LanguageTag{language: "root"}) do
    {:error, no_parent_error("root")}
  end

  def parent(%LanguageTag{backend: backend} = child) do
    if parent = Map.get(parent_locale_map(), child.cldr_locale_name) do
      Cldr.validate_locale(parent, backend)
    else
      {:ok, locale} = Cldr.LanguageTag.parse(child.cldr_locale_name)

      locale
      |> find_parent(backend)
      |> return_parent_or_default(child, backend)
      |> transfer_extensions(child)
    end
  end

  @spec parent(locale_name(), Cldr.backend()) ::
          {:ok, LanguageTag.t()} | {:error, {module(), binary()}}

  def parent(locale_name, backend \\ Cldr.default_backend!()) when is_binary(locale_name) do
    with {:ok, locale} <- Cldr.validate_locale(locale_name, backend) do
      parent(locale)
    end
  end

  defp find_parent(%LanguageTag{language_variants: [_ | _] = variants} = locale, backend) do
    %LanguageTag{language: language, script: script, territory: territory} = locale
    first_match(language, script, territory, variants, &known_locale(&1, backend))
  end

  defp find_parent(%LanguageTag{territory: territory} = locale, backend)
       when not is_nil(territory) do
    %LanguageTag{language: language, script: script} = locale
    first_match(language, script, nil, [], &known_locale(&1, backend))
  end

  defp find_parent(%LanguageTag{language: language}, backend) do
    parent_locale_map()
    |> Map.get(language)
    |> known_locale(backend)
  end

  defp known_locale(locale_name, backend) do
    Enum.find(backend.known_locale_names(), &(locale_name == &1))
  end

  # If the language of the parent and default are the same
  # then return "root" to avoid loops
  defp return_parent_or_default(parent, child, backend) when is_nil(parent) do
    default_locale = Cldr.default_locale(backend)

    if child.language == default_locale.language do
      Cldr.validate_locale(@root_locale, backend)
    else
      {:ok, default_locale}
    end
  end

  defp return_parent_or_default(parent, _child, backend) do
    Cldr.validate_locale(parent, backend)
  end

  defp transfer_extensions({:ok, parent}, child) do
    {:ok, %{parent | locale: child.locale, transform: child.transform}}
  end

  defp no_parent_error(locale_name) do
    {Cldr.NoParentError, "The locale #{inspect(locale_name)} has no parent locale"}
  end

  @doc """
  Returns the effective territory for a locale.

  ## Arguments

  * `language_tag` is any language tag returned by `Cldr.Locale.new/2`
    or any `locale_name` returned by `Cldr.known_locale_names/1`. If
    the parameter is a `locale_name` then a default backend must be
    configured in `config.exs` or an exception will be raised.

  ## Returns

  * The territory to be used for localization purposes.

  ## Examples

      iex> Cldr.Locale.territory_from_locale "en-US"
      :US

      iex> Cldr.Locale.territory_from_locale "en-US-u-rg-cazzzz"
      :CA

      iex> Cldr.Locale.territory_from_locale "en-US-u-rg-xxxxx"
      :US

  ## Notes

  A locale can reflect the desired territory to be used
  when determining region-specific defaults for items such
  as:

  * default currency,
  * default calendar and week data,
  * default time cycle, and
  * default measurement system and unit preferences

  Territory information is stored in the locale in up to three
  different places:

  1. The `:territory` extracted from the locale name or
     defined by default for a given language. This is the typical
     use case when locale names such as `en-US` or `es-AR` are
     used.

  2. In some cases it might be desirable to override the territory
     derived from the locale name. For example, the default
     territory for the language "en" is "US" but it may be desired
     to apply the defaults for the territory "AU" instead, without
     otherwise changing the localization intent. In this case
     the [U extension](https://unicode.org/reports/tr35/#u_Extension) is
     used to define a
     [regional override](https://unicode.org/reports/tr35/#RegionOverride).

  3. Similarly, the [regional subdivision identifier]
     (https://unicode.org/reports/tr35/#UnicodeSubdivisionIdentifier)
     can be used to influence localization decisions. This identifier
     is not currently used in `ex_cldr` and dependent libraries
     however it is correctly parsed to support future use.

  """
  @spec territory_from_locale(LanguageTag.t() | locale_name()) :: Cldr.territory()

  @doc since: "2.18.2"

  def territory_from_locale(%LanguageTag{locale: %{region_override: _}} = language_tag) do
    language_tag.locale.region_override ||
      language_tag.territory ||
      Cldr.default_territory()
  end

  def territory_from_locale(%LanguageTag{} = language_tag) do
    language_tag.territory ||
      Cldr.default_territory()
  end

  def territory_from_locale(locale_name) when is_binary(locale_name) do
    territory_from_locale(locale_name, Cldr.default_backend!())
  end

  @doc """
  Returns the effective territory for a locale.

  ## Arguments

  * `locale_name` is any locale name returned by
    `Cldr.known_locale_names/1`.

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module.

  ## Returns

  * The territory to be used for localization purposes or
    `{:error, {exception, reason}}`.

  ## Examples

      iex> Cldr.Locale.territory_from_locale "en-US", TestBackend.Cldr
      :US

      iex> Cldr.Locale.territory_from_locale "en-US-u-rg-cazzzz", TestBackend.Cldr
      :CA

      iex> Cldr.Locale.territory_from_locale "en-US-u-rg-xxxxx", TestBackend.Cldr
      :US

  ## Notes

  A locale can reflect the desired territory to be used
  when determining region-specific defaults for items such
  as:

  * default currency,
  * default calendar and week data,
  * default time cycle, and
  * default measurement system and unit preferences

  Territory information is stored in the locale in up to three
  different places:

  1. The `:territory` extracted from the locale name or
     defined by default for a given language. This is the typical
     use case when locale names such as `en-US` or `es-AR` are
     used.

  2. In some cases it might be desirable to override the territory
     derived from the locale name. For example, the default
     territory for the language "en" is "US" but it may be desired
     to apply the defaults for the territory "AU" instead, without
     otherwise changing the localization intent. In this case
     the [U extension](https://unicode.org/reports/tr35/#u_Extension) is
     used to define a
     [regional override](https://unicode.org/reports/tr35/#RegionOverride).

  3. Similarly, the [regional subdivision identifier]
     (https://unicode.org/reports/tr35/#UnicodeSubdivisionIdentifier)
     can be used to influence localization decisions. This identifier
     is not currently used in `ex_cldr` and dependent libraries
     however it is correctly parsed to support future use.

  """

  @spec territory_from_locale(locale_name(), Cldr.backend()) ::
          Cldr.territory() | {:error, {module(), String.t()}}

  @doc since: "2.18.2"

  def territory_from_locale(locale, backend) when is_binary(locale) do
    with {:ok, locale} <- Cldr.validate_locale(locale, backend) do
      territory_from_locale(locale)
    end
  end

  @doc """
  Returns the effective time zone for a locale.

  ## Arguments

  * `language_tag` is any language tag returned by `Cldr.Locale.new/2`
    or any `locale_name` returned by `Cldr.known_locale_names/1`. If
    the parameter is a `locale_name` then a default backend must be
    configured in `config.exs` or an exception will be raised.

  ## Returns

  * The time zone ID as a `String.t` or `{:error, {exception, reason}}`

  ## Examples

      iex> Cldr.Locale.timezone_from_locale "en-US-u-tz-ausyd"
      "Australia/Sydney"

      iex> Cldr.Locale.timezone_from_locale "en-AU"
      {:error,
       {Cldr.AmbiguousTimezoneError,
        "Cannot determine the timezone since the territory :AU has 24 timezone IDs"}}

  """

  @spec timezone_from_locale(LanguageTag.t() | locale_name()) ::
          String.t() | {:error, {module(), String.t()}}

  @doc since: "2.19.0"

  def timezone_from_locale(%LanguageTag{locale: %{timezone: timezone}})
      when not is_nil(timezone) do
    case Cldr.Timezone.validate_timezone(timezone) do
      {:ok, zone} -> zone
    end
  end

  def timezone_from_locale(%LanguageTag{} = language_tag) do
    territory = territory_from_locale(language_tag)

    with {:ok, [zone]} <- Cldr.Timezone.timezones_for_territory(territory) do
      zone
    else
      {:ok, zones} -> ambiguous_timezone_error(territory, zones)
      _ -> Cldr.unknown_territory_error(territory)
    end
  end

  def timezone_from_locale(locale_name) when is_binary(locale_name) do
    timezone_from_locale(locale_name, Cldr.default_backend!())
  end

  @doc """
  Returns the effective time zone for a locale.

  ## Arguments

  * `locale_name` is any name returned by `Cldr.known_locale_names/1`

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module

  ## Returns

  * The time zone ID as a `String.t` or `{:error, {exception, reason}}`

  ## Examples

      iex> Cldr.Locale.timezone_from_locale "en-US-u-tz-ausyd", TestBackend.Cldr
      "Australia/Sydney"

      iex> Cldr.Locale.timezone_from_locale "en-AU", TestBackend.Cldr
      {:error,
       {Cldr.AmbiguousTimezoneError,
        "Cannot determine the timezone since the territory :AU has 24 timezone IDs"}}

  """

  @spec timezone_from_locale(locale_name(), Cldr.backend()) ::
          String.t() | {:error, {module(), String.t()}}

  @doc since: "2.19.0"

  def timezone_from_locale(locale, backend) when is_binary(locale) do
    with {:ok, locale} <- Cldr.validate_locale(locale, backend) do
      timezone_from_locale(locale)
    end
  end

  defp ambiguous_timezone_error(territory, zones) do
    zone_count = length(zones)

    {:error,
     {Cldr.AmbiguousTimezoneError,
      "Cannot determine the timezone since the territory #{inspect(territory)} " <>
        "has #{zone_count} timezone IDs"}}
  end

  @doc """
  Parses a locale name and returns a `Cldr.LanguageTag` struct
  that represents a locale.

  ## Arguments

  * `language_tag` is any language tag returned by `Cldr.Locale.new/2`
    or any `locale_name` returned by `Cldr.known_locale_names/1`

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module

  ## Returns

  * `{:ok, language_tag}` or

  * `{:eror, reason}`

  ## Method

  1. The language tag is parsed in accordance with [RFC5646](https://tools.ietf.org/html/rfc5646)

  2. Any language, script or region aliases are replaced. This
     will replace any obsolete elements with current versions

  3. If a territory or script is not specified, a default is provided
     using the CLDR information returned by `Cldr.Locale.likely_subtags/1`

  4. A `Cldr` locale name is selected that is the nearest fit to the
     requested locale.

  ## Example

      iex> Cldr.Locale.canonical_language_tag("en", TestBackend.Cldr)
      {
        :ok,
        %Cldr.LanguageTag{
          backend: TestBackend.Cldr,
          canonical_locale_name: "en",
          cldr_locale_name: "en",
          extensions: %{},
          gettext_locale_name: "en",
          language: "en",
          locale: %{},
          private_use: [],
          rbnf_locale_name: "en",
          requested_locale_name: "en",
          script: "Latn",
          territory: :US,
          transform: %{},
          language_variants: []
        }
      }

  """

  def canonical_language_tag(locale_name, backend) when is_binary(locale_name) do
    if locale_name in backend.known_locale_names do
      Cldr.validate_locale(locale_name, backend)
    else
      case LanguageTag.parse(locale_name) do
        {:ok, language_tag} ->
          canonical_language_tag(language_tag, backend)

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  def canonical_language_tag(%LanguageTag{} = language_tag, backend) do
    supress_requested_locale_substitution? = !language_tag.language

    canonical_tag =
      language_tag
      |> put_requested_locale_name(supress_requested_locale_substitution?)
      |> substitute_aliases()
      |> put_likely_subtags()
      |> put_backend(backend)
      |> put_cldr_locale_name()
      |> put_rbnf_locale_name()
      |> put_gettext_locale_name()

    {:ok, canonical_tag}
  end

  @doc false
  def canonical_language_tag(locale_name) when is_binary(locale_name) do
    canonical_language_tag(locale_name, Cldr.default_backend!)
  end

  def canonical_language_tag(%LanguageTag{backend: nil} = language_tag) do
    canonical_language_tag(language_tag, Cldr.default_backend!())
  end

  def canonical_language_tag(%LanguageTag{backend: backend} = language_tag) do
    canonical_language_tag(language_tag, backend)
  end

  @doc """
  Parses a locale name and returns a `Cldr.LanguageTag` struct
  that represents a locale or raises on error.

  ## Arguments

  * `language_tag` is any language tag returned by `Cldr.Locale.new/2`
    or any `locale_name` returned by `Cldr.known_locale_names/1`

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module

  See `Cldr.Locale.canonical_language_tag/2` for more information.

  """
  @spec canonical_language_tag!(locale_name | Cldr.LanguageTag.t(), Cldr.backend()) ::
          Cldr.LanguageTag.t() | none()

  def canonical_language_tag!(language_tag, backend) do
    case canonical_language_tag(language_tag, backend) do
      {:ok, canonical_tag} -> canonical_tag
      {:error, {exception, reason}} -> raise exception, reason
    end
  end

  def canonical_language_tag!(language_tag) do
    case canonical_language_tag(language_tag) do
      {:ok, canonical_tag} -> canonical_tag
      {:error, {exception, reason}} -> raise exception, reason
    end
  end

  @doc """
  Substitute deprectated subtags with a `Cldr.LanguageTag` with their
  non-deprecated alternatives.

  ## Arguments

  * `language_tag` is any language tag returned by `Cldr.Locale.new/2`

  ## Method

  * Replace any deprecated subtags with their canonical values using the alias
    data. Use the first value in the replacement list, if
    it exists. Language tag replacements may have multiple parts, such as
    `sh` ➞ `sr_Latn` or `mo` ➞ `ro_MD`. In such a case, the original script and/or
    region/territory are retained if there is one. Thus `sh_Arab_AQ` ➞ `sr_Arab_AQ`, not
    `sr_Latn_AQ`.

  * Remove the script code 'Zzzz' and the territory code 'ZZ' if they occur.

  * Get the components of the cleaned-up source tag (languages, scripts, and
    regions/territories), plus any variants and extensions.

  ## Example

      iex> Cldr.Locale.substitute_aliases Cldr.LanguageTag.Parser.parse!("mo")
      %Cldr.LanguageTag{
        backend: nil,
        canonical_locale_name: "ro",
        cldr_locale_name: nil,
        extensions: %{},
        gettext_locale_name: nil,
        language: "ro",
        language_subtags: [],
        language_variants: [],
        locale: %{}, private_use: [],
        rbnf_locale_name: nil,
        requested_locale_name: "mo",
        script: nil, transform: %{},
        territory: nil
      }

  """
  def substitute_aliases(%LanguageTag{} = language_tag) do
    updated_tag =
      language_tag
      |> substitute(:requested_name)
      |> substitute(:language)
      |> substitute(:variant)
      |> substitute(:script)
      |> substitute(:territory)
      |> remove_unknown(:script)
      |> remove_unknown(:territory)
      |> put_canonical_locale_name()

    if updated_tag == language_tag do
      updated_tag
    else
      substitute_aliases(updated_tag)
    end
  end

  defp substitute(%LanguageTag{canonical_locale_name: locale} = language_tag, :requested_name)
       when not is_nil(locale) do
    locale_name = locale_name_from(language_tag.language, nil, language_tag.territory, [])

    if replacement_tag = aliases(locale_name, :language) do
      type_tag = Cldr.LanguageTag.Parser.parse!(locale_name)

      replacement_tag =
        Map.put(replacement_tag, :language_variants, language_tag.language_variants)

      merge_language_tags(replacement_tag, language_tag, type_tag)
    else
      language_tag
    end
  end

  defp substitute(%LanguageTag{requested_locale_name: locale} = language_tag, :requested_name) do
    if replacement_tag = aliases(locale, :language) do
      type_tag = Cldr.LanguageTag.Parser.parse!(locale)
      merge_language_tags(replacement_tag, language_tag, type_tag)
    else
      language_tag
    end
  end

  # No variants so we just check the language for an alias
  defp substitute(%LanguageTag{language_variants: []} = language_tag, :language) do
    if replacement_tag = aliases(language_tag.language, :language) do
      type_tag = Cldr.LanguageTag.Parser.parse!(language_tag.language)
      merge_language_tags(replacement_tag, language_tag, type_tag)
    else
      language_tag
    end
  end

  # One or more language variants which, when combined with the language,
  # may have an alias
  defp substitute(%LanguageTag{language_variants: variants} = language_tag, :language) do
    variants = variant_selectors(variants)
    language = language_tag.language

    {type_tag, replacement_tag} = find_language_alias(language, variants, :language)

    if replacement_tag do
      merge_language_tags(replacement_tag, language_tag, type_tag)
    else
      language_tag
    end
  end

  defp substitute(%LanguageTag{language_variants: []} = language_tag, :variant) do
    language_tag
  end

  defp substitute(%LanguageTag{language_variants: [variant]} = language_tag, :variant) do
    {type_tag, replacement_tag} =
      find_alias([[variant]], :variant) || find_language_alias("und", [variant], :language)

    merge_variants(replacement_tag, language_tag, type_tag)
  end

  defp substitute(%LanguageTag{language_variants: variants} = language_tag, :variant) do
    variants = variant_selectors(variants)
    {type_tag, replacement_tag} = find_alias(variants, :variant)

    if replacement_tag do
      merge_variants(replacement_tag, language_tag, type_tag)
    else
      language_tag
    end
  end

  defp substitute(%LanguageTag{script: script} = language_tag, :script) do
    %{language_tag | script: aliases(script, :script) || script}
  end

  defp substitute(%LanguageTag{territory: territory} = language_tag, :territory) do
    territory =
      case aliases(territory, :region) || territory do
        territories when is_list(territories) -> hd(territories)
        territory when is_atom(territory) -> territory
        other -> String.to_existing_atom(other)
      end

    %{language_tag | territory: territory}
  rescue
    ArgumentError ->
      language_tag
  end

  defp remove_unknown(%LanguageTag{script: "Zzzz"} = language_tag, :script) do
    %{language_tag | script: nil}
  end

  defp remove_unknown(%LanguageTag{} = language_tag, :script), do: language_tag

  defp remove_unknown(%LanguageTag{territory: "ZZ"} = language_tag, :territory) do
    %{language_tag | territory: nil}
  end

  defp remove_unknown(%LanguageTag{} = language_tag, :territory), do: language_tag

  defp put_canonical_locale_name(language_tag) do
    language_tag
    |> Map.put(:canonical_locale_name, Cldr.LanguageTag.to_string(language_tag))
  end

  defp put_backend(language_tag, backend) do
    language_tag
    |> Map.put(:backend, backend)
  end

  @spec put_requested_locale_name(Cldr.LanguageTag.t(), boolean()) :: Cldr.LanguageTag.t()
  defp put_requested_locale_name(language_tag, true) do
    language_tag
  end

  defp put_requested_locale_name(language_tag, false) do
    language_tag
    |> Map.put(:requested_locale_name, locale_name_from(language_tag, false))
  end

  @spec put_cldr_locale_name(Cldr.LanguageTag.t()) :: Cldr.LanguageTag.t()
  defp put_cldr_locale_name(%LanguageTag{} = language_tag) do
    cldr_locale_name = cldr_locale_name(language_tag)
    %{language_tag | cldr_locale_name: cldr_locale_name}
  end

  @spec put_rbnf_locale_name(Cldr.LanguageTag.t()) :: Cldr.LanguageTag.t()
  defp put_rbnf_locale_name(%LanguageTag{} = language_tag) do
    rbnf_locale_name = rbnf_locale_name(language_tag)
    %{language_tag | rbnf_locale_name: rbnf_locale_name}
  end

  @spec put_gettext_locale_name(Cldr.LanguageTag.t()) :: Cldr.LanguageTag.t()
  def put_gettext_locale_name(%LanguageTag{} = language_tag) do
    gettext_locale_name = gettext_locale_name(language_tag)
    %{language_tag | gettext_locale_name: gettext_locale_name}
  end

  @spec put_gettext_locale_name(Cldr.LanguageTag.t(), Cldr.Config.t()) :: Cldr.LanguageTag.t()
  def put_gettext_locale_name(%LanguageTag{} = language_tag, config) do
    gettext_locale_name = gettext_locale_name(language_tag, config)
    %{language_tag | gettext_locale_name: gettext_locale_name}
  end

  @spec cldr_locale_name(Cldr.LanguageTag.t()) :: locale_name() | nil
  defp cldr_locale_name(%LanguageTag{} = language_tag) do
    first_match(language_tag, &Cldr.known_locale_name(&1, language_tag.backend)) ||
      Cldr.known_locale_name(language_tag.requested_locale_name, language_tag.backend)
  end

  @spec rbnf_locale_name(Cldr.LanguageTag.t()) :: locale_name | nil
  defp rbnf_locale_name(%LanguageTag{} = language_tag) do
    first_match(language_tag, &Cldr.known_rbnf_locale_name(&1, language_tag.backend))
  end

  @spec gettext_locale_name(Cldr.LanguageTag.t()) :: locale_name | nil
  defp gettext_locale_name(%LanguageTag{} = language_tag) do
    language_tag
    |> first_match(&known_gettext_locale_name(&1, language_tag.backend))
    |> locale_name_to_posix
  end

  # Used at compile time only
  defp gettext_locale_name(%LanguageTag{} = language_tag, config) do
    language_tag
    |> first_match(&known_gettext_locale_name(&1, config))
    |> locale_name_to_posix
  end

  @spec known_gettext_locale_name(locale_name(), Cldr.backend() | Cldr.Config.t()) ::
          locale_name() | false

  def known_gettext_locale_name(locale_name, backend) when is_atom(backend) do
    gettext_locales = backend.known_gettext_locale_names()
    Enum.find(gettext_locales, &(&1 == locale_name)) || false
  end

  # This clause is only called at compile time when we're
  # building a backend.  In normal use is should not be used.
  @doc false
  def known_gettext_locale_name(locale_name, config) when is_map(config) do
    gettext_locales = Cldr.Config.known_gettext_locale_names(config)
    Enum.find(gettext_locales, &(&1 == locale_name)) || false
  end

  @doc """
  Execute a function for a locale returning
  the first match on language, script, territory,
  and variant combination.

  A match is determined when the `fun/1` returns
  a `truthy` value.

  ## Arguments

  * `language_tag` is any language tag returned by
    `Cldr.Locale.new/2`.

  * `fun/1` is single-arity function that takes a string
    locale name. The locale name is a built from the language,
    script, territory and variant combinations of `language_tag`.

  ## Returns

  * The first `truthy` value returned by `fun/1` or `nil` if no
    match is made.

  """

  def first_match(%LanguageTag{} = language_tag, fun) when is_function(fun, 1) do
    %LanguageTag{
      language: language,
      script: script,
      territory: territory,
      language_variants: variants
    } = language_tag

    first_match(language, script, territory, variants, fun)
  end

  defp first_match(language, script, territory, variants, fun) do
    # Including variants
    # Not including variants
    fun.(locale_name_from(language, script, territory, variants)) ||
      fun.(locale_name_from(language, nil, territory, variants)) ||
      fun.(locale_name_from(language, script, nil, variants)) ||
      fun.(locale_name_from(language, nil, nil, variants)) ||
      fun.(locale_name_from(language, script, territory, [])) ||
      fun.(locale_name_from(language, nil, territory, [])) ||
      fun.(locale_name_from(language, script, nil, [])) ||
      fun.(locale_name_from(language, nil, nil, [])) || nil
  end

  @doc """
  Return a locale name from a `Cldr.LanguageTag`

  ## Options

  * `locale_name` is any `Cldr.LanguageTag` struct returned by
    `Cldr.Locale.new!/2`

  ## Example

      iex> Cldr.Locale.locale_name_from Cldr.Locale.new!("en", TestBackend.Cldr)
      "en"

  """
  @spec locale_name_from(Cldr.LanguageTag.t()) :: locale_name()

  # TODO proper formation of a canonical name required
  def locale_name_from(language_tag, omit_singular_script? \\ true)

  def locale_name_from(%LanguageTag{canonical_locale_name: nil} = tag, omit_singular_script?) do
    locale_name_from(
      tag.language,
      tag.script,
      tag.territory,
      tag.language_variants,
      omit_singular_script?
    )
  end

  def locale_name_from(
        %LanguageTag{canonical_locale_name: canonical_locale_name},
        _omit_singular_script?
      ) do
    canonical_locale_name
  end

  @doc """
  Return a locale name by combining language, script, territory and variant
  parameters

  ## Arguments

  * `language`, `script`, `territory` are string
    representations, or `nil`, of the language subtags

  * `variants` is a list of language variants or `[]`

  ## Returns

  * The locale name constructed from the non-nil arguments joined
    by a "-"

  ## Example

      iex> Cldr.Locale.locale_name_from("en", "Latn", "001", [])
      "en-001"

      iex> Cldr.Locale.locale_name_from("en", "Latn", :"001", [])
      "en-001"

  """
  @spec locale_name_from(language(), script(), Cldr.territory() | territory(), variants()) ::
          locale_name()

  # TODO Should not be required - delete this
  # need a proper formation of the canonical name
  def locale_name_from(language, script, territory, variants, omit_singular_scipt? \\ true) do
    Cldr.Config.locale_name_from(language, script, territory, variants, omit_singular_scipt?)
  end

  @doc """
  Replace empty subtags within a `t:Cldr.LanguageTag.t/0` with the most likely
  subtag.

  ## Options

  * `language_tag` is any language tag returned by `Cldr.Locale.new/2`

  A subtag is called empty if it has a missing script or territory subtag, or it is
  a base language subtag with the value `und`. In the description below,
  a subscript on a subtag x indicates which tag it is from: x<sub>s</sub> is in the
  source, x<sub>m</sub> is in a match, and x<sub>r</sub> is in the final result.

  ## Lookup

  Lookup each of the following in order, and stops on the first match:

  * language<sub>s</sub>-script<sub>s</sub>-region<sub>s</sub>
  * language<sub>s</sub>-region<sub>s</sub>
  * language<sub>s</sub>-script<sub>s</sub>
  * language<sub>s</sub>
  * und-script<sub>s</sub>

  ## Returns

  * If there is no match,either return
    * an error value, or
    * the match for `und`

  * Otherwise there is a match = language<sub>m</sub>-script<sub>m</sub>-region<sub>m</sub>

  * Let x<sub>r</sub> = x<sub>s</sub> if x<sub>s</sub> is not empty, and x<sub>m</sub> otherwise.

  * Return the language tag composed of language<sub>r</sub>-script<sub>r</sub>-region<sub>r</sub> + variants + extensions .

  ## Example

      iex> Cldr.Locale.put_likely_subtags Cldr.LanguageTag.parse!("zh-SG")
      %Cldr.LanguageTag{
        backend: nil,
        canonical_locale_name: nil,
        cldr_locale_name: nil,
        language_subtags: [],
        extensions: %{},
        gettext_locale_name: nil,
        language: "zh",
        locale: %{},
        private_use: [],
        rbnf_locale_name: nil,
        requested_locale_name: "zh-SG",
        script: "Hans",
        territory: "SG",
        transform: %{},
        language_variants: []
      }

  """
  def put_likely_subtags(%LanguageTag{} = language_tag) do
    %LanguageTag{language: language, script: script, territory: territory} = language_tag

    subtags =
      likely_subtags(locale_name_from(language, script, territory, [])) ||
        likely_subtags(locale_name_from(language, nil, territory, [])) ||
        likely_subtags(locale_name_from(language, script, nil, [])) ||
        likely_subtags(locale_name_from(language, nil, nil, [])) ||
        likely_subtags(locale_name_from("und", script, nil, [])) ||
        likely_subtags(locale_name_from("und", nil, nil, []))

    Map.merge(subtags, language_tag, fn _k, v1, v2 -> if empty?(v2), do: v1, else: v2 end)
  end

  @merge_fields [:language, :script, :territory, :language_variants]
  defp merge_language_tags(replacement_tag, source_tag, type_tag) do
    Map.merge(replacement_tag, source_tag, fn
      _k, "und", source_field ->
        source_field

      k, replacement_field, source_field when k in @merge_fields ->
        # IO.inspect k, label: "Field"
        type_field = type_field_from(type_tag, k) # |> IO.inspect(label: "Type")
        replacement_field = field_from(replacement_field)# |> IO.inspect(label: "Replacement")
        source_field = field_from(source_field, k) # |> IO.inspect(label: "Source")
        replaced = replace(source_field, replacement_field, type_field)

        if k == :language_variants || replaced == [], do: replaced, else: hd(replaced)

      _k, _replacement_field, source_field ->
        source_field
    end)
  end

  defp merge_variants(replacement, source_tag, type_tag) do
    type_field = type_field_from(type_tag, :language_variants)
    replacement_field = type_field_from(replacement, :language_variants)
    source_field = type_field_from(source_tag, :language_variants)
    replaced = replace(source_field, replacement_field, type_field)

    %{source_tag | language_variants: replaced}
  end

  # From TR35 https://unicode-org.github.io/cldr/ldml/tr35.html#replacement
  # if type.field ≠ {}
  #   source.field = (source.field - type.field) ∪ replacement.field
  # else if source.field = {} and replacement.field ≠ {}
  #   source.field = replacement.field
  #
  defp replace(source_field, replacement_field, [_ | _] = type_field) do
    (source_field -- type_field) ++ replacement_field
    # |> Enum.sort
  end

  defp replace([], [_ | _] = replacement_field, _type_field) do
    replacement_field
  end

  defp replace(source_field, _replacement_field, _type_field) do
    source_field
  end

  defp type_field_from(nil, _), do: []

  defp type_field_from(tag, :language_variants = key) do
    Map.fetch!(tag, key)
  end

  defp type_field_from(tag, :territory = key) do
    case Map.fetch!(tag, key) do
      nil -> []
      other -> [String.to_existing_atom(other)]
    end
  end

  defp type_field_from(tag, key) do
    case Map.fetch!(tag, key) do
      nil -> []
      other -> [other]
    end
  end

  defp field_from(nil), do: []
  defp field_from(field) when is_list(field), do: field
  defp field_from(field), do: [field]

  defp field_from(field, :territory) when is_binary(field) do
    case Integer.parse(field) do
      {int, ""} when int in 0..999 -> [String.to_atom(field)]
      _other -> [String.to_existing_atom(field)]
    end
  end

  defp field_from(field, _), do: field_from(field)

  # This will crash if there are more than 4 variants
  # which is possible but highly unlikely
  defp variant_selectors([a]),
    do: [[a]]

  defp variant_selectors([a, b]),
    do: [[a, b], [a], [b]]

  defp variant_selectors([a, b, c]),
    do: [[a, b, c], [a, b], [a, c], [b, c], [a], [b], [c]]

  defp variant_selectors([a, b, c, d]),
    do: [
      [a, b, c, d],
      [a, b, c],
      [a, c, d],
      [b, c, d],
      [a, b],
      [a, c],
      [a, d],
      [b, c],
      [b, d],
      [c, d],
      [a],
      [b],
      [c],
      [d]
    ]

  defp sort_variants(language, variants) do
    Enum.flat_map(variants, &[[language | &1], ["und" | &1]])
    |> Enum.sort(fn
      ["und" | rest1], ["und" | rest2] ->
        if length(rest1) == length(rest2),
          do: rest1 < rest2,
          else: length(rest1) > length(rest2)

      ["und" | rest1], rest2 ->
        if length(rest1) == length(rest2),
          do: rest1 < rest2,
          else: length(rest1) > length(rest2)

      rest1, ["und" | rest2] ->
        if length(rest1) == length(rest2),
          do: rest1 < rest2,
          else: length(rest1) > length(rest2)

      rest1, rest2 ->
        if length(rest1) == length(rest2),
          do: rest1 < rest2,
          else: length(rest1) > length(rest2)
    end)
    |> List.insert_at(0, [language])

    # |> IO.inspect
  end

  defp find_language_alias(language, variants, type) do
    variants = sort_variants(language, variants)

    Enum.reduce_while(variants, {nil, nil}, fn variant, acc ->
      alias_key = Enum.join(variant, "-")

      if alias_tag = aliases(alias_key, type) do
        type_field = Cldr.LanguageTag.Parser.parse!(alias_key)
        {:halt, {type_field, alias_tag}}
      else
        {:cont, acc}
      end
    end)
  end

  defp find_alias(variants, type) do
    Enum.reduce_while(variants, {nil, nil}, fn variant, acc ->
      alias_key = Enum.join(variant, "-")

      if alias_tag = aliases(alias_key, type) do
        type_tag = Cldr.LanguageTag.Parser.parse!("und-" <> alias_key)
        replacement_tag = Cldr.LanguageTag.Parser.parse!("und-" <> alias_tag)
        {:halt, {type_tag, replacement_tag}}
      else
        {:cont, acc}
      end
    end)
  end

  @doc """
  Returns an error tuple for an invalid locale.

  ## Arguments

    * `locale_name` is any locale name returned by `Cldr.known_locale_names/1`

  ## Returns

  * `{:error, {Cldr.UnknownLocaleError, message}}`

  ## Examples

      iex> Cldr.Locale.locale_error :invalid
      {Cldr.UnknownLocaleError, "The locale :invalid is not known."}

  """
  @spec locale_error(locale_name() | LanguageTag.t()) :: {Cldr.UnknownLocaleError, String.t()}
  def locale_error(%LanguageTag{requested_locale_name: requested_locale_name}) do
    locale_error(requested_locale_name)
  end

  def locale_error(locale_name) do
    {Cldr.UnknownLocaleError, "The locale #{inspect(locale_name)} is not known."}
  end

  @doc """
  Returns an error tuple for an invalid gettext locale.

  ## Options

    * `locale_name` is any locale name returned by `Cldr.known_gettext_locale_names/1`

  ## Returns

  * `{:error, {Cldr.UnknownLocaleError, message}}`

  ## Examples

      iex> Cldr.Locale.gettext_locale_error :invalid
      {Cldr.UnknownLocaleError, "The gettext locale :invalid is not known."}

  """
  @spec gettext_locale_error(locale_name() | LanguageTag.t()) ::
          {Cldr.UnknownLocaleError, String.t()}
  def gettext_locale_error(%LanguageTag{gettext_locale_name: gettext_locale_name}) do
    gettext_locale_error(gettext_locale_name)
  end

  def gettext_locale_error(locale_name) do
    {Cldr.UnknownLocaleError, "The gettext locale #{inspect(locale_name)} is not known."}
  end

  @doc """
  Returns the map of likely subtags.

  Note that not all locales are guaranteed
  to have likely subtags.

  ## Example

      Cldr.Locale.likely_subtags
      %{
        "bez" => %Cldr.LanguageTag{
          backend: TestBackend.Cldr,
          canonical_locale_name: nil,
          cldr_locale_name: nil,
          extensions: %{},
          language: "bez",
          locale: %{},
          private_use: [],
          rbnf_locale_name: nil,
          requested_locale_name: nil,
          script: "Latn",
          territory: :TZ,
          transform: %{},
          language_variants: []
        },
        "fuf" => %Cldr.LanguageTag{
          canonical_locale_name: nil,
          cldr_locale_name: nil,
          extensions: %{},
          language: "fuf",
          locale: %{},
          private_use: [],
          rbnf_locale_name: nil,
          requested_locale_name: nil,
          script: "Latn",
          territory: :GN,
          transform: %{},
          language_variants: []
        },
        ...

  """
  @likely_subtags Cldr.Config.likely_subtags()
  def likely_subtags do
    @likely_subtags
  end

  @doc """
  Returns the likely substags, as a `Cldr.LanguageTag`,
  for a given locale name.

  ## Options

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/1`
    or a `Cldr.LanguageTag` struct

  ## Examples

      iex> Cldr.Locale.likely_subtags "en"
      %Cldr.LanguageTag{
        backend: nil,
        canonical_locale_name: nil,
        cldr_locale_name: nil,
        extensions: %{},
        gettext_locale_name: nil,
        language: "en",
        locale: %{},
        private_use: [],
        rbnf_locale_name: nil,
        requested_locale_name: "en-Latn-US",
        script: "Latn",
        territory: :US,
        transform: %{},
        language_variants: []
      }

  """
  @spec likely_subtags(locale_name) :: LanguageTag.t() | nil
  def likely_subtags(locale_name) when is_binary(locale_name) do
    Map.get(likely_subtags(), locale_name)
  end

  def likely_subtags(%LanguageTag{requested_locale_name: requested_locale_name}) do
    likely_subtags(requested_locale_name)
  end

  @doc """
  Return a map of the known aliases for Language, Script and Territory
  """
  @aliases Cldr.Config.aliases()
  @spec aliases :: map()
  def aliases do
    @aliases
  end

  @doc """
  Return a map of the aliases for a given alias key and type

  ## Options

  * `type` is one of `[:language, :region, :script, :variant, :zone]`

  * `key` is the substitution key (a language, region, script, variant or zone)

  """
  @alias_keys Map.keys(@aliases)
  @spec aliases(locale_name(), atom()) :: map() | nil

  def aliases(key, :region = type) do
    aliases()
    |> Map.get(type)
    |> Map.get(to_string(key))
  end

  def aliases(key, type) when type in @alias_keys do
    aliases()
    |> Map.get(type)
    |> Map.get(key)
  end

  @doc """
  Returns an error tuple for an invalid locale alias.

  ## Options

    * `locale_name` is any locale name returned by `Cldr.known_locale_names/1`

  """
  @spec alias_error(locale_name() | LanguageTag.t(), String.t()) ::
          {Cldr.UnknownLocaleError, String.t()}

  def alias_error(locale_name, alias_name) when is_binary(locale_name) do
    {
      Cldr.UnknownLocaleError,
      "The locale #{inspect(locale_name)} and its " <>
        "alias #{inspect(alias_name)} are not known."
    }
  end

  def alias_error(%LanguageTag{requested_locale_name: requested_locale_name}, alias_name) do
    alias_error(requested_locale_name, alias_name)
  end
end
