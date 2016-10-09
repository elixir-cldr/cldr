defmodule Cldr.Currency do
  @moduledoc """
  Currency functions for CLDR.
  """

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

  ## Example

      iex> Cldr.Currency.known_currencies |> Enum.count
      297
  """

  def known_currencies do
    Cldr.get_locale()
    |> Cldr.Locale.get_locale
    |> get_in([:currencies])
    |> Map.keys
  end

  @doc """
  Returns a boolean indicating if the supplied currency code is known.

  ## Examples

      iex> Cldr.Currency.known_currency? "AUD"
      true

      iex> Cldr.Currency.known_currency? "GGG"
      false
  """
  @spec known_currency?(code) :: boolean
  def known_currency?(currency) when is_binary(currency) do
    try do
      currency = normalize_currency_code(currency)
      known_currency?(currency)
    rescue ArgumentError ->
      false
    end
  end

  def known_currency?(currency) when is_atom(currency) do
    !!Enum.find(known_currencies(), &(&1 == currency))
  end

  @doc """
  Returns the currency metadata for the requested currency code.

  The currency code is a string representation of an ISO 4217 currency code.

  ## Examples

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
  def for_code(currency, locale \\ Cldr.get_locale()) do
    do_for_code(currency, locale)
  end

  @doc """
  Returns the currency metadata for a locale.
  """
  @spec for_locale(Cldr.locale) :: %{}
  def for_locale(locale) do
    Cldr.Locale.get_locale(locale).currencies
  end

  @doc """
  Normalized the representation of a currency code.

  The normalized form is an ISO4217 code in an atom form.
  """
  @spec normalize_currency_code(binary) :: atom
  def normalize_currency_code(currency) when is_binary(currency) do
    currency
    |> String.upcase
    |> String.to_existing_atom
  end

  @spec do_for_code(code, Cldr.locale) :: %{}
  defp do_for_code(code, locale) when is_binary(code) do
    code
    |> normalize_currency_code
    |> do_for_code(locale)
  end

  defp do_for_code(code, locale) when is_atom(code) do
    for_locale(locale)[code]
  end

end
