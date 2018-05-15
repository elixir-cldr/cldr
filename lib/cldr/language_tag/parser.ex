defmodule Cldr.LanguageTag.Parser do
  @moduledoc """
  Parses a CLDR language tag (also referred to as locale string).

  The applicable specification is from [CLDR](http://unicode.org/reports/tr35/#Unicode_Language_and_Locale_Identifiers)
  which is similar based upon [RFC5646](https://tools.ietf.org/html/rfc5646) with some variations.

  This module provides functions to parse a language tag (locale string).  To be
  consistent with the rest of `Cldr`, the term locale string will be preferred.
  """
  alias Cldr.LanguageTag
  alias Cldr.Config
  alias Cldr.Locale

  @doc """
  Parse a locale name into a `Cldr.LanguageTag.t`

  * `locale_name` is a string representation of a language tag
    as defined by RFC5646

  Returns

  * `{:ok, language_tag}` or

  * `{:error, reasons}`

  """
  def parse(locale) when is_list(locale) do
    case return_parse_result(Cldr.Rfc5646.parse(:"language-tag", locale), locale) do
      {:ok, language_tag} ->
        normalized_tag =
          language_tag
          |> extract_keys
          |> Map.put(:requested_locale_name, List.to_string(locale))
          |> canonicalize_locale_keys
          |> canonicalize_transform_keys

        {:ok, normalized_tag}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def parse(locale_name) when is_binary(locale_name) do
    locale_name
    |> normalize_locale_name
    |> String.to_charlist()
    |> parse
  end

  @doc """
  Parse a locale name into a `Cldr.LanguageTag.t`

  * `locale_name` is a string representation of a language tag
    as defined by RFC5646

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

  defp extract_keys([{:langtag, _value, subtags}]) do
    Enum.reduce(subtags, %LanguageTag{}, fn {key, value, children}, language_tag ->
      extract_key(key, value, children, language_tag)
    end)
  end

  defp extract_keys([{:privateuse = key, value, subtags}]) do
    extract_key(key, value, subtags, %LanguageTag{})
    |> Map.put(:requested_locale_name, value)
  end

  defp extract_keys([{:grandfathered = key, value, subtags}]) do
    extract_key(key, value, subtags, %LanguageTag{})
    |> Map.put(:requested_locale_name, value)
  end

  defp extract_key(:language = key, value, _children, language_tag) do
    language = normalize_language(value)
    Map.put(language_tag, key, language)
  end

  defp extract_key(:grandfathered, value, _subtags, language_tag) do
    Map.put(language_tag, :requested_locale_name, value)
  end

  defp extract_key(:script = key, value, _children, language_tag) do
    script = normalize_script(value)
    Map.put(language_tag, key, script)
  end

  defp extract_key(:region, value, _children, language_tag) do
    territory = normalize_territory(value)
    Map.put(language_tag, :territory, territory)
  end

  defp extract_key(:variant = key, value, _children, language_tag) do
    variant = normalize_variant(value)
    Map.put(language_tag, key, variant)
  end

  defp extract_key(:privateuse, value, _children, language_tag) do
    Map.put(language_tag, :private_use, value)
  end

  defp extract_key(:extensions, _value, extensions, language_tag) do
    Enum.reduce(extensions, language_tag, fn
      {extension, value, subtags}, language_tag when extension in [:locale, :transform] ->
        Map.put(language_tag, extension, extract_extension(extension, value, subtags))

      {:extension = extension, value, subtags}, language_tag ->
        [key, value] = extract_extension(extension, value, subtags)
        extensions = language_tag.extensions
        Map.put(language_tag, :extensions, Map.put(extensions, key, value))
    end)
  end

  defp extract_key(_key, _value, _children, language_tag) do
    language_tag
  end

  def extract_extension(:extension, value, _subtags) do
    String.split(value, "-", parts: 2)
  end

  def extract_extension(:locale, _value, subtags) do
    Enum.reduce(subtags, %{}, fn
      {:keyword, _value, [{:key, key, _}, {:literal, _, _}, {:type, value, _}]}, locale_tags ->
        Map.put(locale_tags, key, value)

      _, locale_tags ->
        locale_tags
    end)
  end

  defp canonicalize_locale_keys(%Cldr.LanguageTag{locale: nil} = language_tag) do
    language_tag
  end

  defp canonicalize_locale_keys(%Cldr.LanguageTag{locale: locale} = language_tag) do
    canon_locale =
      Enum.map(locale, fn {k, v} ->
        if Map.has_key?(locale_key_map(), k) do
          canonicalize_key(locale_key_map()[k], v)
        else
          {k, v}
        end
      end)
      |> Enum.into(%{})

    Map.put(language_tag, :locale, canon_locale)
  end

  defp canonicalize_transform_keys(%Cldr.LanguageTag{transform: nil} = language_tag) do
    language_tag
  end

  defp canonicalize_transform_keys(%Cldr.LanguageTag{transform: locale} = language_tag) do
    canon_transform =
      Enum.map(locale, fn {k, v} ->
        if Map.has_key?(transform_key_map(), k) do
          canonicalize_key(transform_key_map()[k], v)
        else
          {k, v}
        end
      end)
      |> Enum.into(%{})

    Map.put(language_tag, :transform, canon_transform)
  end

  defp normalize_locale_name(name) do
    name
    |> String.downcase()
    |> Locale.locale_name_from_posix()
  end

  defp normalize_language(nil), do: nil

  defp normalize_language(language) do
    String.downcase(language)
  end

  defp normalize_script(nil), do: nil

  defp normalize_script(script) do
    script
    |> String.downcase()
    |> String.capitalize()
  end

  defp normalize_territory(nil), do: nil

  defp normalize_territory(territory) do
    String.upcase(territory)
  end

  defp normalize_variant(nil), do: nil

  defp normalize_variant(variant) do
    String.upcase(variant)
  end

  defp return_parse_result([{_rule, _name, children}], locale) do
    remaining = Abnf.Operators.advance(children, locale)

    if remaining == '' do
      {:ok, children}
    else
      {:error, language_tag_error(remaining)}
    end
  end

  defp return_parse_result(:error, locale_name) do
    {:error, language_tag_error(locale_name)}
  end

  defp canonicalize_key([key, valid, default], param) when is_function(valid) do
    case valid.(param) do
      {:ok, value} -> {key, value}
      {:error, _} -> {key, default}
    end
  end

  defp canonicalize_key([key, valid, default], param) do
    value = if param in valid, do: param, else: default
    {key, value}
  end

  defp canonicalize_key(key, value) when is_atom(key) do
    {key, value}
  end

  # from => [to, valid_list, default]
  @locale_map %{
    "ca" => [:calendar, &Cldr.validate_calendar/1, "gregory"],
    "co" => [:collation, Config.collations(), "standard"],
    "ka" => [:alternative_collation, ["noignore", "shifted"], "shifted"],
    "kb" => [:backward_level2, Config.true_false(), "false"],
    "kc" => [:case_level, Config.true_false(), "false"],
    "kn" => [:numeric, Config.true_false(), "false"],
    "kh" => [:hiaragana_quarternary, Config.true_false(), "true"],
    "kk" => [:normalization, Config.true_false(), "true"],
    "kf" => [:case_first, ["upper", "lower", "false"], "false"],
    "ks" => [:strength, ["level1", "level2", "level3", "level4", "identic"], "level3"],
    "cu" => [:currency, &Cldr.validate_currency/1, nil],
    "cf" => [:currency_format, ["standard", "account"], "standard"],
    "nu" => [:number_system, &Cldr.validate_number_system/1, nil],
    "em" => [:emoji_style, ["emoji", "text", "default"], "default"],
    "fw" => [:first_day_of_week, Config.days_of_week(), "mon"],
    "hc" => [:hour_cycle, ["h12", "h23", "h11", "h24"], "h23"],
    "lb" => [:line_break_style, ["strict", "normal", "loose"], "normal"],
    "lw" => [:line_break_word, ["normal", "breakall", "keepall"], "normal"],
    "ms" => [:measurement_system, ["metric", "ussystem", "uksystem"], "metric"],
    "ss" => [:sentence_break_supression, ["standard", "none"], "standard"],
    "sd" => :subdivision,
    "vt" => :variable_top,
    "tz" => :timezone,
    "va" => :variant,
    "rg" => :region_override
  }

  defp locale_key_map do
    @locale_map
  end

  @transform_map %{
    "m0" => :mechanism,
    "s0" => :source,
    "d0" => :destination,
    "i0" => :input_method,
    "k0" => :keyboard,
    "t0" => :machine,
    "h0" => :hybrid,
    "x0" => :private
  }

  defp transform_key_map do
    @transform_map
  end

  defp language_tag_error(locale_name) do
    {
      Cldr.InvalidLanguageTag,
      "Could not parse language tag.  Error was detected at #{inspect(locale_name)}"
    }
  end
end
