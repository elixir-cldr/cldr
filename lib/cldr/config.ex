defmodule Cldr.Config do
  @moduledoc """
  Locales are configured for use in `Cldr` by either
  specifying them directly or by using a configured
  `Gettext` module.
  
  Locales are configured in `config.exs` (or any included config).
  For example the following will configure English and French as
  the available locales.  Note that only locales that are contained
  within the CLDR repository will be available for use.  There 
  are currently 511 locales defined in CLDR.
  
      config :cldr,
        locales: ["en", "fr"]
        
  It's also possible to use the locales from a Gettext
  configuration:
  
      config :cldr,
        locales: ["en", "fr"]
        gettext: App.Gettext
  
  In which case the combination of locales "en", "fr" and
  whatever is configured for App.Gettext will be generated.
  
  As a special case, all locales in CLDR can be configured
  by using the keyword `:all`.  For example:
  
      config :cldr,
        locales: :all
    
  *Configuring all locales is not recommended*. Doing so
  imposes a significant compilation load as many functions
  are created at compmile time for each locale.
  
  The `Cldr` test configuration does configure all locales in order
  to ensure test coverage.  This does provide good test
  coverage at the expense of significant compile time.
  """
  
  @doc """
  Return which set of CLDR repository data we are using: 
  the full set or the modern set.
  """
  @full_or_modern "full"
  def full_or_modern do
    @full_or_modern
  end
    
  @doc """
  Return the configured `Gettext` module name or `nil`.
  """
  @spec gettext :: atom
  def gettext do
    Application.get_env(:cldr, :gettext)
  end
  
  @doc """
  Return the default locale.
  
  In order of priority return either:
  
  * The default locale specified in the `mix.exs` file
  * The `Gettext.get_locale/1` for the current configuratioh
  * "en"
  """
  @spec default_locale :: String.t
  def default_locale do
    app_default = Application.get_env(:cldr, :default_locale)
    cond do
      app_default ->
        app_default
      gettext_configured?() ->
        apply(Gettext, :get_locale, [gettext])
      true ->
        "en"
    end
  end
  
  @doc """
  Return a list of the lcoales defined in `Gettext`.
  
  Return a list of locales configured in `Gettext` or
  `[]` if `Gettext` is not configured.
  """
  @spec gettext_locales :: [String.t]
  def gettext_locales do
    if gettext_configured?(), do: apply(Gettext, :known_locales), else: []
  end
  
  @doc """
  Returns a list of all locales configured in the `config.exs`
  file.
  
  In order of priority return either:
  
  * The list of locales configured configured in mix.exs if any
  * The default locale
  """
  @spec configured_locales :: [String.t]
  def configured_locales do
    Application.get_env(:cldr, :locales) || [default_locale()]
  end
  
  @doc """
  Returns a list of all locales in the CLDR repository.
  
  Returns a list of the complete locales list in CLDR, irrespective
  of whether they are configured for use in the application.
  
  Any configured locales that are not present in this list will be
  ignored.
  """
  @spec all_locales :: [String.t]
  def all_locales do
    locales_path = Path.join(data_dir(), "cldr-core/availableLocales.json")
    {:ok, locales} = File.read!(locales_path)
    |> Poison.decode
    locales["availableLocales"][full_or_modern()]
  end
  
  @doc """
  Returns a list of all locales that are configured and avaialable 
  in th CLDR repository.
  """
  @spec known_locales :: [String.t]
  def known_locales do
    MapSet.intersection(MapSet.new(requested_locales), MapSet.new(all_locales)) 
    |> MapSet.to_list
    |> Enum.sort
  end
  
  @doc """
  Returns a list of all configured locales.
  
  The list contains locales configured both in `Gettext` and
  specified in the mix.exs configuration file as well as the
  default locale.
  """
  @spec requested_locales :: [String.t]
  def requested_locales do
    (configured_locales ++ gettext_locales ++ [default_locale])
    |> Enum.uniq
  end
  
  @doc """
  Return the path name of the CLDR data directory.
  """
  def data_dir do
    Path.join(__DIR__, "/../../data")
  end
  
  @doc """
  Return the path name of the CLDR number directory
  """
  def numbers_locale_dir do
    Path.join(__DIR__, "/../../data/cldr-numbers-#{full_or_modern}/main")
  end
  
  @doc """
  Returns true if a `Gettext` module is configured in Cldr and
  the `Gettext` module is available.
  
  Example:
  
      iex> Cldr.Config.gettext_configured?
      false
  """
  @spec gettext_configured? :: boolean
  def gettext_configured? do
    gettext && Code.ensure_loaded?(Gettext) && Code.ensure_loaded?(gettext)
  end  
end