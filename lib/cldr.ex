defmodule Cldr do
  @moduledoc """
  Cldr provides functions to localise numbers, currencies, lists and
  dates/times to an appropriate locale as defined by the CLDR data
  maintained by the ICU.

  The most commonly used functions are:

  * `Cldr.Number.to_string/2` for formatting numbers

  * `Cldr.Currency.to_string/2` for formatting currencies

  * `Cldr.List.to_string/2` for formatting lists
  """

  alias Cldr.Config
  alias Cldr.Locale

  if Enum.any?(Config.unknown_locales()) do
    raise Cldr.UnknownLocaleError,
      "Some locales are configured that are not known to CLDR. " <>
      "Compilation cannot continue until the configuration includes only " <>
      "locales known in CLDR.\n\n" <>
      "Configured locales: #{inspect Config.requested_locales()}\n" <>
      "Gettext locales:    #{inspect Config.gettext_locales()}\n" <>
      "Unknown locales:    " <>
      "#{IO.ANSI.red()}#{inspect Config.unknown_locales()}" <>
      "#{IO.ANSI.default_color()}\n"
  end

  @warn_if_greater_than 100
  @known_locale_count Enum.count(Config.known_locales())
  @locale_string if @known_locale_count > 1, do: "locales ", else: "locale "
  IO.puts "Generating Cldr for #{@known_locale_count} " <>
    @locale_string <>
    "#{inspect Config.known_locales, limit: 5} with " <>
    "default locale #{inspect Config.default_locale()}"
  if @known_locale_count > @warn_if_greater_than do
    IO.puts "Please be patient, generating functions for many locales " <>
    "can take some time"
  end

  @doc """
  Returns the directory path name where the CLDR json data
  is kept.
  """
  @data_dir Config.client_data_dir()
  def data_dir do
    @data_dir
  end

  @doc """
  Returns the version of the CLDR repository as a tuple

  ## Example

      iex> Cldr.version
      {"31", "0", "1"}
  """
  @version Config.version() |> String.split(".") |> List.to_tuple
  def version do
    @version
  end

  @doc """
  Return the current locale to be used for `Cldr` functions that
  take an optional locale parameter for which a locale is not supplied.
  """
  @spec get_current_locale :: Locale.t
  def get_current_locale do
    Process.get(:cldr, default_locale())
  end

  @doc """
  Set the current locale to be used for `Cldr` functions that
  take an optional locale parameter for which a locale is not supplied.
  """
  @spec set_current_locale(Locale.t) :: Locale.t
  def set_current_locale(locale) when is_binary(locale) do
    if known_locale?(locale) do
      Process.put(:cldr, locale)
      locale
    else
      {:error, Cldr.Locale.locale_error(locale)}
    end
  end

  @doc """
  Returns the default `locale` name.

  ## Example

      iex> Cldr.default_locale()
      "en"
  """
  @default_locale Config.default_locale()
  @spec default_locale :: [Locale.t]
  def default_locale do
    @default_locale
  end

  @doc """
  Returns a list of all the locales defined in the CLDR
  repository.

  Note that not necessarily all of these locales are
  available since functions are only generated for configured
  locales which is most cases will be a subset of locales
  defined in CLDR.

  See also: `requested_locales/0` and `known_locales/0`
  """
  @all_locales Config.all_locales()
  @spec all_locales :: [Locale.t]
  def all_locales do
    @all_locales
  end

  @doc """
  Returns a list of all requested locales.

  The list is the combination of configured locales,
  `Gettext` locales and the default locale.

  See also `known_locales/0` and `all_locales/0`
  """
  @requested_locales Config.requested_locales()
  @spec requested_locales :: [Locale.t] | []
  def requested_locales do
    @requested_locales
  end

  @doc """
  Returns a list of the known locales.

  Known locales are those locales which
  are the subset of all CLDR locales that
  have been configured for use either
  directly in the `config.exs` file or
  in `Gettext`.
  """
  @known_locales Config.known_locales()
  @spec known_locales :: [Locale.t] | []
  def known_locales do
    @known_locales
  end

  @doc """
  Returns a list of the locales that are configured, but
  not known in CLDR.

  Since we check at compile time for any unknown locales
  and raise and exception this function should always
  return an empty list.
  """
  @unknown_locales Config.unknown_locales()
  @spec unknown_locales :: [Locale.t] | []
  def unknown_locales do
    @unknown_locales
  end

  @doc """
  Returns a boolean indicating if the specified locale
  is configured and available in Cldr.

  ## Examples

      iex> Cldr.known_locale?("en")
      true

      iex> Cldr.known_locale?("!!")
      false
  """
  @spec known_locale?(Locale.t) :: boolean
  def known_locale?(locale) when is_binary(locale) do
    !!Enum.find(known_locales(), &(&1 == locale))
  end

  @doc """
  Returns the map representation of a locale definition

  A locale is defined by a map of definitions that are used to underpin the generation
  of a set of functions that provide the public API.

  * `locale` is any locale returned by `Cldr.known_locales/0`
  """
  @spec get_locale(Locale.name) :: Map.t
  Enum.each @known_locales, fn locale_name ->
    locale = struct(Locale, Config.get_locale(locale_name))

    def get_locale(unquote(locale_name)) do
      unquote(Macro.escape(locale))
    end
  end

  def get_locale(locale_name) do
    {:error, Locale.locale_error(locale_name)}
  end

  @doc """
  Returns a boolean indicating if the specified locale
  is available in CLDR.

  The return value depends on whether the locale is
  defined in the CLDR repository.  It does not necessarily
  mean the locale is configured for Cldr.  See also
  `Cldr.known_locale?/1`.

  ## Examples

      iex> Cldr.locale_exists? "en-AU"
      true

      iex> Cldr.locale_exists? "en-SA"
      false
  """
  @spec locale_exists?(Locale.t) :: boolean
  def locale_exists?(locale) when is_binary(locale) do
    !!Enum.find(Config.all_locales(), &(&1 == locale))
  end

end