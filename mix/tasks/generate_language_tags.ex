defmodule Mix.Tasks.Cldr.GenerateLanguageTags do
  @moduledoc """
  Mix task to generate the language tags for all
  available locales.
  """

  use Mix.Task

  @impl Mix.Task
  @shortdoc "Generate language tags for all available locales"
  @test_backend MyApp.Cldr

  @doc false
  def run(_) do
    # We set the gettext locale name to nil because we can't tell in advance
    # what the gettext locale name will be (if any)
    locale_count = length(Cldr.all_locale_names() -- Cldr.Config.non_language_locale_names())
    IO.puts "Generating language tags for #{locale_count} locales"

    language_tags =
      for locale_name <- Cldr.all_locale_names() -- Cldr.Config.non_language_locale_names() do
        with {:ok, canonical_tag} <-
               Cldr.Locale.canonical_language_tag(locale_name, @test_backend) do

          language_tag =
            canonical_tag
            |> Map.put(:cldr_locale_name, locale_name)
            |> Map.put(:gettext_locale_name, nil)
            |> Map.put(:backend, nil)
            |> Map.put(:rbnf_locale_name, rbnf_locale_name(locale_name))

          {locale_name, language_tag}
        else
          {:error, {exception, reason}} ->
            raise exception, reason
        end
      end
      |> Map.new()

    output_path = Path.expand(Path.join("priv/cldr/", "language_tags.ebin"))
    File.write!(output_path, :erlang.term_to_binary(language_tags))
    IO.puts "Wrote binary term file of #{Enum.count(language_tags)} language tags to #{output_path}"
  end

  defp rbnf_locale_name(locale_name) do
    rbnf_locale_names =
      Cldr.Rbnf.Config.rbnf_locale_names()
      |> Enum.map(&({&1, &1}))
      |> Map.new

    parts =
      locale_name
      |> Atom.to_string()
      |> String.split("-")

    case parts do
      [_language] ->
        Map.get(rbnf_locale_names, locale_name) ||
        parent_rbnf_locale(locale_name)
      [language, territory] ->
        Map.get(rbnf_locale_names, locale_name) ||
        Map.get(rbnf_locale_names, String.to_atom(language <> "-" <> territory)) ||
        Map.get(rbnf_locale_names, String.to_atom(language)) ||
        parent_rbnf_locale(locale_name)
      [language, variant, territory] ->
        Map.get(rbnf_locale_names, locale_name) ||
        Map.get(rbnf_locale_names, String.to_atom(language <> "-" <> variant)) ||
        Map.get(rbnf_locale_names, String.to_atom(language <> "-" <> territory)) ||
        Map.get(rbnf_locale_names, String.to_atom(language)) ||
        parent_rbnf_locale(locale_name)
      [language, territory, "u", "va", _variant] ->
        rbnf_locale_name(String.to_atom("#{language}-#{territory}"))
    end
  end

  defp parent_rbnf_locale(locale) do
    if parent = Map.get(Cldr.Locale.parent_locale_map(), locale) do
      rbnf_locale_name(parent)
    else
      nil
    end
  end
end
