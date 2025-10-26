defmodule Cldr.Locale.Match do
  @moduledoc """
  Implements the language matching algorithm.

  """

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

  def match_distance(desired, supported, backend \\ Cldr.default_backend!()) do
    with {:ok, desired} <- Cldr.validate_locale(desired, backend),
         {:ok, supported} <- Cldr.validate_locale(supported, backend) do
      @match_list
      |> Enum.reduce(0, &distance(desired, supported, &1, &2))
      |> min(100)
    end
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

        matches?(desired, match.supported) && matches?(supported, match.desired)
            && !Map.get(match, :one_way) ->
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
  def matches?([language, _, _], [language, :"*", :"*"]), do: true
  def matches?([language, _], [language, :"*"]), do: true
  def matches?([language], [language]), do: true

  # Language and script
  def matches?([language, script, _], [language, script, :"*"]), do: true
  def matches?([language, script], [language, script]), do: true

  # Language, script and territory
  def matches?([language, _, territory], [language, :"*", territory]), do: true
  def matches?([language, script, territory], [language, script, territory]), do: true

  # Expanded match variables
  def matches?([language, _script, territory], [language, :"*", {:in, variable}]) do
    territory in expand(variable)
  end

  def matches?([language, script, territory], [language, script, {:in, variable}]) do
    territory in expand(variable)
  end

  def matches?([language, _script, territory], [language, :"*", {:not_in, variable}]) do
    territory not in expand(variable)
  end

  def matches?([language, script, territory], [language, script, {:not_in, variable}]) do
    territory not in expand(variable)

  end

  # Wildcard matches are true
  def matches?([_, _, _], [:"*", :"*", :"*"]), do: true
  def matches?([_, _], [:"*", :"*"]), do: true
  def matches?([_], [:"*"]), do: true

  def matches?(_fields, _match_data), do: false

  def expand(variable) do
    Map.fetch!(match_variables(), variable)
  end

  defp subtags(locale, subtags) do
    Enum.map(subtags, &(Map.fetch!(locale, &1)))
  end

end