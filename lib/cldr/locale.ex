defmodule Cldr.Locale do
  @moduledoc """
  Parse and process locale json as defined by [Unicode](http://unicode.org/reports/tr35/#Unicode_Language_and_Locale_Identifiers)
  """
  alias Cldr.LanguageTag

  @typedoc "The name of a locale in a string format"
  @type name :: String.t

  @spec normalize_locale_name(name) :: name
  def normalize_locale_name(name) do
    String.replace(name, "_", "-")
  end

  def locale_from_language_tag(%LanguageTag{language: language, script: script, region: region}) do
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

  * If the tag is grandfathered in the supplemental data, then return it.

  * Remove the script code 'Zzzz' and the region code 'ZZ' if they occur.

  * Get the components of the cleaned-up source tag (languages, scripts, and
  regions), plus any variants and extensions.
  """
  def substitute_aliases(%LanguageTag{} = language_tag) do
    language_tag
    |> substitute(:language)
    |> substitute(:script)
    |> substitute(:region)
    |> merge(language_tag)
  end

  defp substitute(language_tag, _key) do
    language_tag
  end

  defp merge(_language_tag1, _language_tag2) do

  end

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

  * Input is `ZH-ZZZZ-SG`.

  * Normalize to `zh-SG`.

  * Lookup in table. No match.

  * Lookup `zh`, and get the match `zh-Hans-CN`. Substitute `SG`, and return `zh-Hans-SG`.

  """
  def add_likely_subtags do

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