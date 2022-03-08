defmodule Mix.Tasks.Cldr.Install.Locales do
  @moduledoc """
  Installs the cldr core data and configured locales into the application.  By
  default it installs into the ./priv/cldr directory.

  ## Arguments

  * `backend` is the name of any backend module for which
    the locales will be installed. This is a required parameter
    and there is no default.

  ## Options

  * `--force-locale-download` will force locales
    to be downloaded even if they are already
    available.

  ## Examples

      % mix cldr.install.locales MyApp.Cldr
      % mix cldr.install.locales --force-locale-download MyApp.Cldr

  """

  use Mix.Task

  @shortdoc "Install all configured `Cldr` locales for a given backend."

  @backend_error_message "A Cldr backend module name must be provided"

  @doc false
  def run([]) do
    raise ArgumentError, @backend_error_message
  end

  @options [strict: [force_locale_download: :boolean]]

  def run(args) do
    case OptionParser.parse!(args, @options) do
      {_options, []} ->
        raise ArgumentError, @backend_error_message

      {options, backend} ->
        do_install(backend, options)
    end
  end

  defp do_install(backend, options) do
    module = Module.concat(backend)
    config = module.__cldr__(:config)

    config =
      if Keyword.get(options, :force_locale_download) do
        Map.put(config, :force_locale_download, true)
      else
        config
      end

    Cldr.Install.install_known_locale_names(config)
  end
end
