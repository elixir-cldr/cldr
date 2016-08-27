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

  @type locale :: String.t

  if Enum.any?(Config.unknown_locales) do
    raise CompileError, description:
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
  @known_locale_count Enum.count(Config.known_locales)
  @locale_string if @known_locale_count > 1, do: "locales ", else: "locale "
  IO.puts "Generating functions for #{@known_locale_count} " <>
    @locale_string <>
    "#{inspect Config.known_locales, limit: 5} with " <>
    "default #{inspect Config.default_locale()}"
  if @known_locale_count > @warn_if_greater_than do
    IO.puts "Please be patient, generating functions for many locales can take some time"
  end

  @doc """
  Returns the directory path name where the CLDR json data for numbers
  is kept.
  """
  @numbers_locale_dir Config.numbers_locale_dir()
  def numbers_locale_dir do
    @numbers_locale_dir
  end

  @doc """
  Returns the directory path name where the CLDR json data
  is kept.
  """
  @data_dir Config.data_dir()
  def data_dir do
    @data_dir
  end


  @doc """
  Returns the directory path name where the CLDR json supplemental
  data is kept.
  """
  @supplemental_dir Config.supplemental_dir()
  def supplemental_dir do
    @supplemental_dir
  end

  @doc """
  Returns the default `locale` name.

  ## Example

      iex> Cldr.default_locale()
      "en"
  """
  @default_locale Config.default_locale()
  @spec default_locale :: [locale]
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
  @all_locales Config.all_locales
  @spec all_locales :: [locale]
  def all_locales do
    @all_locales
  end

  @doc """
  Returns a list of all requested locales.

  The list is the combination of configured locales,
  `Gettext` locales and the default locale.

  See also `known_locales/0` and `all_locales/0`
  """
  @requested_locales Config.requested_locales
  @spec requested_locales :: [locale] | []
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
  @known_locales Config.known_locales
  @spec known_locales :: [locale] | []
  def known_locales do
    @known_locales
  end

  @doc """
  Returns a list of the locales that are configured, but
  not known in CLDR.

  Functions typically raise an exception if a requested locale
  is not configured and available in CLDR.
  """
  @unknown_locales Config.unknown_locales
  @spec unknown_locales :: [locale] | []
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
  @spec known_locale?(locale) :: boolean
  def known_locale?(locale) when is_binary(locale) do
    !!Enum.find(known_locales(), &(&1 == locale))
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
  @spec locale_exists?(locale) :: boolean
  def locale_exists?(locale) when is_binary(locale) do
    !!Enum.find(Config.all_locales(), &(&1 == locale))
  end

end