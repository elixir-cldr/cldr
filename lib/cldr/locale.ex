defmodule Cldr.Locale do
  @moduledoc """
  Parse and process locale json as defined by [Unicode](http://unicode.org/reports/tr35/#Unicode_Language_and_Locale_Identifiers)
  """
  alias Cldr.LanguageTag

  @type name :: binary

  def normalize_locale_name(locale_name) do
    String.replace(locale_name, "_", "-")
  end

  def locale_from(%LanguageTag{language: language, script: script, region: region}) do
    [language, script, region]
    |> Enum.reject(&is_nil/1)
    |> Enum.join("-")
  end

  @doc """
  Attempt to match the provided locale to a configured locale.
  """
  def match(locale) when is_binary(locale) do
    if Cldr.known_locale?(locale) do
      {:ok, locale}
    else
      locale
      |> LanguageTag.parse_locale
      |> match
    end
  end

  @known_locales Cldr.known_locales
  def match({:error, reason}), do: {:error, reason}

  def match({:ok, locale, %LanguageTag{} = language_tag}) when locale in @known_locales do
    {:ok, locale, language_tag}
  end

  def match({:ok, locale, %LanguageTag{} = language_tag}) do
    match_alias(locale, language_tag)
  end

  def match_alias(locale, language_tag) do
    case find_alias(locale, language_tag) do
      {:ok, locale_alias} -> match({:ok, locale_alias, language_tag})
      {:error, reason} -> {:error, reason}
    end
  end

  def find_alias(locale, language_tag) do
    cond do
      locale_alias = aliases(locale, :language_alias)  -> {:ok, locale_alias}
      true -> {:error, alias_error(locale_from(language_tag), locale)}
    end
  end

  def locale_error(locale_name) do
    {Cldr.UnknownLocaleError, "The locale #{inspect locale_name} is not known."}
  end

  def alias_error(locale_name, alias_name) do
    {Cldr.UnknownLocaleError, "The locale #{inspect locale_name} and its alias #{inspect alias_name} are not known."}
  end

  @aliases Cldr.Config.aliases
  def aliases do
    @aliases
  end

  @alias_keys Map.keys(@aliases)
  defp aliases(locale, type) when type in @alias_keys do
    get_in(aliases(), [type, locale])
  end

end