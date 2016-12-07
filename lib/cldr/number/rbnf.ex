defmodule Cldr.Rbnf do
  @moduledoc """
  Functions to implement Rules Based Number Formatting (rbnf)

  During compilation we want to look up the configured locales
  and generate the functions needed for only those locales.

  For any other recognized locale we need a way to either fallback
  to a known locale, or error exit (configurable)

  Note that many of the functions in this module rely on having the raw
  XML RBNF files from the CLDR repository.  The repository can be installed by
  running:

      mix cldr.download

  Unless you are interested in the muysteries of how the repository is
  put together this is not recommended.
  """

  @doc """
  Returns the list of locales that that have RBNF defined

  This list is the set of known locales for which
  there are rbnf rules defined.
  """
  def known_locales do
    Enum.filter Cldr.known_locales(), fn (locale) ->
      Cldr.Locale.get_locale(locale).rbnf != %{}
    end
  end

  @doc """
  Returns the rbnf rules for a `locale` or `{:error, :rbnf_file_not_found}`

  * `locale` is any locale returned by `Rbnf.known_locales/0`.

  Note that `for_locale/1` does not raise if the locale does not exist
  like the majority of `Cldr`.  This is by design since the set of locales
  that have rbnf rules is substantially less than the set of locales
  supported by `Cldr`.
  """
  @spec for_locale(Locale.t) :: %{} | nil
  def for_locale(locale) do
    Cldr.Locale.get_locale(locale).rbnf
  end

  @doc """
  Returns a map that merges all rules by the primary dimension of
  RuleGroup, within which rbnf rules are keyed by locale.

  This function is primarily intended to support compile-time generation
  of functions to process rbnf rules.
  """
  @spec for_all_locales :: %{}
  def for_all_locales do
    Enum.map(known_locales(), fn locale ->
      Enum.map(for_locale(locale), fn {group, sets} ->
        locale = String.replace(locale, "_", "-")
        {group, %{locale => sets}}
      end)
      |> Enum.into(%{})
    end)
    |> Cldr.Map.merge_map_list
  end

  # Returns all the rules in rbnf without any tagging for rulegroup or set.
  # This is helpful for testing only.
  @doc false
  def all_rules do
    known_locales()
    |> Enum.map(&for_locale/1)
    |> Enum.flat_map(&Map.values/1) # Get sets from groups
    |> Enum.flat_map(&Map.values/1) # Get rules from set
    |> Enum.flat_map(&(&1.rules))   # Get the list of rules
  end

  # Returns a list of unique rule definitions.  Used for testing.
  @doc false
  def all_rule_definitions do
    all_rules()
    |> Enum.map(&(&1.definition))
    |> Enum.uniq
  end
end
