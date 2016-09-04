if Code.ensure_loaded?(Gettext) do
  defmodule Cldr.Gettext.Plural do
    @moduledoc """
    Defines a Plural module for Gettext that uses the `Cldr` plural rules.
    """

    @behaviour Gettext.Plural

    alias Cldr.Number.Cardinal
    alias Cldr.Locale

    def nplurals(locale) do
      locale = Locale.normalize_locale(locale)
      if Cldr.known_locale?(locale) do
        Cardinal.plural_rules_for(locale) |> Enum.count
      else
        apply(Gettext.Plural, :nplurals, [locale])
      end
    end

    def plural(locale, n) do
      locale = Locale.normalize_locale(locale)
      if Cldr.known_locale?(locale) do
        rule = Cardinal.plural_rule(n, locale)
        n = Cardinal.plural_rules_for(locale) |> Enum.count
        gettext_return(rule, n)
      else
        apply(Gettext.Plural, :plural, [locale, n])
      end
    end

    defp gettext_return(:zero, _n),  do: 0
    defp gettext_return(:one,  _n),  do: 1
    defp gettext_return(:two,  _n),  do: 2
    defp gettext_return(:few,  _n),  do: 3
    defp gettext_return(:many, _n),  do: 4

    # Since :other is the catch-all it should
    # return a number 1 greater than the others
    defp gettext_return(:other, n),  do: n - 1
  end
end