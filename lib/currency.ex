defmodule Cldr.Currency do
  # defstruct [:code, :name, :one, :many, :symbol, :narrow_symbol, :digits, :rounding, :cash_digits, :cash_rounding]

  @moduledoc """
  *Implements CLDR currency format functions*
  
  Note that the actual data used is the json version of cldr, not the LDML version described in the standard.  
  Conversion is done using the Unicode Consortiums [ldml2json](http://cldr.unicode.org/tools) tool.
  """
  @spec locale_path(binary) :: String.t
  def locale_path(locale) when is_binary(locale) do
    Path.join(Cldr.locale_dir(), "/#{locale}/currencies.json")
  end
  
  IO.puts "Generating currencies for #{Enum.count(Cldr.known_locales)} locales #{inspect Cldr.known_locales, limit: 10} with default #{inspect Cldr.default_locale}"
  
  @spec for_code(String.t, String.t) :: %{}
  def for_code(currency, locale \\ Cldr.default_locale)
  def for_code(currency, locale) when is_binary(currency),
    do: for_code(String.to_existing_atom(String.upcase(currency)), locale)
  def for_code(currency, locale) when is_atom(currency),
    do: do_for_code(currency, locale)
  
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
  @spec do_for_code(String.t, String.t) :: %{}
  Enum.each Cldr.known_locales, fn locale ->
    {:ok, currencies} = 
      Path.join(Cldr.locale_dir(), "/#{locale}/currencies.json") 
      |> File.read! 
      |> Poison.decode
      
    currencies = currencies["main"][locale]["numbers"]["currencies"]
    currencies = Enum.map currencies, fn {code, currency} ->
       rounding = Map.merge(@rounding["DEFAULT"], (@rounding[code] || %{}))
       {String.to_atom(code), %{
         code:          code,
         name:          currency["displayName"],
         one:           currency["displayName-count-one"],
         many:          currency["displayName-count-other"],
         symbol:        currency["symbol"],
         narrow_symbol: currency["symbol-alt-narrow"],
         digits:        String.to_integer(rounding["_digits"]),
         rounding:      String.to_integer(rounding["_rounding"]),
         cash_digits:   String.to_integer(rounding["_cashDigits"] || rounding["_digits"]),
         cash_rounding: String.to_integer(rounding["_cashRounding"] || rounding["_rounding"])
         }}
    end
    currencies = Enum.into(currencies, %{}) |> Macro.escape
    defp do_for_code(code, unquote(locale)) when is_atom(code) do
      unquote(currencies)[code]
    end
  end
  
  defp do_for_code(any, locale) when is_binary(any) do
    raise ArgumentError, message: "Currency #{inspect any} is not known in locale #{inspect locale}"
  end

end