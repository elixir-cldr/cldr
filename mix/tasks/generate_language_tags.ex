defmodule Mix.Tasks.Cldr.GenerateLanguageTags do
  @moduledoc """
  Mix task to generate the language tags for all
  available locales.
  """

  use Mix.Task

  @impl Mix.Task
  @shortdoc "Generate language tags for all available locales"
  @test_backend TestBackend.Cldr

  @doc false
  def run(_) do
    unless Mix.env() == :test do
      raise "Must be run in :test mode to ensure that all locales are configured"
    end

    # We set the gettext locale name to nil because we can't tell in advance
    # what the gettext locale name will be (if any)
    language_tags =
      for locale_name <- Cldr.all_locale_names() -- Cldr.Config.non_language_locale_names() do
        with {:ok, canonical_tag} <-
               Cldr.Locale.canonical_language_tag(locale_name, @test_backend) do
          language_tag =
            canonical_tag
            |> Map.put(:cldr_locale_name, locale_name)
            |> Map.put(:gettext_locale_name, nil)
            |> Map.put(:backend, nil)

          {locale_name, language_tag}
        else
          {:error, {exception, reason}} ->
            raise exception, reason
        end
      end
      |> Map.new()

    output_path = Path.expand(Path.join("priv/cldr/", "language_tags.ebin"))
    File.write!(output_path, :erlang.term_to_binary(language_tags))
  end
end
