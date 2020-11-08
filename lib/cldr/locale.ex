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
    such as `ca-ES-VALENCIA` and `en-US-POSIX`.

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
        canonical_locale_name: "en-Latn-ES",
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
        language_variant: nil
      }}

  ### Matching locales to requested locale names

  When attempting to match the requested locale name to a configured
  locale, `Cldr` attempt to match against a set of reductions in the
  following order and will return the first match:

  * language, script, territory, variant
  * language, territory, variant
  * language, script, variant
  * language, variant
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
        language_variant: nil,
        locale: %{}, private_use: [],
        rbnf_locale_name: "ro",
        requested_locale_name: "mo",
        script: "Latn",
        transform: %{},
        canonical_locale_name: "ro-Latn-RO",
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
        territory: :US,
        transform: %{},
        language_variant: nil
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
        territory: :US,
        transform: %{},
        language_variant: nil
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
          canonical_locale_name: "en-Latn-AU",
          cldr_locale_name: "en-AU",
          extensions: %{},
          gettext_locale_name: "en",
          language: "en",
          language_subtags: '',
          language_variant: nil,
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
            timezone: "Australia/Sydney",
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
  @type variant :: String.t() | nil
  @type subtags :: [String.t(), ...] | []

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

            iex> #{inspect __MODULE__}.territory_from_locale "en-US"
            :US

            iex> #{inspect __MODULE__}.territory_from_locale "en-US-u-rg-GBzzzz"
            :GB

        """
        @spec territory_from_locale(Cldr.LanguageTag.t() | Cldr.Locale.locale_name()) ::
          Cldr.territory

        def territory_from_locale(locale) when is_binary(locale) do
          Cldr.Locale.territory_from_locale(locale, unquote(config.backend))
        end

        def territory_from_locale(%LanguageTag{} = locale) do
          Cldr.Locale.territory_from_locale(locale)
        end

      end
    end
  end

  defdelegate new(locale_name, backend), to: __MODULE__, as: :canonical_language_tag
  defdelegate new!(locale_name, backend), to: __MODULE__, as: :canonical_language_tag!

  defdelegate locale_name_to_posix(locale_name), to: Cldr.Config
  defdelegate locale_name_from_posix(locale_name), to: Cldr.Config

  @doc """
  Returns the effective territory for a locale.

  ## Arguments

  * `language_tag` is any language tag returned by `Cldr.Locale.new/2`
    or any `locale_name` returned by `Cldr.known_locale_names/1`

  ## Returns

  * The territory to be used for localization purposes

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
     [regional override](https://unicode.org/reports/tr35/#RegionOverride)

  3. Similarly, the [regional subdivision identifier]
     (https://unicode.org/reports/tr35/#UnicodeSubdivisionIdentifier)
     can be used to influence localization decisions. This identifier
     is not currently used in `ex_cldr` and dependent libraries
     however it is correctly parsed to support future use.

  """
  @spec territory_from_locale(LanguageTag.t() | locale_name()) :: Cldr.territory()

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

  @spec territory_from_locale(locale_name(), Cldr.backend()) ::
          Cldr.territory() | {:error, {module(), String.t()}}

  def territory_from_locale(locale, backend) when is_binary(locale) do
    with {:ok, locale} <- Cldr.validate_locale(locale, backend) do
      territory_from_locale(locale)
    end
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
          territory: :US,
          transform: %{},
          language_variant: nil
        }
      }

  """

  def canonical_language_tag(locale_name, backend)
      when is_binary(locale_name) do
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
      |> substitute_aliases
      |> add_likely_subtags

    canonical_tag =
      canonical_tag
      |> Map.put(:canonical_locale_name, locale_name_from(canonical_tag))
      |> Map.put(:backend, backend)
      |> put_cldr_locale_name(backend)
      |> put_rbnf_locale_name(backend)
      |> put_gettext_locale_name(backend)

    {:ok, canonical_tag}
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

  @spec put_requested_locale_name(Cldr.LanguageTag.t(), boolean()) :: Cldr.LanguageTag.t()
  defp put_requested_locale_name(language_tag, true) do
    language_tag
  end

  defp put_requested_locale_name(language_tag, false) do
    Map.put(language_tag, :requested_locale_name, locale_name_from(language_tag))
  end

  @spec put_cldr_locale_name(Cldr.LanguageTag.t(), Cldr.backend()) :: Cldr.LanguageTag.t()
  defp put_cldr_locale_name(%LanguageTag{} = language_tag, backend) do
    cldr_locale_name = cldr_locale_name(language_tag, backend)
    %{language_tag | cldr_locale_name: cldr_locale_name}
  end

  @spec put_rbnf_locale_name(Cldr.LanguageTag.t(), Cldr.backend()) :: Cldr.LanguageTag.t()
  defp put_rbnf_locale_name(%LanguageTag{} = language_tag, backend) do
    rbnf_locale_name = rbnf_locale_name(language_tag, backend)
    %{language_tag | rbnf_locale_name: rbnf_locale_name}
  end

  @spec put_gettext_locale_name(Cldr.LanguageTag.t(), Cldr.backend()) :: Cldr.LanguageTag.t()
  def put_gettext_locale_name(%LanguageTag{} = language_tag, backend) do
    gettext_locale_name = gettext_locale_name(language_tag, backend)
    %{language_tag | gettext_locale_name: gettext_locale_name}
  end

  @spec cldr_locale_name(Cldr.LanguageTag.t(), Cldr.backend()) :: locale_name() | nil
  defp cldr_locale_name(%LanguageTag{} = language_tag, backend) do
    first_match(language_tag, &Cldr.known_locale_name(&1, backend)) ||
      Cldr.known_locale_name(language_tag.requested_locale_name, backend)
  end

  @spec rbnf_locale_name(Cldr.LanguageTag.t(), Cldr.backend()) :: locale_name | nil
  defp rbnf_locale_name(%LanguageTag{} = language_tag, backend) do
    first_match(language_tag, &Cldr.known_rbnf_locale_name(&1, backend))
  end

  @spec gettext_locale_name(Cldr.LanguageTag.t(), Cldr.backend()) :: locale_name | nil
  defp gettext_locale_name(%LanguageTag{} = language_tag, backend) do
    language_tag
    |> first_match(&known_gettext_locale_name(&1, backend))
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

  defp first_match(
         %LanguageTag{
           language: language,
           script: script,
           territory: territory,
           language_variant: variant
         },
         fun
       )
       when is_function(fun) do
    # Including variant
    # Not including variant
    fun.(locale_name_from(language, script, territory, variant)) ||
      fun.(locale_name_from(language, nil, territory, variant)) ||
      fun.(locale_name_from(language, script, nil, variant)) ||
      fun.(locale_name_from(language, nil, nil, variant)) ||
      fun.(locale_name_from(language, script, territory, nil)) ||
      fun.(locale_name_from(language, nil, territory, nil)) ||
      fun.(locale_name_from(language, script, nil, nil)) ||
      fun.(locale_name_from(language, nil, nil, nil)) || nil
  end

  @doc """
  Normalize the casing of a locale name.

  ## Options

  * `locale_name` is any valid locale name returned by `Cldr.known_locale_names/1`
    or a `Cldr.LanguageTag` struct

  ## Returns

  * The normalized locale name as a `String.t`

  ## Method

  Locale names are case insensitive but certain common
  casing is followed in practise:

  * lower case for a language
  * capital case for a script
  * upper case for a region/territory

  **Note** this function is intended to support only the CLDR
  locale names which have a format that is a subset of the full
  langauge tag specification.

  For proper parsing of local names and language tags, see
  `Cldr.Locale.canonical_language_tag/2`

  ## Examples

      iex> Cldr.Locale.normalize_locale_name "zh_hant"
      "zh-Hant"

      iex> Cldr.Locale.normalize_locale_name "en_us"
      "en-US"

      iex> Cldr.Locale.normalize_locale_name "EN"
      "en"

      iex> Cldr.Locale.normalize_locale_name "ca_es_valencia"
      "ca-ES-VALENCIA"

  """
  @spec normalize_locale_name(locale_name) :: locale_name
  def normalize_locale_name(locale_name) when is_binary(locale_name) do
    case String.split(locale_name, ~r/[-_]/) do
      [lang, other] ->
        if String.length(other) == 4 do
          String.downcase(lang) <> "-" <> String.capitalize(other)
        else
          String.downcase(lang) <> "-" <> String.upcase(other)
        end

      [lang, script, region] ->
        # Its a lang-script-region
        # Its lang-region-variant
        if String.length(script) == 4 do
          String.downcase(lang) <>
            "-" <> String.capitalize(script) <> "-" <> String.upcase(region)
        else
          String.downcase(lang) <> "-" <> String.upcase(script) <> "-" <> String.upcase(region)
        end

      [lang] ->
        String.downcase(lang)

      _ ->
        locale_name_from_posix(locale_name)
    end
  end

  @doc """
  Return a locale name from a `Cldr.LanguageTag`

  ## Options

  * `locale_name` is any `Cldr.LanguageTag` struct returned by
    `Cldr.Locale.new!/2`

  ## Example

      iex> Cldr.Locale.locale_name_from Cldr.Locale.new!("en", TestBackend.Cldr)
      "en-Latn-US"

  """
  @spec locale_name_from(Cldr.LanguageTag.t()) :: locale_name()

  def locale_name_from(%LanguageTag{
        language: language,
        script: script,
        territory: territory,
        language_variant: variant
      }) do
    locale_name_from(language, script, territory, variant)
  end

  @doc """
  Return a locale name by combining language, script, territory and variant
  parameters

  ## Arguments

  * `language`, `script`, `territory` and `variant` are string
    representations, or `nil`, of the language subtags

  ## Returns

  * The locale name constructed from the non-nil arguments joined
    by a "-"

  ## Example

      iex> Cldr.Locale.locale_name_from("en", "Latn", "001", nil)
      "en-Latn-001"

      iex> Cldr.Locale.locale_name_from("en", "Latn", :"001", nil)
      "en-Latn-001"

  """
  @spec locale_name_from(language(), script(), Cldr.territory() | territory(), variant()) ::
          locale_name()

  def locale_name_from(language, script, territory, variant) do
    [language, script, territory, variant]
    |> Enum.reject(&is_nil/1)
    |> Enum.join("-")
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
        canonical_locale_name: nil,
        cldr_locale_name: nil,
        extensions: %{},
        gettext_locale_name: nil,
        language: "ro",
        language_subtags: [],
        language_variant: nil,
        locale: %{}, private_use: [],
        rbnf_locale_name: nil,
        requested_locale_name: "mo",
        script: nil, transform: %{},
        territory: nil
      }

  """
  def substitute_aliases(%LanguageTag{} = language_tag) do
    language_tag
    |> substitute(:language)
    |> substitute(:script)
    |> substitute(:territory)
    |> merge_language_tags(language_tag)
    |> remove_unknown(:script)
    |> remove_unknown(:territory)
  end

  defp substitute(%LanguageTag{language: language}, :language) do
    aliases(language, :language) || %LanguageTag{}
  end

  defp substitute(%LanguageTag{script: script} = language_tag, :script) do
    %{language_tag | script: aliases(script, :script) || script}
  end

  defp substitute(%LanguageTag{territory: territory} = language_tag, :territory) do
    %{language_tag | territory: aliases(territory, :region) || territory}
  end

  defp merge_language_tags(alias_tag, original_language_tag) do
    Map.merge(alias_tag, original_language_tag, fn
      :language, v_alias, v_original ->
        if empty?(v_alias), do: v_original, else: v_alias

      _k, v_alias, v_original ->
        if empty?(v_original), do: v_alias, else: v_original
    end)
  end

  defp remove_unknown(%LanguageTag{script: "Zzzz"} = language_tag, :script) do
    %{language_tag | script: nil}
  end

  defp remove_unknown(%LanguageTag{} = language_tag, :script), do: language_tag

  defp remove_unknown(%LanguageTag{territory: "ZZ"} = language_tag, :territory) do
    %{language_tag | territory: nil}
  end

  defp remove_unknown(%LanguageTag{} = language_tag, :territory), do: language_tag

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

      iex> Cldr.Locale.add_likely_subtags Cldr.LanguageTag.parse!("zh-SG")
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
        territory: :SG,
        transform: %{},
        language_variant: nil
      }

  """
  def add_likely_subtags(
        %LanguageTag{language: language, script: script, territory: territory} = language_tag
      ) do
    subtags =
      likely_subtags(locale_name_from(language, script, territory, nil)) ||
        likely_subtags(locale_name_from(language, nil, territory, nil)) ||
        likely_subtags(locale_name_from(language, script, nil, nil)) ||
        likely_subtags(locale_name_from(language, nil, nil, nil)) ||
        likely_subtags(locale_name_from("und", script, nil, nil)) ||
        likely_subtags(locale_name_from("und", nil, nil, nil))

    Map.merge(subtags, language_tag, fn _k, v1, v2 -> if empty?(v2), do: v1, else: v2 end)
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
          language_variant: nil
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
          language_variant: nil
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
        language_variant: nil
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
