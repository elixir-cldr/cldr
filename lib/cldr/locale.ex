defmodule Cldr.Locale do
  @moduledoc """
  Parse and process locale json as defined by [Unicode](http://unicode.org/reports/tr35/#Unicode_Language_and_Locale_Identifiers)
  """
  alias Cldr.LanguageTag
  import Cldr.Helpers

  @typedoc "The name of a locale in a string format"
  @type name :: String.t

  def canonical_language_tag(locale_name) when is_binary(locale_name) do
    case LanguageTag.parse(locale_name) do
      {:ok, language_tag} ->
        canonical_language_tag(language_tag)
      {:error, reason} ->
        {:error, reason}
    end
  end

  def canonical_language_tag(%LanguageTag{} = language_tag) do
    requested_locale_name = locale_name_from(language_tag)

    canonical_tag =
      language_tag
      |> substitute_aliases
      |> add_likely_subtags

    canonical_tag =
      canonical_tag
      |> Map.put(:requested_locale_name, requested_locale_name)
      |> Map.put(:canonical_locale_name, locale_name_from(canonical_tag))
      |> set_cldr_locale_name

    {:ok, canonical_tag}
  end

  def canonical_language_tag!(language_tag) do
    case canonical_language_tag(language_tag) do
      {:ok, tag} -> tag
      {:error, {exception, reason}} -> raise exception, reason
    end
  end

  def canonical_locale_name(locale) do
    case canonical_language_tag(locale) do
      {:ok, language_tag} -> locale_name_from(language_tag)
      {:error, reason} -> {:error, reason}
    end
  end

  defp set_cldr_locale_name(%LanguageTag{language: language, script: script, region: region} = language_tag) do
    cldr_locale_name =
      cldr_locale_name(language_tag) ||
      locale_name_from(Cldr.default_locale)

    %{language_tag | cldr_locale_name: cldr_locale_name}
  end

  def cldr_locale_name(%LanguageTag{language: language, script: script, region: region} = language_tag) do
    Cldr.known_locale(locale_name_from(language, script, region)) ||
    Cldr.known_locale(locale_name_from(language, nil, region)) ||
    Cldr.known_locale(locale_name_from(language, script, nil)) ||
    Cldr.known_locale(locale_name_from(language, nil, nil)) ||
    nil
  end

  @spec normalize_locale_name(name) :: name
  def normalize_locale_name(name) do
    String.replace(name, "_", "-")
  end

  def locale_name_from(%LanguageTag{language: language, script: script, region: region}) do
    locale_name_from(language, script, region)
  end

  def locale_name_from(language, script, region) do
    [language, script, region]
    |> Enum.reject(&is_nil/1)
    |> Enum.join("-")
  end

  @doc """
  Given a source locale X, to return a locale Y where the aliases
  have been substituted with their non-deprecated alternatives.

  * Replace any deprecated subtags with their canonical values using the alias
  data. Use the first value in the replacement list, if
  it exists. Language tag replacements may have multiple parts, such as
  `sh` ➞ `sr_Latn` or `mo` ➞ `ro_MD`. In such a case, the original script and/or
  region are retained if there is one. Thus `sh_Arab_AQ` ➞ `sr_Arab_AQ`, not
  `sr_Latn_AQ`.

  * Remove the script code 'Zzzz' and the region code 'ZZ' if they occur.

  * Get the components of the cleaned-up source tag (languages, scripts, and
  regions), plus any variants and extensions.

  ## Examples

      iex> Cldr.Locale.substitute_aliases Cldr.LanguageTag.Parser.parse!("en-US")
      %Cldr.LanguageTag{extensions: %{}, language: "en", locale: %{}, private_use: [],
       region: "US", script: nil, transforms: %{}, variant: nil}

      iex> Cldr.Locale.substitute_aliases Cldr.LanguageTag.Parser.parse!("sh_Arab_AQ")
      %Cldr.LanguageTag{extensions: %{}, language: "sr", locale: [], private_use: [],
       region: "AQ", script: "Arab", transforms: %{}, variant: nil}

      iex> Cldr.Locale.substitute_aliases Cldr.LanguageTag.Parser.parse!("sh_AQ")
      %Cldr.LanguageTag{extensions: %{}, language: "sr", locale: [], private_use: [],
       region: "AQ", script: "Latn", transforms: %{}, variant: nil}

      iex> Cldr.Locale.substitute_aliases Cldr.LanguageTag.Parser.parse!("mo")
      %Cldr.LanguageTag{extensions: %{}, language: "ro", locale: [], private_use: [],
       region: "MD", script: nil, transforms: %{}, variant: nil}

  """
  def substitute_aliases(%LanguageTag{} = language_tag) do
    language_tag
    |> substitute(:language)
    |> substitute(:script)
    |> substitute(:region)
    |> merge(language_tag)
    |> remove_unknown(:script)
    |> remove_unknown(:region)
  end

  defp substitute(%LanguageTag{language: language}, :language) do
    aliases(language, :language) || %LanguageTag{}
  end

  defp substitute(%LanguageTag{script: script} = language_tag, :script) do
    %{language_tag | script: aliases(script, :script) || script}
  end

  defp substitute(%LanguageTag{region: region} = language_tag, :region) do
    %{language_tag | region: aliases(region, :region) || region}
  end

  defp merge(alias_tag, original_language_tag) do
    Map.merge(alias_tag, original_language_tag, fn
      :language, v_alias, v_original ->
        if empty?(v_alias), do: v_original, else: v_alias
      _k, v_alias, v_original ->
        if empty?(v_original), do: v_alias, else: v_original
    end)
  end

  defp remove_unknown(%LanguageTag{script: "Zzzz"} = language_tag, :script) do
    %{language_tag | script: nil}
  end
  defp remove_unknown(%LanguageTag{} = language_tag, :script), do: language_tag

  defp remove_unknown(%LanguageTag{region: "ZZ"} = language_tag, :region) do
    %{language_tag | region: nil}
  end
  defp remove_unknown(%LanguageTag{} = language_tag, :region), do: language_tag

  @doc """
  Given a source locale X, to return a locale Y where the empty subtags
  have been filled in by the most likely subtags.

  This is written as X ⇒ Y ("X maximizes to Y").

  A subtag is called empty if it is a missing script or region subtag, or it is
  a base language subtag with the value `und`. In the description below,
  a subscript on a subtag x indicates which tag it is from: x<sub>s</sub> is in the
  source, x<sub>m</sub> is in a match, and x<sub>r</sub> is in the final result.

  This operation is performed in the following way:

  ### Lookup

  Lookup each of the following in order, and stop on the first match:

  * language<sub>s</sub>-script<sub>s</sub>-region<sub>s</sub>
  * language<sub>s</sub>-region<sub>s</sub>
  * language<sub>s</sub>-script<sub>s</sub>
  * language<sub>s</sub>
  * und-script<sub>s</sub>

  ### Return

  * If there is no match,either return
    * an error value, or
    * the match for `und`

  * Otherwise there is a match = language<sub>m</sub>-script<sub>m</sub>-region<sub>m</sub>

  * Let x<sub>r</sub> = x<sub>s</sub> if x<sub>s</sub> is not empty, and x<sub>m</sub> otherwise.

  * Return the language tag composed of language<sub>r</sub>-script<sub>r</sub>-region<sub>r</sub> + variants + extensions .

  ## Example

      iex> Cldr.Locale.add_likely_subtags Cldr.LanguageTag.parse!("zh-SG")
      %Cldr.LanguageTag{extensions: %{}, language: "zh", locale: [], private_use: [],
       region: "SG", script: "Hans", transforms: %{}, variant: nil}

  """
  def add_likely_subtags(%LanguageTag{language: language, script: script, region: region} = language_tag) do
    subtags = likely_subtags(locale_name_from(language, script, region)) ||
              likely_subtags(locale_name_from(language, nil, region)) ||
              likely_subtags(locale_name_from(language, script, nil)) ||
              likely_subtags(locale_name_from(language, nil, nil)) ||
              likely_subtags(locale_name_from("und", script, nil)) ||
              likely_subtags(locale_name_from("und", nil, nil))

    Map.merge(subtags, language_tag, fn _k, v1, v2 -> if empty?(v2), do: v1, else: v2 end)
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
  def aliases(key, type) when type in @alias_keys do
    aliases()
    |> Map.get(type)
    |> Map.get(key)
  end

  @likely_subtags Cldr.Config.likely_subtags
  def likely_subtags do
    @likely_subtags
  end

  def likely_subtags(locale_string) do
    Map.get(likely_subtags(), locale_string)
  end
end