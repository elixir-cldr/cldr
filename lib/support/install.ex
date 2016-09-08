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
      File.cp_r!(common_dir(), data_dir())
      File.cp_r!(cldr_core_dir(), data_dir())
      File.cp_r!(rbnf_dir(), data_dir())
    end
    :ok
  end

  def install_configured_locales do
    ensure_locale_dir_exists!()
    Enum.each Cldr.known_locales(), &install_locale/1
  end

  def install_locale(locale) do
    if development_data_exists?() do
      File.cp!(locale_file(locale), Path.join(locale_dir(), "#{locale}.json"))
    end
  end

  def locale_file(locale) do
    Path.join(Cldr.data_dir, ["consolidated/", "#{locale}.json"])
  end

  def common_dir do
    Path.join(Cldr.data_dir, "common")
  end

  def cldr_core_dir do
    Path.join(Cldr.data_dir, "cldr-core")
  end

  def rbnf_dir do
    Path.join(Cldr.data_dir, "cldr-rbnf")
  end


  def ensure_locale_dir_exists! do
    case File.mkdir(locale_dir()) do
      :ok ->
        :ok
      {:error, :eexist} ->
        :ok
      {:error, code} ->
        raise RuntimeError,
          message: "Couldn't create #{data_dir()}: #{inspect code}"
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

  def development_data_exists? do
    File.exists?(Cldr.data_dir())
  end

  @default_dir "./priv/cldr"
  def data_dir do
    Application.get_env(:cldr, :data_dir) || @default_dir
  end

  def locale_dir do
    "#{data_dir()}/locales"
  end
end