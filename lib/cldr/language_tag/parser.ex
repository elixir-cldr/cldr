defmodule Cldr.LanguageTag.Parser do
  @moduledoc """
  Parses a CLDR language tag (also referred to as locale string).

  The applicable specification is from [CLDR](http://unicode.org/reports/tr35/#Unicode_Language_and_Locale_Identifiers)
  which is similar based upon [RFC5646](https://tools.ietf.org/html/rfc5646) with some variations.

  """
  alias Cldr.LanguageTag
  alias Cldr.Locale

  @doc """
  Parse a locale name into a `t:Cldr.LanguageTag`

  * `locale_name` is a string representation of a language tag
    as defined by [RFC5646](https://tools.ietf.org/html/rfc5646).

  Returns

  * `{:ok, language_tag}` or

  * `{:error, reasons}`

  """
  def parse(locale) do
    case Cldr.Rfc5646.Parser.parse(normalize_locale_name(locale)) do
      {:ok, language_tag} ->
        language_tag
        |> Keyword.put(:requested_locale_name, locale)
        |> normalize_tag()
        |> structify(LanguageTag)
        |> wrap(:ok)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Parse a locale name into a `t:Cldr.LanguageTag`

  * `locale_name` is a string representation of a language tag
    as defined by [RFC5646](https://tools.ietf.org/html/rfc5646).

  Returns

  * `language_tag` or

  * raises an exception

  """
  def parse!(locale) do
    case parse(locale) do
      {:ok, language_tag} -> language_tag
      {:error, {exception, reason}} -> raise exception, reason
    end
  end

  defp wrap(term, atom) do
    {atom, term}
  end

  defp normalize_tag(language_tag) do
    Enum.map(language_tag, &normalize_field/1)
  end

  def normalize_field({:language = field, language}) do
    {field, Cldr.Validity.Language.normalize(language)}
  end

  def normalize_field({:script = field, script}) do
    {field, Cldr.Validity.Script.normalize(script)}
  end

  def normalize_field({:territory = field, territory}) do
    {field, Cldr.Validity.Territory.normalize(territory)}
  end

  def normalize_field({:language_variants = field, variants}) do
    {field, Cldr.Validity.Variant.normalize(variants)}
  end

  # Everything is downcased before parsing
  # and that's the canonical form so no need to
  # do it again, just return the value

  def normalize_field(other) do
    other
  end

  defp normalize_locale_name(name) do
    name
    |> String.downcase()
    |> Locale.locale_name_from_posix()
  end

  defp structify(list, module) do
    struct(module, list)
  end
end
