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

  @default_threshold 50

  # When looking for a best match amongst multiple desired
  # languages we want the languages earlier in the list to
  # be preferred over those later in the list in the cases
  # where their match distance is the same. We do that by
  # demoting later entries in the list by am amount greater
  # than the default territory difference (which is 4).
  @more_than_territory_difference 5

  @match_list [
    [:language, :script, :territory],
    [:language, :script],
    [:language]
  ]

  @language_matching Cldr.Config.language_matching()
  @language_matches Map.fetch!(@language_matching, :language_match)
  @match_variables Map.fetch!(@language_matching, :match_variables)
  @paradigm_locales Map.fetch!(@language_matching, :paradigm_locales)

  @doc false
  def language_matches do
    @language_matches
  end

  @doc false
  def match_variables do
    @match_variables
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
        ["en", "en_GB", "es", "it"]
        iex> Cldr.Locale.Match.best_match("en-GB", supported: supported)
        {:ok, "en_GB", 0}
        iex> Cldr.Locale.Match.best_match("zh-HK", supported: supported)
        {:error, {Cldr.NoMatchingLocale, "No match for desired locales \\"zh-HK\\""}}

  """
  @doc since: "2.44.0"
  def best_match(desired, options \\ []) do
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

  defp match_key_with_paradigm({_language, supported, distance, priority, index}) do
    maybe_paradigm_locale =
      Locale.locale_name_from(supported)

    {distance + (priority * @more_than_territory_difference),
      !paradigm_locale(maybe_paradigm_locale), index}
  end

  defp match_key_no_paradigm({_language, _supported_tag, distance, priority, index}) do
    {distance + (priority * @more_than_territory_difference), index}
  end

  defp paradigm_locale(language) do
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
    with {:ok, desired} <- validate(desired, backend),
         {:ok, supported} <- validate(supported, backend) do
      @match_list
      |> Enum.reduce(0, &subtag_distance(desired, supported, &1, &2))
    end
  end

  @doc false
  def validate(locale, backend, subtags \\ :add_subtags)

  def validate(%Cldr.LanguageTag{} = locale, _backend, _add_subtags) do
    {:ok, locale}
  end

  # Likely subtags has an entry for "und" that will
  # transform it to `en-Latn-US` which is not what
  # we want for matching. So don't apply liekely subtags.
  def validate("und" <> _rest = locale, backend, :skip_subtags_for_und) do
    options = [skip_gettext_and_cldr: true, skip_rbnf_name: true, add_likely_subtags: false]
    Cldr.Locale.canonical_language_tag(locale, backend, options)
  end

  def validate(locale, backend, _add_subtags) when is_binary(locale) do
    options = [skip_gettext_and_cldr: true, skip_rbnf_name: true]
    Cldr.Locale.canonical_language_tag(locale, backend, options)
  end

  def validate(locale, backend, add_subtags) when is_atom(locale) do
    locale
    |> Atom.to_string()
    |> validate(backend, add_subtags)
  end

  defp subtag_distance(desired, supported, subtags, acc) do
    desired_fields = subtags(desired, subtags)
    supported_fields = subtags(supported, subtags)
    distance(desired_fields, supported_fields, acc)
  end

  # When the last subtag is the same, don't process it following the rule:
  # If respective subtags in each language tag are identical, remove the subtag from each
  # (logically) and continue.

  defp distance([_, _, territory], [_, _, territory], acc), do: acc
  defp distance([_, script], [_, script], acc), do: acc
  defp distance([language], [language], acc), do: acc

  # If the subtags are identical then there is no difference
  defp distance(desired, desired, acc), do: acc + 0


  # Now we have to calculate
  defp distance(desired, supported, acc), do: acc + match_score(desired, supported)

  defp match_score(desired, supported) do
    Enum.reduce_while(language_matches(), 0, fn match, acc ->
      cond do
        matches?(desired, match.desired) &&
            matches?(supported, match.supported) ->
          {:halt, match.distance} # |> IO.inspect(label: "Match for #{inspect match}} desire: #{inspect desired} support: #{inspect supported}")

        !Map.get(match, :one_way) && matches?(desired, match.supported) &&
            matches?(supported, match.desired) ->
          {:halt, match.distance} # |> IO.inspect(label: "Match for inverse #{inspect match}}")

        true ->
          {:cont, acc}
      end
    end)
  end

  # Using the following except from TR35 we deduce:
  # a. Traverse the map for each combination of subtags in @match_list (above)
  # b. Only match with the designated subtags - ignore matching if the number of
  #    subtags is different to the number of subtags in the match data.
  #
  # > For example, suppose that nn-DE and nb-FR are being compared. They are first maximized to
  # > nn-Latn-DE and nb-Latn-FR, respectively. The list is searched. The first match is with
  # > "*-*-*", for a match of 96%. The languages are truncated to nn-Latn and nb-Latn, then to nn
  # > and nb. The first match is also for a value of 96%, so the result is 92%.

  # Language matching
  defp matches?([language, _, _], [language, :"*", :"*"]), do: true
  defp matches?([language, _], [language, :"*"]), do: true
  defp matches?([language], [language]), do: true

  # Language and script
  defp matches?([language, script, _], [language, script, :"*"]), do: true
  defp matches?([language, script], [language, script]), do: true

  # Language, script and territory
  defp matches?([language, _, territory], [language, :"*", territory]), do: true
  defp matches?([language, script, territory], [language, script, territory]), do: true

  # Expanded match variables
  defp matches?([language, _script, territory], [language, :"*", {:in, variable}]) do
    territory in expand(variable)
  end

  defp matches?([language, script, territory], [language, script, {:in, variable}]) do
    territory in expand(variable)
  end

  defp matches?([language, _script, territory], [language, :"*", {:not_in, variable}]) do
    territory not in expand(variable)
  end

  defp matches?([language, script, territory], [language, script, {:not_in, variable}]) do
    territory not in expand(variable)
  end

  # Wildcard matches are true
  defp matches?([_, _, _], [:"*", :"*", :"*"]), do: true
  defp matches?([_, _], [:"*", :"*"]), do: true
  defp matches?([_], [:"*"]), do: true

  defp matches?(_fields, _match_data), do: false

  defp expand(variable) do
    Map.fetch!(match_variables(), variable)
  end

  defp subtags(locale, [:language]), do: [locale.language]
  defp subtags(locale, [:language, :script]), do: [locale.language, locale.script]
  defp subtags(locale, [:language, :script, :territory]), do: [locale.language, locale.script, locale.territory]

end