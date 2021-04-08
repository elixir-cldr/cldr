if File.exists?(Cldr.Config.download_data_dir()) do
  defmodule Mix.Tasks.Cldr.Install.Locales do
    @moduledoc """
    Installs the cldr core data and configured locales into the application.  By
    default it installs into the ./priv/cldr directory.

    ## Arguments

    * `backend` is the name of any backend module for which
      the locales will be installed. This is a required parameter
      and there is no default.

    ## Example

        % mix cldr.install.locales MyApp.Cldr

    """

    use Mix.Task

    @shortdoc "Install all configured `Cldr` locales."

    @doc false
    def run([]) do
      raise ArgumentError, "A Cldr backend module must be provided"
    end

    def run([backend]) do
      module = Module.concat([backend])
      config = module.__cldr__(:config)
      Cldr.Install.install_known_locale_names(config)
    end
  end
end
