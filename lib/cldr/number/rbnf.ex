defmodule Cldr.Rbnf do
  @moduledoc """
  Functions to implement Rules Based Number Formatting (rbnf)

  During compilation RBNF rules are extracted and generated
  as function bodies by `Cldr.Rbnf.Ordinal`, `Cldr.Rbnf.Cardinal`
  and `Cldr.Rbnf.NumberSystem`.

  The functions in this module would not normally be of common
  use outside of supporting the compilation phase.
  """

  @doc """
  Returns the list of locales that that have RBNF defined

  This list is the set of known locales for which
  there are rbnf rules defined.
  """

  require Cldr
  alias Cldr.Locale

  @known_locales Enum.filter Cldr.Config.known_locales(), fn (locale) ->
    Cldr.Config.get_locale(locale).rbnf != %{}
  end

  def known_locales do
    @known_locales
  end

  @doc """
  Returns {:ok, rbnf_rules} for a `locale` or `{:error, {Cldr.NoRbnf, info}}`

  * `locale` is any locale returned by `Cldr.Rbnf.known_locales/0`.

  """
  @spec for_locale(Locale.t) :: %{} | nil
  def for_locale(locale \\  Cldr.get_current_locale()) do
    with {:ok, locale} <- Cldr.valid_locale?(locale) do
      rbnf_data =
        locale
        |> Cldr.Config.get_locale
        |> Map.get(:rbnf)

      {:ok, rbnf_data}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Returns rbnf_rules for a `locale` or raises an exception if
  there are no rules.

  * `locale` is any locale returned by `Cldr.Rbnf.known_locales/0`.

  """
  def for_locale!(locale) do
    case for_locale(locale) do
      {:ok, rules} -> rules
      {:error, {exception, reason}} -> raise exception, reason
    end
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
      Enum.map(for_locale!(locale), fn {group, sets} ->
        locale = String.replace(locale, "_", "-")
        {group, %{locale => sets}}
      end)
      |> Enum.into(%{})
    end)
    |> Cldr.Map.merge_map_list
  end

  if Mix.env == :test do
    # Returns all the rules in rbnf without any tagging for rulegroup or set.
    # This is helpful for testing only.
    @doc false
    def all_rules do
      known_locales()
      |> Enum.map(&for_locale!/1)
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
end
