defmodule Mix.Tasks.Cldr.GenerateLanguageTags do
  @moduledoc """
  Mix task to generate the language tags for all
  available locales.
  """

  use Mix.Task

  @shortdoc "Generate langauge tags for all available locales"

  @doc false
  def run(_) do
    unless Mix.env() == :test do
      raise "Must be run in :test mode to ensure that all locales are configured"
    end

    # We set the gettext locale name to nil because we can't tell in advance
    # what the gettext locale name will be (if any)
    language_tags =
      for locale_name <- Cldr.all_locale_names() do
        language_tag = Map.put(Cldr.Locale.new!(locale_name), :gettext_locale_name, nil)
        {locale_name, language_tag}
      end
      |> Enum.into(%{})

    output_path = Path.join(Cldr.Config.source_data_dir(), "language_tags.ebin")
    File.write!(output_path, :erlang.term_to_binary(language_tags))
  end
end
