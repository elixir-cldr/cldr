defmodule Cldr.Locale.Match do
  @moduledoc """
  Implements the language matching algorithm.

  """

  @more_than_region_diff 5
  @default_threshold 30

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
        [{"zh-Hant", 10}, {"zh", 59}, {"zh-Hans", 59}, {"en-Hant", 89}]

        iex> supported = Cldr.known_gettext_locale_names()
        ["en", "en-GB", "es", "it"]
        iex> Cldr.Locale.Match.best_match("en-GB", supported: supported)
        [{"en-GB", 5}, {"en", 10}]
        iex> Cldr.Locale.Match.best_match("zh-HK", supported: supported)
        []

  """
  @doc since: "2.44.0"
  def best_match(desired, options \\ []) do
    desired = List.wrap(desired) |> Enum.with_index()
    backend = Keyword.get_lazy(options, :backend, &Cldr.default_backend!/0)
    supported = Keyword.get_lazy(options, :supported, &backend.known_locale_names/0)
    threshold = Keyword.get(options, :limit, @default_threshold)

    for {desired, index} <- desired, supported <- supported,
        match_distance = match_distance(desired, supported, index, backend),
        match_distance < threshold  do
      {supported, match_distance}
    end
    |> Enum.sort_by(&match_key/1)
  end

  # If the language is a paradigmn locale then it
  # takes precedence of non-paradigm locales. We
  # leverage erlang term ordering to craft a match
  # key.  Since false sorts before true, we use
  # "not in" rather than "in".

  defp match_key({language, distance}) do
    {distance, atomize(language) not in paradigm_locales()}
  end

  defp atomize(string) when is_binary(string) do
    String.to_existing_atom(string)
  rescue _e ->
    nil
  end

  defp atomize(atom) when is_atom(atom) do
    atom
  end

  @doc """
  Return a match distance between a desired locale and
  a supported locale.

  ### Arguments

  * `desired` is any valid locale returned by `Cldr.known_locale_names/1`
    or a string or atom locale name.

  * `supported` is any valid locale returned by `Cldr.known_locale_names/1`
    or a string or atom locale name.

  * `index` is the position of this `desired` language in a
    list of desired languages. The default is `0`.

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module. The default is `Cldr.default_backend!/0`.

  ### Returns

  * A numeric score indicating how well the supported locale can represent
    the desired locale. A smaller number is better with a value under 10 being
    a good fit and a number over 50 being a poor fit.

  ### Example

      iex> Cldr.Locale.Match.match_distance("en", "en")
      0

      iex> Cldr.Locale.Match.match_distance("en", "en-GB")
      5

      iex> Cldr.Locale.Match.match_distance("en-GB", "en-AU")
      3

      iex> Cldr.Locale.Match.match_distance("en", "zh-Hans")
      100

  """
  @doc since: "2.44.0"
  def match_distance(desired, supported, index \\ 0, backend \\ Cldr.default_backend!()) do
    with {:ok, desired} <- validate(desired, backend),
         {:ok, supported} <- validate(supported, backend) do
      @match_list
      |> Enum.reduce(0, &distance(desired, supported, &1, &2))
      |> Kernel.+(index)
      |> Kernel.+(@more_than_region_diff)
      |> min(100)
    end
  end

  defp validate(%Cldr.LanguageTag{} = locale, _backend) do
    {:ok, locale}
  end

  defp validate(locale, backend) do
    Cldr.Locale.canonical_language_tag(locale, backend, skip_gettext_and_cldr: true, skip_rbnf_name: true)
  end

  defp distance(desired, supported, subtags, acc) do
    desired_fields = subtags(desired, subtags)
    supported_fields = subtags(supported, subtags)
    calculate_distance(desired_fields, supported_fields, acc)
  end

  # When the last subtag is the same, don't process it following the rule:
  # If respective subtags in each language tag are identical, remove the subtag from each
  # (logically) and continue.
  defp calculate_distance([_, _, territory], [_, _, territory], acc), do: acc
  defp calculate_distance([_, script], [_, script], acc), do: acc
  defp calculate_distance([language], [language], acc), do: acc

  # If the subtags are identical then there is no difference
  defp calculate_distance(desired, desired, acc), do: acc + 0

  # Now we have to calculate
  defp calculate_distance(desired, supported, acc), do: acc + match_score(desired, supported)

  defp match_score(desired, supported) do
    Enum.reduce_while(language_matches(), 0, fn match, acc ->
      cond do
        matches?(desired, match.desired) &&
            matches?(supported, match.supported) ->
          {:halt, match.distance} # |> IO.inspect(label: "Score for #{inspect match}}")

        !Map.get(match, :one_way) && matches?(desired, match.supported) && matches?(supported, match.desired) ->
          {:halt, match.distance} # |> IO.inspect(label: "Score for inverse #{inspect match}}")

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

  defp subtags(locale, subtags) do
    Enum.map(subtags, &(Map.fetch!(locale, &1)))
  end

end