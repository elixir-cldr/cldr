defmodule Cldr.Install do
  @doc """
  Ensures that cldr-core, cldr-rbnf and common are installed.  These directories
  will be part of the installation package so this is only useful when working
  with Cldr itself.  If there is no development data present then we assume its
  a package installation and therefore the data is already present and nothing
  need be done.
  """
  def install_cldr_core do
    ensure_data_dir_exists!()
    if development_data_exists?() do
      install_core_files()
    end
    :ok
  end

  def install_known_locales do
    ensure_locale_dir_exists!()
    Enum.each Cldr.known_locales(), &install_locale/1
    :ok
  end

  def install_all_locales do
    ensure_locale_dir_exists!()
    Enum.each Cldr.all_locales(), &install_locale/1
    :ok
  end

  def install_locale(locale) do
    if development_data_exists?() do
      destination = Path.join(locale_dir(), "#{locale}.json")
      File.cp!(locale_file(locale), destination)
    end
  end

  @core_files ~w(available_locales plural_rules number_systems)
  def install_core_files do
    for file <- @core_files do
      file_from = file_to = "#{file}.json"
      File.cp! Path.join(Cldr.Consolidate.output_dir(), file_from),
        Path.join(data_dir(), file_to)
    end
  end

  def locale_file(locale) do
    Path.join(Cldr.Consolidate.locales_dir, "#{locale}.json")
  end

  def ensure_locale_dir_exists! do
    case File.mkdir(locale_dir()) do
      :ok ->
        :ok
      {:error, :eexist} ->
        :ok
      {:error, code} ->
        raise RuntimeError,
          message: "Couldn't create #{locale_dir()}: #{inspect code}"
    end
  end

  def ensure_data_dir_exists! do
    case File.mkdir(data_dir()) do
      :ok ->
        :ok
      {:error, :eexist} ->
        :ok
      {:error, code} ->
        raise RuntimeError,
          message: "Couldn't create #{data_dir()}: #{inspect code}"
    end
  end

  # The consolidated source data,
  # not the configured data for app use
  def development_data_exists? do
    File.exists?(Cldr.Consolidate.data_dir())
  end

  # The place where the installed data goes
  # not the source data from CLDR
  def data_dir do
    Cldr.Config.data_dir()
  end

  def locale_dir do
    "#{data_dir()}/locales"
  end
end