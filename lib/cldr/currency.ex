defmodule Cldr.Currency do
  @moduledoc """
  Defines a currency structure and a set of functions to manage the validity of a currency code
  and to return metadata for currencies.
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
      298
  """
  def known_currencies do
    Cldr.get_locale()
    |> Cldr.Locale.get_locale
    |> get_in([:currencies])
    |> Map.keys
  end

  @doc """
  Returns a boolean indicating if the supplied currency code is known.

  * `currency_code` is a `binary` or `atom` representing an ISO4217
  currency code

  ## Examples

      iex> Cldr.Currency.known_currency? "AUD"
      true

      iex> Cldr.Currency.known_currency? "GGG"
      false
  """
  @spec known_currency?(code) :: boolean
  def known_currency?(currency_code) when is_binary(currency_code) do
    case code_atom = normalize_currency_code(currency_code) do
      {:error, {_exception, _message}} -> false
      _ -> known_currency?(code_atom)
    end
  end

  def known_currency?(currency_code) when is_atom(currency_code) do
    !!Enum.find(known_currencies(), &(&1 == currency_code))
  end

  @doc """
  Returns a normalized currency code if the code is valid or an error tuple if not.

  Similar to the function `known_currency/1` but whereas that function returns a
  `boolean` result, this function returns the normalized currency code if the
  argument is valid.

  ## Examples

      iex> Cldr.Currency.validate_currency_code :usd
      :USD

      iex> Cldr.Currency.validate_currency_code "usd"
      :USD

      iex> Cldr.Currency.validate_currency_code "USD"
      :USD

      iex> Cldr.Currency.validate_currency_code "NOPE"
      {:error, {Cldr.UnknownCurrencyError, "Currency \\"NOPE\\" is not known"}}

      iex> Cldr.Currency.validate_currency_code :ABC
      {:error, {Cldr.UnknownCurrencyError, "Currency :ABC is not known"}}
  """
  @spec validate_currency_code(code) :: atom
  def validate_currency_code(currency_code) do
    case code_atom = normalize_currency_code(currency_code) do
      {:error, {_exception, _message}} = error ->
        error
      _ ->
        if known_currency?(code_atom) do
          code_atom
        else
          error_tuple(code_atom)
        end
    end
  end

  @doc """
  Returns the currency metadata for the requested currency code.

  * `currency_code` is a `binary` or `atom` representation of an ISO 4217 currency code.

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
  def for_code(currency_code, locale \\ Cldr.get_locale()) do
    case code = validate_currency_code(currency_code) do
      {:error, {_exception, _message}} = error -> error
      _ -> for_locale(locale)[code]
    end
  end

  @doc """
  Returns the currency metadata for a locale.
  """
  @spec for_locale(Cldr.locale) :: %{}
  def for_locale(locale) do
    Cldr.Locale.get_locale(locale).currencies
  end

  @doc """
  Normalizes the representation of a currency code.

  * `currency_code` is any `binary` or `atom` representation of
  an ISO4217 currency code.

  The normalized form is an ISO4217 code in an upper case atom form.

  `binary` forms of `currency_code` are only every converted
  to an atom using `String.to_existing_atom/1`.  Since all known currencies
  are loaded at compile time, we can detect invalid currencies in these
  cases - the third example below is one such instance.

  Note that `normalize_currency_code` only normalizes the currency
  code.  For checking the validiting of a currency code, use `known_currency?/1`.

  ## Examples:

      iex> Cldr.Currency.normalize_currency_code "USD"
      :USD

      iex> Cldr.Currency.normalize_currency_code :usd
      :USD

      iex> Cldr.Currency.normalize_currency_code "NADA"
      {:error, {Cldr.UnknownCurrencyError, "Currency \\"NADA\\" is not known"}}

      iex> Cldr.Currency.normalize_currency_code :ABC
      :ABC
  """
  @spec normalize_currency_code(binary) :: atom
  def normalize_currency_code(currency_code) when is_binary(currency_code) do
    try do
      currency_code
      |> String.upcase
      |> String.to_existing_atom
    rescue ArgumentError ->
      error_tuple(currency_code)
    end
  end

  def normalize_currency_code(currency_code) when is_atom(currency_code) do
    if known_currency?(currency_code) do
      currency_code
    else
      currency_code
      |> Atom.to_string
      |> normalize_currency_code
    end
  end

  @doc """
  Normalizes the representation of a currency code using `normalize_currency_code/1`
  but raises an exception if the code is known to be invalid.  Note that this function
  does not conclusively detect invalid currency codes and is not intended to.

  * `currency_code` is any `binary` or `atom` representation of
  an ISO4217 currency code.

  The normalized form is an ISO4217 code in an upper case atom form.

  ## Example:

      Cldr.Currency.normalize_currency_code! "ABC"
      ** (Cldr.UnknownCurrencyError) Currency "ABC" is not known
      (ex_cldr) lib/cldr/currency.ex:146: Cldr.Currency.normalize_currency_code!/1
  """
  def normalize_currency_code!(currency_code) when is_binary(currency_code) or is_atom(currency_code) do
    case code = normalize_currency_code(currency_code) do
      {:error, {exception, message}} ->
        raise exception, message
      _ -> code
    end
  end

  defp error_tuple(currency_code) do
    {:error, {Cldr.UnknownCurrencyError, "Currency #{inspect currency_code} is not known"}}
  end
end
