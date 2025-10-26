defmodule Doc.Test do
  use ExUnit.Case, async: true

  doctest Cldr
  doctest Cldr.Config
  doctest Cldr.Locale
  doctest Cldr.Number.PluralRule

  doctest Cldr.LanguageTag
  doctest Cldr.LanguageTag.Parser
  doctest Cldr.LanguageTag.Sigil
  doctest Cldr.AcceptLanguage
  doctest Cldr.Substitution
  doctest Cldr.Timezone

  doctest Cldr.Validity.Territory
  doctest Cldr.Validity.Script
  doctest Cldr.Validity.Variant
  doctest Cldr.Validity.Language
  doctest Cldr.Validity.Subdivision

  doctest TestBackend.Cldr
  doctest TestBackend.Cldr.Locale
  doctest TestBackend.Cldr.Number.Ordinal
  doctest TestBackend.Cldr.Number.Cardinal
  doctest TestBackend.Cldr.Number.PluralRule.Range

  doctest TestBackend.Gettext.Plural
  doctest MyApp.Cldr
  doctest Cldr.Rbnf.Config

  doctest Cldr.Locale.Match
end
