defmodule Cldr.Currency do
  alias Cldr.Currency.Metadata
  defstruct [:code, :name, :symbol, :narrow_symbol, :digits, :rounding, :cash_digits, :cash_rounding, :count]
  
  defdelegate known_currencies,      to: Metadata
  defdelegate known_currency?(code), to: Metadata
  defdelegate for_code(code),        to: Metadata
  
  @type format :: :standard | :accounting | :short | :long | :percent | :scientific
  @type code :: atom | String.t
  
  @spec to_string(number, code, Cldr.locale, format) :: String.t
  def to_string(number, code, locale \\ Cldr.default_locale(), options \\ :standard)
  
  # Use the formal from currencyFormat
  def to_string(number, code, locale, :standard) do
    IO.puts inspect(number)
  end

  # Use the accounting format
  def to_string(number, code, locale, :accounting) do
    IO.puts inspect(number)
  end
  
  # Use the short format
  def to_string(number, code, locale, :short) do
    IO.puts inspect(number)
  end
  
  # Use the format from Decimal format with the text expansion
  def to_string(number, code, locale, :long) do
    IO.puts inspect(number)
  end

end