defmodule Cldr.Currency do
  defstruct [:code, :name, :one, :many, :symbol, :narrow_symbol, :digits, :rounding, :cash_digits, :cash_rounding]
  alias Cldr.Currency

  @moduledoc """
  *Implements CLDR currency format functions*
  
  Note that the actual data used is the json version of cldr, not the LDML version described in the standard.  
  Conversion is done using the Unicode Consortiums [ldml2json](http://cldr.unicode.org/tools) tool.
  """
  @spec locale_path(binary) :: String.t
  def locale_path(locale) when is_binary(locale) do
    Path.join(Cldr.locale_dir(), "/#{locale}/currencies.json")
  end
  
  IO.puts "Generating currencies for locales #{inspect Cldr.known_locales} with default #{inspect Cldr.default_locale}"
  
  @spec for_code(String.t, String.t) :: %Cldr.Currency{}
  def for_code(currency, locale \\ Cldr.default_locale)
  def for_code(currency, locale) when is_binary(currency),
    do: do_for_code(String.upcase(currency), locale)
  def for_code(currency, locale) when is_atom(currency),
    do: for_code(Atom.to_string(currency), locale)
  
  @currencies_path "/#{Cldr.default_locale()}/currencies.json"
  @currencies_data "/cldr-core/supplemental/currencyData.json"
  
  # A list of known currencies derived from the data in the
  # default locale
  {:ok, currencies} = 
    Path.join(Cldr.locale_dir(), @currencies_path) 
    |> File.read! 
    |> Poison.decode
  @currencies currencies["main"][Cldr.default_locale()]["numbers"]["currencies"] 
    |> Enum.map(fn {code, _currency} -> code end)
    
  # Rounding and fraction information which is independent of locale
  {:ok, rounding} = 
    Path.join(Cldr.data_dir(), @currencies_data) 
    |> File.read! 
    |> Poison.decode
  @rounding rounding["supplemental"]["currencyData"]["fractions"]
  
  def known_currencies do
    @currencies
  end
  defdelegate currency_codes, to: __MODULE__, as: :known_currencies

  def known_currency?(currency) when is_binary(currency) do
    upcase_currency = String.upcase(currency)
    !!Enum.find(known_currencies, &(&1 == upcase_currency))
  end
  def known_currency?(currency) when is_atom(currency) do
    known_currency?(Atom.to_string(currency))
  end
    
  # For each locale, generate a currency lookup function for 
  # each known currency
  @spec do_for_code(String.t, String.t) :: %Cldr.Currency{}
  Enum.each Cldr.known_locales, fn locale ->
    {:ok, currencies} = 
      Path.join(Cldr.locale_dir(), "/#{locale}/currencies.json") 
      |> File.read! 
      |> Poison.decode
      
    currencies = currencies["main"][locale]["numbers"]["currencies"] 
    Enum.each currencies, fn {code, currency} ->
      rounding = Map.merge(@rounding["DEFAULT"], (@rounding[code] || %{}))
      defp do_for_code(unquote(code), unquote(locale)) do
        %Currency{
          code:          unquote(code),
          name:          unquote(currency["displayName"]), 
          one:           unquote(currency["displayName-count-one"]),
          many:          unquote(currency["displayName-count-other"]),
          symbol:        unquote(currency["symbol"]),
          narrow_symbol: unquote(currency["symbol-alt-narrow"]),
          digits:        unquote(rounding["_digits"] |> String.to_integer),
          rounding:      unquote(rounding["_rounding"] |> String.to_integer),
          cash_digits:   unquote((rounding["_cashDigits"] || rounding["_digits"]) |> String.to_integer),
          cash_rounding: unquote((rounding["_cashRounding"] || rounding["_rounding"]) |> String.to_integer)
        }
      end
    end
  end
  
  defp do_for_code(any, locale) when is_binary(any) do
    raise ArgumentError, message: "Currency #{inspect any} is not known in locale #{inspect locale}"
  end

end