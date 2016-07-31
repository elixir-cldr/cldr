defmodule Cldr do
  # Treat this as the canonical definition of what locales are available
  @locale_dir Path.join(__DIR__, "/../data/cldr-numbers-full/main")
  def locale_dir do
    @locale_dir
  end
  
  @data_dir   Path.join(__DIR__, "/../data")
  def data_dir do
    @data_dir
  end   
  
  @doc """
  Returns a list of the locales defined in Cldr
  
  Note that not necessarily all of these locales are
  available since functions are only generated for configured
  locales which is most cases will be a subset of locales
  defined in Cldr.
  
  See also: configured_locales/0 and known_locales/0
  """
  {:ok, files} = File.ls(@locale_dir)
  @locales Enum.map(files, &Path.basename(&1))
  @spec locales :: [String.t]
  def locales do
    @locales
  end
  
  # If locales is configured to be :all then set locales to be 
  # the list of available locales
  if Application.get_env(:cldr, :locales) == :all do
    Application.put_env(:cldr, :locales, @locales)
  end
  
  # The configured Gettext backend
  @gettext            Application.get_env(:cldr, :gettext)
  
  # Use the configured default. If there isn't one use the Gettext default if available, otherwise "en"
  @default_locale     if (is_nil(Application.get_env(:cldr, :default_locale)) && @gettext && Code.ensure_loaded?(Gettext) && Code.ensure_loaded?(@gettext)),
                        do: Gettext.get_locale(@gettext),
                        else: Application.get_env(:cldr, :default_locale) || "en"
  
  # The locales known to Gettext
  @gettext_locales    if (@gettext && Code.ensure_loaded?(Gettext) && Code.ensure_loaded?(@gettext)),
                        do: Gettext.known_locales(@gettext),
                        else: []
                        
  # The configured locales to use.  If not specified use Gettext locales if they're known. Otherwise
  # just the default locale
  @cldr_locales       if (is_nil(Application.get_env(:cldr, :locales)) && @gettext && Code.ensure_loaded?(Gettext) && Code.ensure_loaded?(@gettext)),
                        do: Gettext.known_locales(@gettext),
                        else: Application.get_env(:cldr, :locales) || [@default_locale]
                        
  @spec default_locale :: [String.t]
  def default_locale do
    @default_locale
  end
  
  @configured_locales Enum.uniq(@cldr_locales ++ @gettext_locales ++ [@default_locale])
  @spec configured_locales :: [String.t]
  def configured_locales do
    @configured_locales
  end
  
  @doc """
  Returns a list of the available locales for cldr
  
  Locales are configured in `config.exs` 
  
      config :cldr,
        locales: ["en", "fr"]
        
  It's also possible to use the locales from a Gettext
  configuration:
  
      config :cldr,
        locales: ["en", "fr"]
        gettext: App.Gettext
  
  In which case the combination of locales "en", "fr" and
  whatever is configured for App.Gettext will be generated.
  """
  @known_locales  MapSet.intersection(MapSet.new(@configured_locales), MapSet.new(@locales)) 
    |> MapSet.to_list
    |> Enum.sort
    
  @spec known_locales :: [String.t] | []
  def known_locales do
    @known_locales
  end
  
  @doc """
  Returns a boolean indicating if the specified locale
  is configured and available in Cldr
  """
  @spec known_locale?(String.t) :: boolean
  def known_locale?(locale) when is_binary(locale) do
    Enum.find(known_locales(), &(&1 == locale))
  end
  
  @doc """
  Returns a boolean indicating if the specified locale
  is available in Cldr
  """
  @spec locale_exists?(String.t) :: boolean
  def locale_exists?(locale) when is_binary(locale) do
    Enum.find(locales(), &(&1 == locale))
  end
end