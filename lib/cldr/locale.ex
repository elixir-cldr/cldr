defmodule Cldr.Locale do
  @moduledoc """
  Functions to parse and normalize locale names into a structure
  locale represented by`Cldr.LanguageTag`.

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

  """
  alias Cldr.LanguageTag
  import Cldr.Helpers

  @typedoc "The name of a locale in a string format"
  @type locale_name() :: String.t

  defdelegate new(locale_name), to: __MODULE__, as: :canonical_language_tag
  defdelegate new!(locale_name), to: __MODULE__, as: :canonical_language_tag!

  @doc """
  Parses a locale name and returns a `Cldr.LanguageTag` struct
  that represents a locale.

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/0`
    or a `Cldr.LanguageTag` struct

  Returns:

  * `{:ok, language_tag}` or

  * `{:eror, reason}`

  Several steps are followed to produce a canonical language tag:

  1. The language tag is parsed in accordance with [RFC5646](https://tools.ietf.org/html/rfc5646)

  2. Any language, script or region aliases are replaced. This
     will replace any obsolete elements with current versions

  3. If a territory or script is not specified, a default is provided
     using the CLDR information returned by `Cldr.Locale.likely_subtags/1`

  4. A `Cldr` locale name is selected that is the nearest fit to the
     requested locale.

  ## Example

      iex> Cldr.Locale.canonical_language_tag "en"
      {
        :ok,
        %Cldr.LanguageTag{
          canonical_locale_name: "en-Latn-US",
          cldr_locale_name: "en",
          extensions: %{},
          language: "en",
          locale: %{},
          private_use: [],
          rbnf_locale_name: "en",
          requested_locale_name: "en",
          script: "Latn",
          territory: "US",
          transform: %{},
          variant: nil
        }
      }

  """
  @spec canonical_language_tag(locale_name | LanguageTag.t) ::
    {:ok, LanguageTag.t} | {:error, {Cldr.InvalidLanguageTag, String.t}}

  def canonical_language_tag(locale_name) when is_binary(locale_name) do
    case LanguageTag.parse(locale_name) do
      {:ok, language_tag} ->
        canonical_language_tag(language_tag)
      {:error, reason} ->
        {:error, reason}
    end
  end

  def canonical_language_tag(%LanguageTag{} = language_tag) do
    canonical_tag =
      language_tag
      |> substitute_aliases
      |> add_likely_subtags

    canonical_tag =
      canonical_tag
      |> Map.put(:requested_locale_name, locale_name_from(language_tag))
      |> Map.put(:canonical_locale_name, locale_name_from(canonical_tag))
      |> set_cldr_locale_name
      |> set_rbnf_locale_name

    {:ok, canonical_tag}
  end

  @doc """
  Parses a locale name and returns a `Cldr.LanguageTag` struct
  that represents a locale or raises on error.

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/0`
    or a `Cldr.LanguageTag` struct

  See `Cldr.Locale.canonical_language_tag/1` for more information.

  """
  @spec canonical_language_tag!(locale_name | LanguageTag.t) :: LanguageTag.t | none()
  def canonical_language_tag!(language_tag) do
    case canonical_language_tag(language_tag) do
      {:ok, canonical_tag} -> canonical_tag
      {:error, {exception, reason}} -> raise exception, reason
    end
  end

  @spec set_cldr_locale_name(LanguageTag.t) :: LanguageTag.t
  defp set_cldr_locale_name(%LanguageTag{} = language_tag) do
    cldr_locale_name = cldr_locale_name(language_tag)
    %{language_tag | cldr_locale_name: cldr_locale_name}
  end

  @spec set_rbnf_locale_name(LanguageTag.t) :: LanguageTag.t
  defp set_rbnf_locale_name(%LanguageTag{} = language_tag) do
    rbnf_locale_name = rbnf_locale_name(language_tag)
    %{language_tag | rbnf_locale_name: rbnf_locale_name}
  end

  @spec cldr_locale_name(LanguageTag.t) :: locale_name | nil
  defp cldr_locale_name(%LanguageTag{language: language, script: script,
      territory: territory, variant: variant} = language_tag) do
    Cldr.known_locale_name(locale_name_from(language, script, territory, variant)) ||
    Cldr.known_locale_name(locale_name_from(language, nil, territory, variant)) ||
    Cldr.known_locale_name(locale_name_from(language, script, nil, variant)) ||
    Cldr.known_locale_name(locale_name_from(language, nil, nil, variant)) ||
    Cldr.known_locale_name(language_tag.requested_locale_name) ||
    nil
  end

  @spec rbnf_locale_name(LanguageTag.t) :: locale_name | nil
  defp rbnf_locale_name(%LanguageTag{language: language, script: script,
      territory: territory} = language_tag) do
    Cldr.known_rbnf_locale_name(locale_name_from(language, script, territory, nil)) ||
    Cldr.known_rbnf_locale_name(locale_name_from(language, nil, territory, nil)) ||
    Cldr.known_rbnf_locale_name(locale_name_from(language, script, nil, nil)) ||
    Cldr.known_rbnf_locale_name(locale_name_from(language, nil, nil, nil)) ||
    Cldr.known_rbnf_locale_name(language_tag.requested_locale_name) ||
    nil
  end

  @doc """
  Normalize the casing of a locale name.

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/0`
    or a `Cldr.LanguageTag` struct

  Locale names are case insensitive but certain common
  casing is followed in practise:

  * lower case for a language
  * capital case for a script
  * upper case for a region/territory

  **Note** this function is intended to support only the CLDR
  locale names which have a format that is a subset of the full
  langauge tag specification.

  For proper parsing of local names and language tags, see
  `Cldr.Locale.canonical_language_tag/1`

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
  def normalize_locale_name(locale_name) do
    case String.split(locale_name, ~r/[-_]/) do
      [lang, other] ->
        if String.length(other) == 4 do
          String.downcase(lang) <> "-" <> String.capitalize(other)
        else
          String.downcase(lang) <> "-" <> String.upcase(other)
        end
      [lang, script, region] ->
        if String.length(script) == 4 do # Its a lang-script-region
          String.downcase(lang) <> "-" <> String.capitalize(script) <> "-" <> String.upcase(region)
        else # Its lang-region-variant
          String.downcase(lang) <> "-" <> String.upcase(script) <> "-" <> String.upcase(region)
        end
      [lang] ->
        String.downcase(lang)
      _ ->
        String.replace(locale_name, "_", "-")
    end
  end

  @doc """
  Return a locale name from a `Cldr.LanguageTag`

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/0`
    or a `Cldr.LanguageTag` struct

  ## Example

      iex> Cldr.Locale.locale_name_from Cldr.Locale.new!("en")
      "en-Latn-US"

  """
  @spec locale_name_from(LanguageTag.t) :: Locale.locale_namne

  def locale_name_from(%LanguageTag{language: language, script: script,
      territory: territory, variant: variant}) do
    locale_name_from(language, script, territory, variant)
  end

  @doc """
  Return a locale name by combining language, script, territory and variant
  parameters

  * `language`, `script`, `territory` and `variant` are string
    representations, or `nil`, of the language subtags

  ## Example

      iex> Cldr.Locale.locale_name_from("en", "Latn", "001", nil)
      "en-Latn-001"

  """
  @spec locale_name_from(String.t | nil, String.t | nil, String.t | nil, String.t | nil) ::
    Locale.locale_name

  def locale_name_from(language, script, territory, variant) do
    [language, script, territory, variant]
    |> Enum.reject(&is_nil/1)
    |> Enum.join("-")
  end

  @doc """
  Substitute deprectated subtags with a `Cldr.LanguageTag` with their
  non-deprecated alternatives.

  * Replace any deprecated subtags with their canonical values using the alias
    data. Use the first value in the replacement list, if
    it exists. Language tag replacements may have multiple parts, such as
    `sh` ➞ `sr_Latn` or `mo` ➞ `ro_MD`. In such a case, the original script and/or
    region/territory are retained if there is one. Thus `sh_Arab_AQ` ➞ `sr_Arab_AQ`, not
    `sr_Latn_AQ`.

  * Remove the script code 'Zzzz' and the territory code 'ZZ' if they occur.

  * Get the components of the cleaned-up source tag (languages, scripts, and
    regions/territories), plus any variants and extensions.

  ## Examples

      iex> Cldr.Locale.substitute_aliases Cldr.LanguageTag.Parser.parse!("en-US")
      %Cldr.LanguageTag{extensions: %{}, language: "en", locale: %{}, private_use: [],
       territory: "US", script: nil, transform: %{}, variant: nil}

      iex> Cldr.Locale.substitute_aliases Cldr.LanguageTag.Parser.parse!("sh_Arab_AQ")
      %Cldr.LanguageTag{extensions: %{}, language: "sr", locale: %{}, private_use: [],
       territory: "AQ", script: "Arab", transform: %{}, variant: nil}

      iex> Cldr.Locale.substitute_aliases Cldr.LanguageTag.Parser.parse!("sh_AQ")
      %Cldr.LanguageTag{extensions: %{}, language: "sr", locale: %{}, private_use: [],
       territory: "AQ", script: "Latn", transform: %{}, variant: nil}

      iex> Cldr.Locale.substitute_aliases Cldr.LanguageTag.Parser.parse!("mo")
      %Cldr.LanguageTag{extensions: %{}, language: "ro", locale: %{}, private_use: [],
       territory: "MD", script: nil, transform: %{}, variant: nil}

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
  Replace empty subtags within a `Cldr.LanguageTag` with the most likely
  subtag.

  A subtag is called empty if it is a missing script or region subtag, or it is
  a base language subtag with the value `und`. In the description below,
  a subscript on a subtag x indicates which tag it is from: x<sub>s</sub> is in the
  source, x<sub>m</sub> is in a match, and x<sub>r</sub> is in the final result.

  This operation is performed in the following way:

  ### Lookup

  Lookup each of the following in order, and stop on the first match:

  * language<sub>s</sub>-script<sub>s</sub>-region<sub>s</sub>
  * language<sub>s</sub>-region<sub>s</sub>
  * language<sub>s</sub>-script<sub>s</sub>
  * language<sub>s</sub>
  * und-script<sub>s</sub>

  ### Return

  * If there is no match,either return
    * an error value, or
    * the match for `und`

  * Otherwise there is a match = language<sub>m</sub>-script<sub>m</sub>-region<sub>m</sub>

  * Let x<sub>r</sub> = x<sub>s</sub> if x<sub>s</sub> is not empty, and x<sub>m</sub> otherwise.

  * Return the language tag composed of language<sub>r</sub>-script<sub>r</sub>-region<sub>r</sub> + variants + extensions .

  ## Example

      iex> Cldr.Locale.add_likely_subtags Cldr.LanguageTag.parse!("zh-SG")
      %Cldr.LanguageTag{extensions: %{}, language: "zh", locale: %{}, private_use: [],
       territory: "SG", script: "Hans", transform: %{}, variant: nil}

  """
  def add_likely_subtags(%LanguageTag{language: language, script: script, territory: territory} = language_tag) do
    subtags = likely_subtags(locale_name_from(language, script, territory, nil)) ||
              likely_subtags(locale_name_from(language, nil, territory, nil)) ||
              likely_subtags(locale_name_from(language, script, nil, nil)) ||
              likely_subtags(locale_name_from(language, nil, nil, nil)) ||
              likely_subtags(locale_name_from("und", script, nil, nil)) ||
              likely_subtags(locale_name_from("und", nil, nil, nil))

    Map.merge(subtags, language_tag, fn _k, v1, v2 -> if empty?(v2), do: v1, else: v2 end)
  end

  @doc """
  Returns an error tuple for an invalid locale.

    * `locale_name` is any locale name returned by `Cldr.known_locale_names/0`

  ## Examples

      iex> Cldr.Locale.locale_error :invalid
      {Cldr.UnknownLocaleError, "The locale :invalid is not known."}

  """
  @spec locale_error(Locale.locale_name | LanguageTag.t) :: {Cldr.UnknownLocaleError, String.t}
  def locale_error(%LanguageTag{requested_locale_name: requested_locale_name}) do
    locale_error(requested_locale_name)
  end

  def locale_error(locale_name) do
    {Cldr.UnknownLocaleError, "The locale #{inspect locale_name} is not known."}
  end

  @doc """
  Returns the map of likely subtags for a subset of available
  locale names.

  ## Example

      Cldr.Locale.likely_subtags
      %{
        "bez" => %Cldr.LanguageTag{
          canonical_locale_name: nil,
          cldr_locale_name: nil,
          extensions: %{},
          language: "bez",
          locale: %{},
          private_use: [],
          rbnf_locale_name: nil,
          requested_locale_name: nil,
          script: "Latn",
          territory: "TZ",
          transform: %{},
          variant: nil
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
          territory: "GN",
          transform: %{},
          variant: nil
        },
        ...

  """
  @likely_subtags Cldr.Config.likely_subtags
  @spec likely_subtags :: Map.t
  def likely_subtags do
    @likely_subtags
  end

  @doc """
  Returns the likely substags, as a `Cldr.LanguageTag`,
  for a given locale name.

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/0`
    or a `Cldr.LanguageTag` struct

  ## Examples

      iex> Cldr.Locale.likely_subtags "en"
      %Cldr.LanguageTag{
        canonical_locale_name: nil,
        cldr_locale_name: nil,
        extensions: %{},
        language: "en",
        locale: %{},
        private_use: [],
        rbnf_locale_name: nil,
        requested_locale_name: nil,
        script: "Latn",
        territory: "US",
        transform: %{},
        variant: nil
      }

      iex> Cldr.Locale.likely_subtags Cldr.Locale.new!("th")
      %Cldr.LanguageTag{
        canonical_locale_name: nil,
        cldr_locale_name: nil,
        extensions: %{},
        language: "th",
        locale: %{},
        private_use: [],
        rbnf_locale_name: nil,
        requested_locale_name: nil,
        script: "Thai",
        territory: "TH",
        transform: %{},
        variant: nil
      }

  """
  @spec likely_subtags(locale_name) :: LanguageTag.t
  def likely_subtags(locale_name) when is_binary(locale_name) do
    Map.get(likely_subtags(), locale_name)
  end

  def likely_subtags(%LanguageTag{requested_locale_name: requested_locale_name}) do
    likely_subtags(requested_locale_name)
  end

  @doc """
  Return a map of the known aliases for Language, Script and Territory
  """
  @aliases Cldr.Config.aliases
  @spec aliases :: Map.t
  def aliases do
    @aliases
  end

  @doc """
  Return a map of the aliases for a given alias key and type

  * `type` is one of `[:language, :region, :script, :variant, :zone]`

  * `key` is the substitution key (a language, region, script, variant or zone)

  """
  @alias_keys Map.keys(@aliases)
  @spec aliases(Locale.locale_name, atom()) :: Map.t
  def aliases(key, type) when type in @alias_keys do
    aliases()
    |> Map.get(type)
    |> Map.get(key)
  end

  @doc """
  Returns an error tuple for an invalid locale alias.

    * `locale_name` is any locale name returned by `Cldr.known_locale_names/0`

  ## Examples


  """
  @spec alias_error(Locale.locale_name | LanguageTag.t, String.t) ::
    {Cldr.UnknownLocaleError, String.t}

  def alias_error(locale_name, alias_name) when is_binary(locale_name) do
    {Cldr.UnknownLocaleError, "The locale #{inspect locale_name} and its " <>
      "alias #{inspect alias_name} are not known."}
  end

  def alias_error(%LanguageTag{requested_locale_name: requested_locale_name}, alias_name) do
    alias_error(requested_locale_name, alias_name)
  end
end