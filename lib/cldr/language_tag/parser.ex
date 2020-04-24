defmodule Cldr.LanguageTag.Parser do
  @moduledoc """
  Parses a CLDR language tag (also referred to as locale string).

  The applicable specification is from [CLDR](http://unicode.org/reports/tr35/#Unicode_Language_and_Locale_Identifiers)
  which is similar based upon [RFC5646](https://tools.ietf.org/html/rfc5646) with some variations.

  """
  alias Cldr.LanguageTag
  alias Cldr.Locale
  alias Cldr.LanguageTag.{U, T}

  @doc """
  Parse a locale name into a `t:Cldr.LanguageTag.t/0`

  * `locale_name` is a string representation of a language tag
    as defined by RFC5646

  Returns

  * `{:ok, language_tag}` or

  * `{:error, reasons}`

  """
  def parse(locale) do
    case Cldr.Rfc5646.Parser.parse(normalize_locale_name(locale)) do
      {:ok, language_tag} ->
        normalized_tag =
          language_tag
          |> structify(LanguageTag)
          |> Map.put(:requested_locale_name, locale)
          |> normalize_language
          |> normalize_script
          |> normalize_variants
          |> normalize_territory
          |> U.canonicalize_locale_keys()
          |> T.canonicalize_transform_keys()

        {:ok, normalized_tag}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp structify(list, module) do
    struct(module, list)
  end

  @doc """
  Parse a locale name into a `t:Cldr.LanguageTag.t/0`

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

  defp normalize_locale_name(name) do
    name
    |> String.downcase()
    |> Locale.locale_name_from_posix()
  end

  defp normalize_language(%LanguageTag{language: nil} = language_tag), do: language_tag

  defp normalize_language(%LanguageTag{language: language} = language_tag) do
    language_tag
    |> Map.put(:language, String.downcase(language))
  end

  defp normalize_script(%LanguageTag{script: nil} = language_tag), do: language_tag

  defp normalize_script(%LanguageTag{script: script} = language_tag) do
    language_tag
    |> Map.put(:script, script |> String.downcase() |> String.capitalize())
  end

  defp normalize_territory(%LanguageTag{territory: nil} = language_tag), do: language_tag

  defp normalize_territory(%LanguageTag{territory: territory} = language_tag)
       when is_integer(territory) do
    territory =
      case territory do
        territory when territory < 10 -> "00#{territory}"
        territory when territory < 100 -> "0#{territory}"
        _ -> "#{territory}"
      end

    territory =
      case Cldr.validate_territory(territory) do
        {:ok, territory} -> territory
        {:error, _} -> territory
      end

    Map.put(language_tag, :territory, territory)
  end

  defp normalize_territory(%LanguageTag{territory: territory} = language_tag) do
    territory =
      case Cldr.validate_territory(territory) do
        {:ok, territory} -> territory
        {:error, _} -> nil
      end

    Map.put(language_tag, :territory, territory)
  end

  defp normalize_variants(%LanguageTag{language_variant: nil} = language_tag), do: language_tag

  defp normalize_variants(%LanguageTag{language_variant: variant} = language_tag) do
    language_tag
    |> Map.put(:language_variant, String.upcase(variant))
  end

  @doc false
  def canonicalize_key([key, valid, default], param) when is_function(valid) do
    case valid.(param) do
      {:ok, value} -> {key, value}
      {:error, _} -> {key, default}
    end
  end

  def canonicalize_key([key, :any, default], param) do
    value = param || default
    {key, value}
  end

  def canonicalize_key([key, valid, default], param) do
    value = if param in valid, do: param, else: default
    {key, value}
  end

  def canonicalize_key(key, value) when is_atom(key) do
    {key, value}
  end
end
