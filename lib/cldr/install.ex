defmodule Cldr.Install do
  @moduledoc """
  Provides functions for installing locales.

  When installed as a package on from [hex](http://hex.pm), `Cldr` has only
  the default locales `["en", "root"]` installed and configured.

  When other locales are added to the configuration `Cldr` will attempt to
  download the locale from [github](https://github.com/kipcole9/cldr)
  during compilation.

  If `Cldr` is installed from github directly then all locales are already
  installed.

  """

  defdelegate client_data_dir(config), to: Cldr.Config
  defdelegate client_locales_dir(config), to: Cldr.Config
  defdelegate locale_filename(locale), to: Cldr.Config

  @doc """
  Install all the configured locales.

  """
  def install_known_locale_names(config) do
    config
    |> Cldr.Config.known_locale_names()
    |> Enum.each(&install_locale_name(&1, config))

    :ok
  end

  @doc """
  Install all available locales.
  """
  def install_all_locale_names(config) do
    Cldr.Config.all_locale_names()
    |> Enum.each(&install_locale_name(&1, config))

    :ok
  end

  @doc """
  Download the requested locale from github into the
  client application's cldr data directory.

  * `locale` is any locale returned by `Cldr.known_locale_names/1`

  * `options` is a keyword list.  Currently the only supported
    option is `:force` which defaults to `false`.  If `truthy` the
    locale will be installed or re-installed.

  The data directory is typically `priv/cldr/locales`.

  This function is intended to be invoked during application
  compilation when a valid locale is configured but is not yet
  installed in the application.

  An https request to the master github repository for `Cldr` is made
  to download the correct version of the locale file which is then
  written to the configured data directory.

  """
  def install_locale_name(locale_name, config, options \\ []) do
    force_download? = config.force_locale_download || options[:force]

    if !locale_installed?(locale_name, config) || force_download? do
      ensure_client_dirs_exist!(client_locales_dir(config))
      Application.ensure_started(:inets)
      Application.ensure_started(:ssl)
      Application.ensure_started(Cldr.Config.app_name())
      do_install_locale_name(locale_name, config, locale_name in Cldr.Config.all_locale_names())
    else
      output_file_name = locale_output_file_name(locale_name, config)
      Cldr.maybe_log("Locale already installed and found at #{inspect(output_file_name)}")
      :already_installed
    end
  end

  # Normally a library function shouldn't raise an exception (thats up
  # to the client app) but we install locales only at compilation time
  # and an exception then is the appropriate response.
  defp do_install_locale_name(locale_name, _config, false) do
    raise Cldr.UnknownLocaleError,
          "Failed to install the locale named #{inspect(locale_name)}. The locale name is not known."
  end

  defp do_install_locale_name(locale_name, config, true) do
    require Logger

    output_file_name = locale_output_file_name(locale_name, config)
    url = String.to_charlist("#{base_url()}#{locale_filename(locale_name)}")

    case :httpc.request(:get, {url, headers()}, https_opts(), []) do
      {:ok, {{_version, 200, 'OK'}, _headers, body}} ->
        output_file_name
        |> File.write!(body)

        Logger.bare_log(:info, "Downloaded locale #{inspect(locale_name)}")
        {:ok, output_file_name}

      {_, {{_version, code, message}, _headers, _body}} ->
        Logger.bare_log(
          :error,
          "Failed to download locale #{inspect(locale_name)} from #{url}. " <>
            "HTTP Error: (#{code}) #{inspect(message)}"
        )

        {:error, code}

      {:error, {:failed_connect, [{_, {host, _port}}, {_, _, sys_message}]}} ->
        Logger.bare_log(
          :error,
          "Failed to connect to #{inspect(host)} to download " <>
            "locale #{inspect(locale_name)}. Reason: #{inspect(sys_message)}"
        )

        {:error, sys_message}
    end
  end

  defp locale_output_file_name(locale_name, config) do
    [client_locales_dir(config), "/", locale_filename(locale_name)]
    |> :erlang.iolist_to_binary()
  end

  defp headers do
    # [{'Connection', 'close'}]
    []
  end

  @certificate_locations [
                           # Configured cacertfile
                           Application.get_env(Cldr.Config.app_name(), :cacertfile),

                           # Populated if hex package CAStore is configured
                           if(Code.ensure_loaded?(CAStore), do: CAStore.file_path()),

                           # Populated if hex package certfi is configured
                           if(Code.ensure_loaded?(:certifi),
                             do: :certifi.cacertfile() |> List.to_string()
                           ),

                           # Debian/Ubuntu/Gentoo etc.
                           "/etc/ssl/certs/ca-certificates.crt",

                           # Fedora/RHEL 6
                           "/etc/pki/tls/certs/ca-bundle.crt",

                           # OpenSUSE
                           "/etc/ssl/ca-bundle.pem",

                           # OpenELEC
                           "/etc/pki/tls/cacert.pem",

                           # CentOS/RHEL 7
                           "/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem",

                           # Open SSL on MacOS
                           "/usr/local/etc/openssl/cert.pem",

                           # MacOS & Alpine Linux
                           "/etc/ssl/cert.pem"
                         ]
                         |> Enum.reject(&is_nil/1)

  def certificate_store do
    @certificate_locations
    |> Enum.find(&File.exists?/1)
    |> raise_if_no_cacertfile
    |> :erlang.binary_to_list()
  end

  defp raise_if_no_cacertfile(nil) do
    raise RuntimeError, """
    No certificate trust store was found.
    Tried looking for: #{inspect(@certificate_locations)}

    A certificate trust store is required in
    order to download locales for your configuration.

    Since ex_cldr could not detect a system
    installed certificate trust store one of the
    following actions may be taken:

    1. Install the hex package `castore`. It will
       be automatically detected after recompilation.

    2. Install the hex package `certifi`. It will
       be automatically detected after recomilation.

    3. Specify the location of a certificate trust store
       by configuring it in `config.exs`:

       config :ex_cldr,
         cacertfile: "/path/to/cacertfile",
         ...

    """
  end

  defp raise_if_no_cacertfile(file) do
    file
  end

  defp https_opts do
    [
      ssl: [
        verify: :verify_peer,
        cacertfile: certificate_store(),
        customize_hostname_check: [
          match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
        ]
      ]
    ]
  end

  # Builds the base url to retrieve a locale file from github.
  #
  # The url is built using the version number of the `Cldr` application.
  # If the version is a `-dev` version then the locale file is downloaded
  # from the master branch.
  #
  # This requires that a branch is tagged with the version number before creating
  # a release or publishing to hex.

  @base_url "https://raw.githubusercontent.com/elixir-cldr/cldr/"
  defp base_url do
    [@base_url, branch_from_version(), "/priv/cldr/locales/"]
    |> :erlang.iolist_to_binary()
  end

  # Returns the version of ex_cldr
  defp app_version do
    cond do
      spec = Application.spec(Cldr.Config.app_name()) ->
        Keyword.get(spec, :vsn) |> :erlang.list_to_binary()

      Code.ensure_loaded?(Cldr.Mixfile) ->
        module = Module.concat(Cldr, Mixfile)
        Keyword.get(module.project(), :version)

      true ->
        :error
    end
  end

  # Get the git branch name based upon the app version
  defp branch_from_version do
    version = app_version()

    if String.contains?(version, "-dev") do
      "master"
    else
      "v#{version}"
    end
  end

  @doc """
  Returns a `boolean` indicating if the requested locale is installed.

  No checking of the validity of the `locale` itself is performed.  The
  check is based upon whether there is a locale file installed in the
  client application or in `Cldr` itself.
  """
  def locale_installed?(locale, config) do
    case Cldr.Config.locale_path(locale, config) do
      {:ok, _path} -> true
      _ -> false
    end
  end

  @doc """
  Returns the full pathname of the locale's json file.

  * `locale` is any locale returned by `Cldr.known_locale_names/1`

  No checking of locale validity is performed.
  """
  def client_locale_file(locale, config) do
    Path.join(client_locales_dir(config), "#{locale}.json")
  end

  # Create the client app locales directory and any directories
  # that don't exist above it.
  defp ensure_client_dirs_exist!(dir) do
    File.mkdir_p(dir)
  end
end
