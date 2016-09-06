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

      config :ex_cldr,
        locales: ["en", "fr"]

  It's also possible to use the locales from a Gettext
  configuration:

      config :ex_cldr,
        locales: ["en", "fr"]
        gettext: App.Gettext

  In which case the combination of locales "en", "fr" and
  whatever is configured for App.Gettext will be generated.

  Locales can also be configured by using a `regex` which is most
  useful when dealing with locales that have many regional variants
  like English (over 100!) and French.  For example:

      config :ex_cldr,
        locales: ["fr-*", "en-[A-Z]+"]

  will configure all French locales and all English locales that have
  alphabetic regional variants.  The expansion is made using
  `Regex.match?` so any valid regex can be used.

  As a special case, all locales in CLDR can be configured
  by using the keyword `:all`.  For example:

      config :ex_cldr,
        locales: :all

  *Configuring all locales is not recommended*. Doing so
  imposes a significant compilation load as many functions
  are created at compmile time for each locale.*

  The `Cldr` test configuration does configure all locales in order
  to ensure good test coverage.  This is done at the expense
  of significant compile time.

  CLDR includes two sets of data:  the `full` and the `modern`.  By default
  `Cldr` uses the `full` set.  To use the `modern` set, configure the
  `:dataset` configuration key.  For example:

      config :ex_cldr,
        locales: ["en", "fr"]
        dataset: :modern
  """

  alias Cldr.Locale

  @type t :: binary

  @default_locale "en"


  @doc """
  Return which set of CLDR repository data we are using:
  the full set or the modern set.

  If the configuration key `:dataset` is set then use
  that value, otherwise defaults to `full`.
  """
  @full_or_modern "full"
  def full_or_modern do
    Application.get_env(:ex_cldr, :dataset) || @full_or_modern
  end

  @doc """
  Return the root path of the cldr application
  """
  @app_home_dir Path.join(__DIR__, "/../..") |> Path.expand
  def app_home do
    @app_home_dir
  end

  @doc """
  Return the path name of the CLDR data directory.
  """
  @data_dir Path.join(__DIR__, "/../../data") |> Path.expand
  def data_dir do
    @data_dir
  end

  @doc """
  Return the path name of the CLDR supplemental data directory.
  """
  @supplemental_dir Path.join(@data_dir, "/cldr-core/supplemental")
  def supplemental_dir do
    @supplemental_dir
  end

  @doc """
  Return the configured `Gettext` module name or `nil`.
  """
  @spec gettext :: atom
  def gettext do
    Application.get_env(:ex_cldr, :gettext)
  end

  @doc """
  Return the default locale.

  In order of priority return either:

  * The default locale specified in the `mix.exs` file
  * The `Gettext.get_locale/1` for the current configuratioh
  * "en"
  """
  @spec default_locale :: Locale.t
  def default_locale do
    app_default = Application.get_env(:ex_cldr, :default_locale)
    cond do
      app_default ->
        app_default
      gettext_configured?() ->
        Gettext
        |> apply(:get_locale, [gettext()])
        |> Enum.map(&String.replace(&1,"_","-"))
      true ->
        @default_locale
    end
  end

  @doc """
  Return a list of the lcoales defined in `Gettext`.

  Return a list of locales configured in `Gettext` or
  `[]` if `Gettext` is not configured.
  """
  @spec gettext_locales :: [Locale.t]
  def gettext_locales do
    if gettext_configured?() do
      Gettext
      |> apply(:known_locales, [gettext()])
      |> Enum.map(&String.replace(&1,"_","-"))
    else
      []
    end
  end

  @doc """
  Returns a list of all locales in the CLDR repository.

  Returns a list of the complete locales list in CLDR, irrespective
  of whether they are configured for use in the application.

  Any configured locales that are not present in this list will be
  ignored.
  """
  @locales_path Path.join(@data_dir, "cldr-core/availableLocales.json")
  {:ok, locales} = @locales_path
  |> File.read!
  |> Poison.decode
  @all_locales locales["availableLocales"][@full_or_modern] |> Enum.sort
  @spec all_locales :: [Locale.t]
  def all_locales do
    @all_locales
  end

  @doc """
  Returns a list of all locales configured in the `config.exs`
  file.

  In order of priority return either:

  * The list of locales configured configured in mix.exs if any
  * The default locale

  If the configured locales is `:all` then all locales
  in CLDR are configured.

  This is not recommended since all 511 locales take
  quite some time (minutes) to compile. It is however
  helpful for testing Cldr.
  """
  @spec configured_locales :: [Locale.t]
  def configured_locales do
    case app_locales = Application.get_env(:ex_cldr, :locales) do
      :all  -> @all_locales
      nil   -> [default_locale()]
      _     -> expand_locales(app_locales)
    end |> Enum.sort
  end

  @doc """
  Returns a list of all locales that are configured and available
  in the CLDR repository.
  """
  @spec known_locales :: [Locale.t]
  def known_locales do
    requested_locales()
    |> MapSet.new()
    |> MapSet.intersection(MapSet.new(all_locales()))
    |> MapSet.to_list
    |> Enum.sort
  end

  @doc """
  Returns a list of all locales that are configured but not available
  in the CLDR repository.
  """
  @spec unknown_locales :: [Locale.t]
  def unknown_locales do
    requested_locales()
    |> MapSet.new()
    |> MapSet.difference(MapSet.new(all_locales()))
    |> MapSet.to_list
    |> Enum.sort
  end

  @doc """
  Returns a list of all configured locales.

  The list contains locales configured both in `Gettext` and
  specified in the mix.exs configuration file as well as the
  default locale.
  """
  @lint false
  @spec requested_locales :: [Locale.t]
  def requested_locales do
    (configured_locales() ++ gettext_locales() ++ [default_locale()])
    |> Enum.uniq
    |> Enum.sort
  end

  @doc """
  Return the path name of the CLDR number directory
  """
  @numbers_locale_dir Path.join(@data_dir, "cldr-numbers-#{@full_or_modern}/main")
  def numbers_locale_dir do
    @numbers_locale_dir
  end

  @doc """
  Returns true if a `Gettext` module is configured in Cldr and
  the `Gettext` module is available.

  ## Example

      iex> Cldr.Config.gettext_configured?
      false
  """
  @spec gettext_configured? :: boolean
  def gettext_configured? do
    gettext() && Code.ensure_loaded?(Gettext) && Code.ensure_loaded?(gettext())
  end

  @doc """
  Expands wildcards in locale names.

  Locales often have region variants (for example en-AU is one of 104
  variants in CLDR).  To make it easier to configure a language and all
  its variants, a locale can be specified as a regex which will
  then do a match against all CLDR locales.

  ## Examples

      iex> Cldr.Config.expand_locales(["en-A+"])
      ["en-AG", "en-AI", "en-AS", "en-AT", "en-AU"]

      iex(15)> Cldr.Config.expand_locales(["fr-*"])
      ["fr", "fr-BE", "fr-BF", "fr-BI", "fr-BJ", "fr-BL", "fr-CA", "fr-CD", "fr-CF",
       "fr-CG", "fr-CH", "fr-CI", "fr-CM", "fr-DJ", "fr-DZ", "fr-GA", "fr-GF",
       "fr-GN", "fr-GP", "fr-GQ", "fr-HT", "fr-KM", "fr-LU", "fr-MA", "fr-MC",
       "fr-MF", "fr-MG", "fr-ML", "fr-MQ", "fr-MR", "fr-MU", "fr-NC", "fr-NE",
       "fr-PF", "fr-PM", "fr-RE", "fr-RW", "fr-SC", "fr-SN", "fr-SY", "fr-TD",
       "fr-TG", "fr-TN", "fr-VU", "fr-WF", "fr-YT"]
  """
  @wildcard_matchers ["*", "+", ".", "["]
  @spec expand_locales([Locale.t]) :: [Locale.t]
  def expand_locales(locales) do
    locale_list = Enum.map(locales, fn locale ->
      if String.contains?(locale, @wildcard_matchers) do
        Enum.filter(@all_locales, &Regex.match?(Regex.compile!(locale), &1))
      else
        locale
      end
    end)
    locale_list |> List.flatten |> Enum.uniq
  end

  @doc false
  @spec normalize_short_format(Map.t) :: List.t
  def normalize_short_format(nil) do
    nil
  end

  @doc false
  def normalize_short_format(format) do
    format
    |> Enum.group_by(fn {range, _rules} -> List.first(String.split(range,"-")) end)
    |> Enum.map(fn {range, rules} -> {String.to_integer(range), rules} end)
    |> Enum.map(&flatten_short_formats/1)
    |> Enum.sort
  end

  @doc false
  @spec flatten_short_formats({binary, [] | String.t}) :: tuple
  def flatten_short_formats({range, rules}) when is_list(rules) do
    formats = Enum.map rules, fn {name, format} ->
      plural_type = name
      |> String.split("-")
      |> Enum.reverse
      |> List.first
      |> String.to_atom

      {plural_type, format}
    end
    {range, formats}
  end

  @doc false
  def flatten_short_formats(formats) do
    formats
  end

  # Here we get the entire currency format section but we only want
  # the section that is marked as a set of "unitPattern-count-___".
  @doc false
  @pattern_count "unitPattern-count-"
  @pattern_regex Regex.compile!(@pattern_count)
  def currency_long_format(nil), do: nil
  def currency_long_format(formats) do
    formats
    |> Enum.filter(fn {k, _v} -> Regex.match?(@pattern_regex, k) end)
    |> Enum.map(fn {k, v} ->
         @pattern_count <> count = k
         {String.to_existing_atom(count), v}
       end)
  end
end
