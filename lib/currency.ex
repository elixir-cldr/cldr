defmodule Cldr.Currency do
  alias Cldr.Currency.Metadata
  defstruct [:code, :name, :symbol, :narrow_symbol, :digits, :rounding, :cash_digits, :cash_rounding, :count]
  
  @doc """
  Returns a list of all known currency codes.
  
  Example:
  
      iex> Cldr.Currency.known_currencies |> Enum.count
      297
  """
  defdelegate known_currencies,      to: Metadata
  
  @doc """
  Returns a boolean indicating if the supplied currency code is known.
  
  Examples:
  
      iex> Cldr.Currency.known_currency? :AUD
      true
      
      iex> Cldr.Currency.known_currency? "GGG"
      false
  """
  defdelegate known_currency?(code), to: Metadata
  
  @doc """
  Returns the currency metadata for the requested currency code.
  
  The currency code can be either an `atom` or `string` representation
  of an ISO 4217 currency code.
  
  Examples:
  
      iex> Cldr.Currency.for_code "AUD" 
      %Cldr.Currency{cash_digits: 2, cash_rounding: 0, code: "AUD",
      count: %{one: "Australian dollar", other: "Australian dollars"}, digits: 2,
      name: "Australian Dollar", narrow_symbol: "$", rounding: 0, symbol: "A$"}
      
      iex> Cldr.Currency.for_code :thb
      %Cldr.Currency{cash_digits: 2, cash_rounding: 0, code: "THB",
      count: %{one: "Thai baht", other: "Thai baht"}, digits: 2, name: "Thai Baht",
      narrow_symbol: "฿", rounding: 0, symbol: "THB"}
  """
  defdelegate for_code(code),        to: Metadata
  
  @type format :: :standard | :accounting | :short | :long | :percent | :scientific
  @type code :: atom | String.t
  
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