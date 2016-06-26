defmodule Cldr do
  @locale_dir Path.join(__DIR__, "/../data/cldr-numbers-full/main")
  {:ok, files} = File.ls(@locale_dir)
  @locales Enum.map(files, &Path.basename(&1))
    
  @doc """
  Returns a boolean identifying if the specified locale
  is available in Cldr
  """
  @spec locale_exists?(String.t) :: boolean
  def locale_exists?(locale) when is_binary(locale) do
    Enum.find(known_locales, &(&1 == locale))
  end
  
  @doc """
  Returns a list of the configured locales for rbnf
  
  Locales are configured in `config.exs` 
  
      config :cldr,
        locales: ["en", "fr"]
        
  It's also possible to use the locales from a Gettext
  configuration:
  
      config :cldr,
        gettext: App.Gettext
  """
  @spec configured_locales :: [String.t]
  def configured_locales do
    Application.get_env(:cldr, :locales)
  end
  
  @doc """
  Returns a list of the locales defined in rbnf
  """
  @spec known_locales :: [String.t]
  def known_locales do
    @locales
  end
end