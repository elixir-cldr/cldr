defmodule Cldr.Currency.Metadata do
  alias Cldr.File
  
  # These functions are delegated from Cldr.Currency 
  # and they are documented their.
  
  @moduledoc false

  @doc false
  @spec for_code(String.t, String.t) :: %{}
  def for_code(currency, locale \\ Cldr.default_locale)
  def for_code(currency, locale) when is_binary(currency),
    do: do_for_code(String.upcase(currency), locale)
  def for_code(currency, locale) when is_atom(currency),
    do: for_code(Atom.to_string(currency), locale)
  
  # A list of known currencies derived from the data in the
  # default locale
  @currency_codes File.read(:currency_codes)
  
  # Rounding and fraction information which is independent of locale
  @currency_data File.read(:currency_data)

  @doc false
  def known_currencies do
    @currency_codes
  end

  @doc false
  def known_currency?(currency) when is_binary(currency) do
    upcase_currency = String.upcase(currency)
    !!Enum.find(known_currencies, &(&1 == upcase_currency))
  end
  def known_currency?(currency) when is_atom(currency) do
    known_currency?(Atom.to_string(currency))
  end
    
  # For each locale, generate a currency lookup function for 
  # each known currency
  @count_types [:one, :two, :few, :many, :other]
  @spec do_for_code(String.t, String.t) :: %{}
  Enum.each Cldr.known_locales(), fn locale ->
    currencies = Cldr.File.read(:currency, locale)
    |> Enum.map(fn {code, currency} ->
      rounding = Map.merge(@currency_data["DEFAULT"], (@currency_data[code] || %{}))
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

      counts = Enum.reduce @count_types, %{}, fn (category, counts) ->
        if display_count = currency["displayName-count-#{category}"] do 
          Map.put(counts, category, display_count)
        else
          counts
        end
      end
      {code, %{currency_data | count: counts}}
    end)
    
    currencies = Enum.into(currencies, %{}) 
    |> Macro.escape
    
    def for_locale(unquote(locale)) do
      unquote(currencies)
    end
    
    defp do_for_code(code, locale) when is_binary(code) do
      for_locale(locale)[code]
    end
  end
end