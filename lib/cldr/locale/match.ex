defmodule Cldr.Locale.Match do
  @moduledoc """
  Implements the [CLDR language matching algorithm](https://www.unicode.org/reports/tr35/tr35.html#LanguageMatching).

  """

  alias Cldr.Locale

  # Since the default distance for differnt territories is 4
  # and the default distance for different scripts is 50 this
  # default will match if there is a territory difference or
  # a script different but not both. Bote that a language
  # default distance is 80 so by default different languages
  # can never match.

  # UPDATED: now matching if only the language matches. Was 50,
  # now 54.

  @default_threshold 54

  # When looking for a best match amongst multiple desired
  # languages we want the languages earlier in the list to
  # be preferred over those later in the list in the cases
  # where their match distance is the same. We do that by
  # demoting later entries in the list by am amount greater
  # than the default territory difference (which is 4).
  @more_than_territory_difference 5

  @language_matching Cldr.Config.language_matching()
  @paradigm_locales Map.fetch!(@language_matching, :paradigm_locales)

  # Kept as @doc false accessors for backward compatibility with any
  # downstream callers. The matching engine itself no longer iterates
  # these — see Cldr.Locale.DistanceTrie.
  @doc false
  def language_matches do
    Map.fetch!(@language_matching, :language_match)
  end

  @doc false
  def match_variables do
    Map.fetch!(@language_matching, :match_variables)
  end

  @doc false
  def paradigm_locales do
    @paradigm_locales
  end

  @doc false
  def default_threshold do
    @default_threshold
  end

  @doc """
  Find the desired locale that is the best suported match.

  ### Arguments

  * `desired` is any valid locale name or list of locale names
    returned by `Cldr.known_locale_names/1` or a string or atom locale name.

  * `options` is a keyword list of options.

  ### Options

  * `:backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module. The default is `Cldr.default_backend!/0`.

  * `:supported` is a list of locale names that are supported by the application.
    The default is `Cldr.known_locale_names/1`.

  * `:threshold` filters the returned list to those locales that score below this
    limit. The default is #{@default_threshold}.

  ### Returns

  * A possibly empty list of `{supported_locale, numeric_score}` tuples sorted in ascending numeric
    score order. The head of the list is considered the best match for `desired` in
    `supported`.

  ### Examples

        iex> Cldr.Locale.Match.best_match "zh-HK",
        ...>   supported: ["zh", "zh-Hans", "zh-Hant", "en", "fr", "en-Hant"]
        {:ok, "zh-Hant", 5}

        iex> supported = Cldr.known_gettext_locale_names()
        ["bg_BG", "en", "en_GB", "es", "it"]
        iex> Cldr.Locale.Match.best_match("en-GB", supported: supported)
        {:ok, "en_GB", 0}
        iex> Cldr.Locale.Match.best_match("zh-HK", supported: supported)
        {:error, {Cldr.NoMatchingLocale, "No match for desired locales \\"zh-HK\\""}}

  """
  @doc since: "2.44.0"
  def best_match(desired, options \\ [])

  def best_match(desired, options) do
    threshold = Keyword.get(options, :threshold, @default_threshold)
    backend = Keyword.get_lazy(options, :backend, &Cldr.default_backend!/0)

    desired_list =
      desired
      |> List.wrap()
      |> Enum.with_index()

    supported =
      options
      |> Keyword.get_lazy(:supported, &backend.known_locale_names/0)
      |> Enum.with_index()

    matches =
      for {candidate, priority} <- desired_list, {supported, index} <- supported,
          {:ok, candidate_tag} = validate(candidate, backend, :skip_subtags_for_und),
          {:ok, supported_tag} = validate(supported, backend),
          match_distance = match_distance(candidate_tag, supported_tag, backend),
          match_distance <= threshold do
        {supported, supported_tag, match_distance, priority, index}
      end
      |> Enum.sort(&language_comparator/2)
      # |> IO.inspect(label: "Ordered matches")

    case matches do
      [{supported, _supported_tag, distance, _priority, _index} | _rest] -> {:ok, supported, distance}
      [] -> {:error, {Cldr.NoMatchingLocale, "No match for desired locales #{inspect desired}"}}
    end
  end

  # "und" sorts after any other language that has the same distance score
  defp language_comparator({"und", _, distance, _, _}, {_lang, _, distance, _, _}) do
    false
  end

  defp language_comparator({_lang, _, distance, _, _}, {"und", _, distance, _, _}) do
    true
  end

  defp language_comparator(a, b) do
    if same_base_language?(a, b) do
      match_key_with_paradigm(a) < match_key_with_paradigm(b)
    else
      match_key_no_paradigm(a) < match_key_no_paradigm(b)
    end
  end

  defp same_base_language?(a, b) do
    extract_base_language(a) == extract_base_language(b)
  end

  defp extract_base_language({_supported, supported_tag, _, _, _}) do
    supported_tag.language
  end

  # If the language is a paradigmn locale then it
  # takes precedence of non-paradigm locales. We
  # leverage erlang term ordering to craft a match
  # key.  Since false sorts before true, we use
  # "not in" rather than "in".

  defp match_key_with_paradigm({_language, supported_tag, distance, priority, index}) do
    maybe_paradigm_locale =
      Locale.locale_name_from(supported_tag)

    {distance + (priority * @more_than_territory_difference),
      !paradigm_locale(maybe_paradigm_locale), index}
  end

  defp match_key_no_paradigm({_language, _supported_tag, distance, priority, index}) do
    {distance + (priority * @more_than_territory_difference), index}
  end

  defp paradigm_locale(language) when is_binary(language) do
    language in paradigm_locales()
  end

  @doc """
  Return a match distance between a desired locale and
  a supported locale.

  ### Arguments

  * `desired` is any valid locale returned by `Cldr.known_locale_names/1`
    or a string or atom locale name.

  * `supported` is any valid locale returned by `Cldr.known_locale_names/1`
    or a string or atom locale name.

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module. The default is `Cldr.default_backend!/0`.

  ### Returns

  * A numeric score indicating how well the supported locale can represent
    the desired locale. A smaller number is better with a value under 10 being
    a good fit and a number over 50 being a poor fit.

  ### Example

      iex> Cldr.Locale.Match.match_distance("en", "en")
      0

      iex> Cldr.Locale.Match.match_distance("en-AU", "en")
      5

      iex> Cldr.Locale.Match.match_distance("en-AU", "en-GB")
      3

      iex> Cldr.Locale.Match.match_distance("zh-HK", "zh-Hant")
      5

      iex> Cldr.Locale.Match.match_distance("en", "zh-Hans")
      134

  """
  @doc since: "2.44.0"

  def match_distance(desired, supported, backend \\ Cldr.default_backend!()) do
    with {:ok, desired} <- validate(desired, backend, :skip_subtags_for_und),
         {:ok, supported} <- validate(supported, backend) do
      Cldr.Locale.DistanceTrie.lookup(
        desired.language,
        desired.script,
        desired.territory,
        supported.language,
        supported.script,
        supported.territory
      )
    end
  end

  @doc false
  def validate(locale, backend, subtags \\ :add_subtags)

  def validate(%Cldr.LanguageTag{} = locale, _backend, _add_subtags) do
    {:ok, locale}
  end

  # Likely subtags has an entry for "und" that will
  # transform it to `en-Latn-US` which is not what
  # we want for matching. So don't apply likely subtags.
  def validate("und" <> _rest = locale, backend, :skip_subtags_for_und) do
    options = [skip_gettext_and_cldr: true, skip_rbnf_name: true, add_likely_subtags: false]
    Cldr.Locale.canonical_language_tag(locale, backend, options)
  end

  # Fast path: when the locale is a precomputed known name on the backend,
  # delegate to backend.validate_locale/1 which returns a fully maximised
  # tag in O(1). This is the asymptotic fix — without it, best_match did
  # full canonicalisation per supported locale on every call.
  #
  # Crucially, we MUST NOT fall through to backend.validate_locale/1 for
  # unknown names: its generic clause calls Cldr.Locale.canonical_language_tag
  # without skip_gettext_and_cldr, which re-enters Match.best_match and
  # recurses indefinitely while best_match is itself iterating the
  # supported list. Detect the precomputed path explicitly and use the
  # safe slow path otherwise.
  def validate(locale, backend, _add_subtags) when is_binary(locale) or is_atom(locale) do
    cond do
      not (Code.ensure_loaded?(backend) and function_exported?(backend, :validate_locale, 1)) ->
        slow_validate(locale, backend)

      precomputed?(locale, backend) ->
        backend.validate_locale(locale)

      true ->
        slow_validate(locale, backend)
    end
  end

  defp precomputed?(locale, backend) do
    not is_nil(Cldr.known_locale_name(normalise_for_lookup(locale), backend))
  end

  defp normalise_for_lookup(locale) when is_atom(locale) do
    locale
    |> Atom.to_string()
    |> normalise_for_lookup()
  end

  defp normalise_for_lookup(locale) when is_binary(locale) do
    normalised =
      locale
      |> String.downcase()
      |> Cldr.Config.locale_name_from_posix()

    try do
      String.to_existing_atom(normalised)
    rescue
      ArgumentError -> nil
    end
  end

  defp slow_validate(locale, backend) do
    options = [skip_gettext_and_cldr: true, skip_rbnf_name: true]
    Cldr.Locale.canonical_language_tag(locale, backend, options)
  end
end