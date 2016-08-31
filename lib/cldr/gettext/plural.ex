if Code.ensure_loaded?(Gettext) do
  defmodule Cldr.Gettext.Plural do
    @moduledoc """
    Defines a Plural module for Gettext that uses the `Cldr` plural rules.
    """

    # @behaviour Gettext.Plural
    alias Cldr.Number.Cardinal

    def nplurals(locale) do
      locale = normalize_locale(locale)
      if Cldr.known_locale?(locale) do
        Cardinal.plural_rules_for(locale) |> Enum.count
      else
        Gettext.Plural.nplurals(locale)
      end
    end

    def plural(locale, n) do
      locale = normalize_locale(locale)
      if Cldr.known_locale?(locale) do
        rule = Cardinal.plural_rule(n, locale)
        n = Cardinal.plural_rules_for(locale) |> Enum.count
        gettext_return(rule, n)
      else
        Gettext.Plural.plural(locale, n)
      end
    end

    defp gettext_return(:one, _n),   do: 0
    defp gettext_return(:two, _n),   do: 1
    defp gettext_return(:few, _n),   do: 2
    defp gettext_return(:many, _n),  do: 3

    # Many languages just have :one and :other so it
    # makes sense to return "1" from :other when there are
    # only 2 forms.  This is to align better with what is
    # probably being defined in the Gettext .po files.
    defp gettext_return(:other, 2),  do: 1
    defp gettext_return(:other, _n), do: 4

    defp normalize_locale(locale) do
      String.replace(locale, "_", "-")
    end
  end
end