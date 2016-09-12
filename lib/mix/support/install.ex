defmodule Cldr.Install do
  @moduledoc """
  Support for installing locales on demand.

  When installed as a package on from [hex](http://hex.pm), `Cldr` has only
  the default locale, "en", installed and configured.

  When other locales are added to the configuration `Cldr` will attempt to
  download the locale from [github](https://github.com/kipcole9/cldr)
  during compilation.

  If `Cldr` is installed from github directly then all locales are already
  installed.
  """

  @doc """
  Install all the configured locales.
  """
  def install_known_locales do
    ensure_client_dirs_exist!(client_locale_dir())
    Enum.each Cldr.known_locales(), &install_locale/1
    :ok
  end

  @doc """
  Install all available locales.
  """
  def install_all_locales do
    ensure_client_dirs_exist!(client_locale_dir())
    Enum.each Cldr.all_locales(), &install_locale/1
    :ok
  end

  @doc """
  Download the requested locale from github into the
  client app data directory.

  The target directory is typically `./priv/cldr/locales`.
  """
  def install_locale(locale) do
    if !Cldr.Config.locale_path(locale) do
      IO.puts "Downloading and installing #{inspect locale} to #{client_locale_dir()}"
    end
  end

  @doc """
  Returns the directory where the client app stores `Cldr` data
  """
  def client_data_dir do
    Cldr.Config.data_dir()
  end

  @doc """
  Returns the directory into which locale files are stored
  for a client application.

  The directory is relative to the configured data directory for
  a client application.  That is typically `./priv/cldr`
  so that locales typically get stored in `./priv/cldr/locales`.
  """
  def client_locale_dir do
    "#{client_data_dir()}/locales"
  end

  def client_locale_file(locale) do
    Path.join(client_locale_dir(), "#{locale}.json")
  end

  @doc """
  Returns the directory where `Cldr` stores the core CLDR data
  """
  def cldr_data_dir do
    Path.join(Cldr.Config.cldr_home(), "/priv/cldr")
  end

  @doc """
  Returns the directory where `Cldr` stores locales that can be
  used in a client app.

  Current strategy is to only package the "en" locale in `Cldr`
  itself and that any other locales are downloaded when configured
  and the client app is compiled with `Cldr` as a `dep`.
  """
  def cldr_locale_dir do
    Path.join(cldr_data_dir(), "/locales")
  end

  @doc """
  Returns the path of the consolidated locale file stored in the `Cldr`
  package (not the client application).

  Since these consolidated files go in the github repo we consoldiate
  them into the `Cldr` data directory which is
  `Cldr.Config.cldr_home() <> /priv/cldr/locales`.
  """
  def consolidated_locale_file(locale) do
    Path.join(cldr_locale_dir(), "#{locale}.json")
  end

  # Create the client app locales directory and any directories
  # that don't exist above it.
  defp ensure_client_dirs_exist!(dir) do
    paths = String.split(dir, "/")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&(String.replace_prefix(&1, "", "/")))
    do_ensure_client_dirs(paths)
  end

  defp do_ensure_client_dirs([h | []]) do
    create_dir(h)
  end

  defp do_ensure_client_dirs([h | t]) do
    create_dir(h)
    do_ensure_client_dirs([h <> hd(t) | tl(t)])
  end

  defp create_dir(dir) do
    case File.mkdir(dir) do
      :ok ->
        :ok
      {:error, :eexist} ->
        :ok
      {:error, :eisdir} ->
        :ok
      {:error, code} ->
        raise RuntimeError,
          message: "Couldn't create #{dir}: #{inspect code}"
    end
  end
end