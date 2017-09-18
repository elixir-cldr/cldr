defmodule Cldr.LanguageTag do
  alias Cldr.LanguageTag.Parser

  defstruct language: nil, script: nil, region: nil, variant: nil, locale: %{},
            transforms: %{}, extensions: %{}, private_use: []

  def parse(locale_string) do
    Parser.parse(locale_string)
  end

  def parse!(locale_string) do
    Parser.parse!(locale_string)
  end

  def locale(%{language: language, script: script, region: region} = language_tag) do
    locale =
      [language, script, region]
      |> Enum.reject(&is_nil/1)
      |> Enum.join("-")

    {:ok, locale, language_tag}
  end

  def locale(locale_string) when is_binary(locale_string) do
    case Parser.parse(locale_string) do
      {:ok, language_tag} -> locale(language_tag)
      {:error, reason} -> {:error, reason}
    end
  end

  def locale!(%{language: _language, script: _script, region: _region} = language_tag) do
    {:ok, locale, _language_tag} = locale(language_tag)
    locale
  end

  def locale!(locale_string) when is_binary(locale_string) do
    case Parser.parse(locale_string) do
      {:ok, language_tag} -> locale!(language_tag)
      {:error, {exception, reason}} -> raise exception, reason
    end
  end

end