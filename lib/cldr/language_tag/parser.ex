defmodule Cldr.LanguageTag.Parser do
  @moduledoc """
  Parses a CLDR language tag (also referred to as locale string).

  The applicable specification is from [CLDR](http://unicode.org/reports/tr35/#Unicode_Language_and_Locale_Identifiers)
  which is similar based upon [RFC56469](https://tools.ietf.org/html/rfc5646) with some variations.

  This module provides functions to parse a language tag (locale string).  To be
  consistent with the rest of `Cldr`, the term locale string will be preferred.
  """
  alias Cldr.LanguageTag
  alias Cldr.Config

  @grammar ABNF.load_file(Cldr.data_dir <> "/rfc5646.abnf")

  def parse(locale) when is_list(locale) do
    case return_parse_result(ABNF.apply(@grammar, "language-tag", locale, %LanguageTag{}), locale) do
      {:ok, language_tag} ->
        normalized_tag =
          language_tag
          |> canonicalize_locale_keys
          |> normalize_lang_script_region
        {:ok, normalized_tag}
      {:error, reason} ->
        {:error, reason}
    end
  end

  def parse(locale) when is_binary(locale) do
    locale
    |> Cldr.Locale.normalize_locale_name
    |> String.to_charlist
    |> parse
  end

  def parse!(locale) do
    case parse(locale) do
      {:ok, language_tag} -> language_tag
      {:error, {exception, reason}} -> raise exception, reason
    end
  end

  def lenient_parse(locale) do
    case parse_output = parse(locale) do
      {:ok, result} -> {:ok, result}
      {:error, reason} -> return_minimum_viable_tag(parse_output.state, reason)
    end
  end

  defp canonicalize_locale_keys(%Cldr.LanguageTag{locale: nil} = language_tag) do
    language_tag
  end

  defp canonicalize_locale_keys(%Cldr.LanguageTag{locale: locale} = language_tag) do
    canon_locale = Enum.map(locale, fn {k, v} ->
      if Map.has_key?(locale_key_map(), k) do
        canonicalize_locale_key(locale_key_map()[k], v)
      else
        {k, v}
      end
    end)
    |> upcase(:currency)

    Map.put(language_tag, :locale, canon_locale)
  end

  defp normalize_lang_script_region(%{language: language, script: script, region: region} = language_tag) do
    language = normalize_language(language)
    script = normalize_script(script)
    region = normalize_region(region)

    language_tag
    |> Map.put(:language, language)
    |> Map.put(:script, script)
    |> Map.put(:region, region)
  end

  defp normalize_language(nil), do: nil
  defp normalize_language(language) do
    String.downcase(language)
  end

  defp normalize_script(nil), do: nil
  defp normalize_script(script) do
    script
    |> String.downcase
    |> String.capitalize
  end

  defp normalize_region(nil), do: nil
  defp normalize_region(region) do
    region
    |> String.upcase
  end

  defp return_parse_result(%{rest: [], state: state}, _locale), do: {:ok, state}
  defp return_parse_result(nil, locale) do
    {:error, {Cldr.InvalidLanguageTag, "Could not parse language tag.  Error was detected at #{inspect locale}"}}
  end
  defp return_parse_result(%{rest: rest}, _locale) do
    {:error, {Cldr.InvalidLanguageTag, "Could not parse language tag.  Error was detected at #{inspect rest}"}}
  end

  defp return_minimum_viable_tag(%{language: language, script: script, region: region} = language_tag, _reason)
  when language != nil and script != nil and region != nil do
    {:ok, language_tag}
  end

  defp return_minimum_viable_tag(_language_tag, reason) do
    {:error, reason}
  end

  defp canonicalize_locale_key([key, valid, default], param) do
    value = if param in valid, do: param, else: default
    {key, value}
  end

  defp canonicalize_locale_key(key, value) when is_atom(key) do
    {key, value}
  end

  # from => [to, valid_list, default]
  @locale_map %{
    "ca" => [:calendar,                 Cldr.known_calendars, "gregory"],
    "co" => [:collation,                Config.collations(), "standard"],
    "ka" => [:alternative_collation,    ["noignore", "shifted"], "shifted"],
    "kb" => [:backward_level2,          Config.true_false(), "false"],
    "kc" => [:case_level,               Config.true_false(), "false"],
    "kn" => [:numeric,                  Config.true_false(), "false"],
    "kh" => [:hiaragana_quarternary,    Config.true_false(), "true"],
    "kk" => [:normalization,            Config.true_false(), "true"],
    "kf" => [:case_first,               ["upper", "lower", "false"], "false"],
    "ks" => [:strength,                 ["level1", "level2", "level3", "level4", "identic"], "level3"],
    "cu" => [:currency,                 Enum.map(Cldr.known_currencies, &String.downcase/1), nil],
    "cf" => [:currency_format,          ["standard", "account"], "standard"],
    "nu" => [:number_system,            Cldr.known_number_systems, nil],
    "em" => [:emoji_style,              ["emoji", "text", "default"], "default"],
    "fw" => [:first_day_of_week,        Config.days_of_week(), "mon"],
    "hc" => [:hour_cycle,               ["h12", "h23", "h11", "h24"], "h23"],
    "lb" => [:line_break_style,         ["strict", "normal", "loose"], "normal"],
    "lw" => [:line_break_word,          ["normal", "breakall", "keepall"], "normal"],
    "ms" => [:measurement_system,       ["metric", "ussystem", "uksystem"], "metric"],
    "ss" => [:sentence_break_supression,["standard", "none"], "standard"],
    "sd" => :subdivision,
    "vt" => :variable_top,
    "tz" => :timezone,
    "va" => :variant,
    "rg" => :region_override
  }

  defp locale_key_map do
    @locale_map
  end

  defp upcase(locale, :currency = key) do
    if currency = locale[key] do
      Keyword.put(locale, key, String.upcase(currency))
    else
      locale
    end
  end
end

