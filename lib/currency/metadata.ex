defmodule Cldr.Currency.Metadata do
  @moduledoc """
  *Generates metadata functions for Cldr currency data*
  
  Note that the actual data used is the json version of cldr, not the LDML version described in the standard.  
  Conversion is done using the Unicode Consortiums [ldml2json](http://cldr.unicode.org/tools) tool.
  """
  @warn_if_greater_than 100
  @known_locale_count Enum.count(Cldr.known_locales)
  IO.puts "Generating currencies for #{@known_locale_count} locales #{inspect Cldr.known_locales, limit: 5} with default #{inspect Cldr.default_locale}"
  if @known_locale_count > @warn_if_greater_than do
    IO.puts "Please be patient, generating currencies for many locales can take some time"
  end
  
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
      currency_data = %Cldr.Currency{
        code:          code,
        name:          currency["displayName"],
        symbol:        currency["symbol"],
        narrow_symbol: currency["symbol-alt-narrow"],
        digits:        String.to_integer(rounding["_digits"]),
        rounding:      String.to_integer(rounding["_rounding"]),
        cash_digits:   String.to_integer(rounding["_cashDigits"] || rounding["_digits"]),
        cash_rounding: String.to_integer(rounding["_cashRounding"] || rounding["_rounding"]),
        count:         %{}
      }

      @count_types [:one, :two, :few, :many, :other]
      counts = Enum.reduce @count_types, %{}, fn (category, counts) ->
        if display_count = currency["displayName-count-#{category}"] do 
          Map.put(counts, category, display_count)
        else
          counts
        end
      end
      {String.to_atom(code), %{currency_data | count: counts}}
    end
    currencies = Enum.into(currencies, %{}) |> Macro.escape
    
    def for_locale(unquote(locale)) do
      unquote(currencies)
    end
    
    defp do_for_code(code, locale) when is_atom(code) do
      for_locale(locale)[code]
    end
  end
end