defmodule Cldr.Install do


  def install_known_locales do
    ensure_client_locale_dir_exists!()
    Enum.each Cldr.known_locales(), &install_locale/1
    :ok
  end

  def install_all_locales do
    ensure_client_locale_dir_exists!()
    Enum.each Cldr.all_locales(), &install_locale/1
    :ok
  end

  @doc """
  Download the requested locale from github into the
  client app data directory.

  The target directory is typically `./priv/cldr/locales`.
  """
  def install_locale(locale) do
    IO.puts "Downloading and installing #{inspect locale} to #{client_locale_dir()}"
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

  def ensure_client_locale_dir_exists! do
    case File.mkdir(client_locale_dir()) do
      :ok ->
        :ok
      {:error, :eexist} ->
        :ok
      {:error, code} ->
        raise RuntimeError,
          message: "Couldn't create #{client_locale_dir()}: #{inspect code}"
    end
  end

  def ensure_client_data_dir_exists! do
    case File.mkdir(client_data_dir()) do
      :ok ->
        :ok
      {:error, :eexist} ->
        :ok
      {:error, code} ->
        raise RuntimeError,
          message: "Couldn't create #{client_data_dir()}: #{inspect code}"
    end
  end
end