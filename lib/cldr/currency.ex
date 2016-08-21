defmodule Cldr.Currency do
  @moduledoc """
  Currency functions for CLDR.
  """
  
  alias Cldr.File
  
  @type format :: :standard | 
    :accounting | 
    :short | 
    :long | 
    :percent | 
    :scientific
                  
  @type code :: String.t
  
  @type t :: %__MODULE__{
    code: code,
    name: String.t,
    tender: boolean,
    symbol: String.t,
    digits: pos_integer,
    rounding: pos_integer,
    narrow_symbol: String.t,
    cash_digits: pos_integer,
    cash_rounding: pos_integer,
    count: %{}
  }
  
  defstruct [
    :code, 
    :name, 
    :symbol, 
    :narrow_symbol, 
    :digits, 
    :rounding, 
    :cash_digits, 
    :cash_rounding, 
    :tender, 
    :count]
    
  @doc """
  Returns a list of all known currency codes.
  
  Example:
  
      iex> Cldr.Currency.known_currencies |> Enum.count
      297
  """
  @currency_codes File.read(:currency_codes)
  def known_currencies do
    @currency_codes
  end
  
  @doc """
  Returns a boolean indicating if the supplied currency code is known.
  
  Examples:
  
      iex> Cldr.Currency.known_currency? "AUD"
      true
      
      iex> Cldr.Currency.known_currency? "GGG"
      false
  """
  @spec known_currency?(code) :: boolean
  def known_currency?(currency) when is_binary(currency) do
    !!Enum.find(known_currencies(), &(&1 == currency))
  end 
  
  @doc """
  Returns the currency metadata for the requested currency code.
  
  The currency code is a string representation of an ISO 4217 currency code.
  
  Examples:
  
      iex> Cldr.Currency.for_code("AUD") 
      %Cldr.Currency{cash_digits: 2, cash_rounding: 0, code: "AUD",
      count: %{one: "Australian dollar", other: "Australian dollars"},
      digits: 2, name: "Australian Dollar", narrow_symbol: "$",
      rounding: 0, symbol: "A$", tender: true}
      
      iex> Cldr.Currency.for_code("THB")
      %Cldr.Currency{cash_digits: 2, cash_rounding: 0, code: "THB",
      count: %{one: "Thai baht", other: "Thai baht"}, digits: 2,
      name: "Thai Baht", narrow_symbol: "฿", rounding: 0, symbol: "THB",
      tender: true}
  """
  @spec for_code(code, Cldr.locale) :: %{}
  def for_code(currency, locale \\ Cldr.default_locale()) do
    do_for_code(currency, locale)
  end
  
  @doc """
  Returns the currency metadata for a locale.
  """
  @spec for_locale(Cldr.locale) :: %{}
  def for_locale(locale \\ Cldr.default_locale())
  
  Enum.each Cldr.known_locales(), fn locale ->
    currencies = File.read(:currency, locale)
    def for_locale(unquote(locale)) do
      unquote(Macro.escape(currencies))
    end
  end
  
  @spec do_for_code(code, Cldr.locale) :: %{}
  defp do_for_code(code, locale) when is_binary(code) do
    for_locale(locale)[code]
  end
  
  # @spec to_string(number, code, Cldr.locale, format) :: String.t
  # def to_string(number, code, locale \\ Cldr.default_locale(), options \\ :standard)
  #
  # # Use the formal from currencyFormat
  # def to_string(number, code, locale, :standard) do
  #   IO.puts inspect(number)
  # end
  #
  # # Use the accounting format
  # def to_string(number, code, locale, :accounting) do
  #   IO.puts inspect(number)
  # end
  #
  # # Use the short format
  # def to_string(number, code, locale, :short) do
  #   IO.puts inspect(number)
  # end
  #
  # # Use the format from Decimal format with the text expansion
  # def to_string(number, code, locale, :long) do
  #   IO.puts inspect(number)
  # end

end