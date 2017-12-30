if Code.ensure_loaded?(Gettext) do
  defmodule Cldr.Gettext.Plural do
    @moduledoc """
    Defines a Plural module for Gettext that uses the `Cldr` plural rules.
    """
    @behaviour Gettext.Plural

    alias Cldr.Number.Cardinal
    alias Cldr.Math
    alias Cldr.LanguageTag
    alias Cldr.Locale

    @doc """
    Returns how many plural forms exist for a given locale.

    * `locale` is either a locale name in the list `Cldr.known_locales/0` or
      a `%LanguageTag{}` as returned by `Cldr.Locale.new/1`

    ## Examples

        iex> Cldr.Gettext.Plural.nplurals("pl")
        3

        iex> Cldr.Gettext.Plural.nplurals("en")
        2

    """
    @spec nplurals(Locale.locale_name()) :: non_neg_integer
    def nplurals(locale_name) when is_binary(locale_name) do
      with {:ok, _locale} <- Cldr.validate_locale(locale_name) do
        Cardinal.plural_rules_for(locale_name) |> Enum.count()
      else
        {:error, _reason} -> apply(Gettext.Plural, :nplurals, [locale_name])
      end
    end

    @doc """
    Returns to what plural form a given number belongs to in a given
    locale.

    * `locale` is either a locale name in the list `Cldr.known_locales/0` or
      a `%LanguageTag{}` as returned by `Cldr.Locale.new/1`

    ## Examples

        iex> Cldr.Gettext.Plural.plural("pl", 1)
        0

        iex> Cldr.Gettext.Plural.plural("pl", 2)
        1

        iex> Cldr.Gettext.Plural.plural("pl", 5)
        2

        iex> Cldr.Gettext.Plural.plural("pl", 112)
        2

        iex> Cldr.Gettext.Plural.plural("en", 1)
        0

        iex> Cldr.Gettext.Plural.plural("en", 2)
        1

        iex> Cldr.Gettext.Plural.plural("en", 112)
        1

    """
    @spec plural(Locale.locale_name() | LanguageTag.t(), Math.number_or_decimal()) ::
            non_neg_integer | {:error, String.t()}

    def plural(%LanguageTag{cldr_locale_name: cldr_locale_name}, n) do
      plural(cldr_locale_name, n)
    end

    def plural(locale_name, n) when is_binary(locale_name) do
      with {:ok, locale} <- Cldr.validate_locale(locale_name) do
        rule = Cardinal.plural_rule(n, locale)
        n = Cardinal.plural_rules_for(locale_name) |> Enum.count()
        gettext_return(rule, n)
      else
        {:error, _reason} -> apply(Gettext.Plural, :plural, [locale_name, n])
      end
    end

    defp gettext_return(:zero, _n), do: 0
    defp gettext_return(:one, _n), do: 1
    defp gettext_return(:two, _n), do: 2
    defp gettext_return(:few, _n), do: 3
    defp gettext_return(:many, _n), do: 4

    # Since :other is the catch-all it should
    # return a number 1 greater than the number
    # of rules defined in Cldr
    defp gettext_return(:other, n), do: n - 1
  end
end
