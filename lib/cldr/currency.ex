defmodule Cldr.Currency do
  @moduledoc """
  Defines a currency structure and a set of functions to manage the validity of a currency code
  and to return metadata for currencies.
  """
  require Cldr

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
  Returns a `Currency` struct created from the arguments.

  * `currency` is a custom currency code of a format defined in ISO4217

  * `options` is a map of options representing the optional elements of the `%Currency{}` struct

  ## Example

      iex> Cldr.Currency.new(:XAA)
      {:ok,
       %Cldr.Currency{cash_digits: 0, cash_rounding: 0, code: :XAA, count: nil,
        digits: 0, name: "", narrow_symbol: nil, rounding: 0, symbol: "",
        tender: false}}

      iex> Cldr.Currency.new(:XAA, name: "Custom Name")
      {:ok,
       %Cldr.Currency{cash_digits: 0, cash_rounding: 0, code: :XAA, count: nil,
        digits: 0, name: "Custom Name", narrow_symbol: nil, rounding: 0, symbol: "",
        tender: false}}

      iex> Cldr.Currency.new(:XBC)
      {:error, "Currency :XBC is already defined"}
  """
  @spec new(binary | atom, map | list) :: t | {:error, binary}
  @currency_defaults %{
    name: "",
    symbol: "",
    narrow_symbol: nil,
    digits: 0,
    rounding: 0,
    cash_digits: 0,
    cash_rounding: 0,
    tender: false
  }
  def new(currency, options \\ [])

  def new(currency, options) when is_list(options) do
    new(currency, Enum.into(options, %{}))
  end

  def new(currency, options) when is_map(options) do
    with false <- known_currency?(currency),
         {:ok, currency_code} <- make_currency_code(currency)
    do
      options = @currency_defaults
      |> Map.merge(options)
      |> Map.merge(%{code: currency_code})

      {:ok, struct(__MODULE__, options)}
    else
      true -> {:error, "Currency #{inspect currency} is already defined"}
      error -> error
    end
  end

  @doc """
  Returns the appropriate currency display name for the `currency`, based
  on the plural rules in effect for the `locale`.

  * `number` is an integer, float or `Decimal`

  * `currency` is any currency returned by `Cldr.Currency.known_currencies/0`

  * `options` is a keyword list of options
    * `:locale` is any locale returned by `Cldr.known_locales/0`.  The
    default is `Cldr.get_current_locale/0`

  ## Examples

      iex> Cldr.Currency.pluralize 1, :USD
      "US dollar"

      iex> Cldr.Currency.pluralize 3, :USD
      "US dollars"

      iex> Cldr.Currency.pluralize 12, :USD, locale: "zh"
      "美元"

      iex> Cldr.Currency.pluralize 12, :USD, locale: "fr"
      "dollars des États-Unis"

      iex> Cldr.Currency.pluralize 1, :USD, locale: "fr"
      "dollar des États-Unis"

  """
  def pluralize(number, currency, options \\ []) do
    default_options = [locale: Cldr.get_current_locale()]
    options = Keyword.merge(default_options, options)
    locale = options[:locale]

    with {:ok, currency_code} <- validate_currency_code(currency),
         {:ok, locale} <- Cldr.valid_locale?(locale)
    do
      currency_data = for_code(currency_code, locale)
      counts = Map.get(currency_data, :count)
      Cldr.Number.Cardinal.pluralize(number, locale, counts)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Returns a list of all known currency codes.

  ## Example

      iex> Cldr.Currency.known_currencies |> Enum.count
      298
  """
  @known_currencies Cldr.Config.currency_codes
  def known_currencies do
    @known_currencies
  end

  @doc """
  Returns a boolean indicating if the supplied currency code is known.

  * `currency_code` is a `binary` or `atom` representing an ISO4217
  currency code

  * `custom_currencies` is an optional list of custom currencies created by the
  `Cldr.Currency.new/2` function

  ## Examples

      iex> Cldr.Currency.known_currency? "AUD"
      true

      iex> Cldr.Currency.known_currency? "GGG"
      false

      iex> Cldr.Currency.known_currency? :XCV
      false

      iex> Cldr.Currency.known_currency? :XCV, [%Cldr.Currency{code: :XCV}]
      true
  """
  @spec known_currency?(code, [__MODULE__, ...]) :: boolean
  def known_currency?(currency_code, custom_currencies \\ [])
  def known_currency?(currency_code, custom_currencies) when is_binary(currency_code) do
    case code_atom = normalize_currency_code(currency_code) do
      {:error, {_exception, _message}} -> false
      _ -> known_currency?(code_atom, custom_currencies)
    end
  end

  def known_currency?(currency_code, custom_currencies)
  when is_atom(currency_code) and is_list(custom_currencies) do
    !!(Enum.find(known_currencies(), &(&1 == currency_code)) ||
       Enum.find(custom_currencies, &(&1.code == currency_code)))
  end

  @doc """
  Returns a normalized currency code if the code is valid or an error tuple if not.

  Similar to the function `known_currency/1` but whereas that function returns a
  `boolean` result, this function returns an `{:ok, code}` or `{:error, {exception, reason}}`
  tuple.

  ## Examples

      iex> Cldr.Currency.validate_currency_code :usd
      {:ok, :USD}

      iex> Cldr.Currency.validate_currency_code "usd"
      {:ok, :USD}

      iex> Cldr.Currency.validate_currency_code "USD"
      {:ok, :USD}

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
          {:ok, code_atom}
        else
          error_tuple(code_atom)
        end
    end
  end

  @doc """
  Returns a valid normalized ISO4217 format custom currency code or an error.

  Currency codes conform to the ISO4217 standard which means that any
  custom currency code must start with an "X" followed by two alphabetic
  characters.

  ## Examples

      iex> Cldr.Currency.make_currency_code("xzz")
      {:ok, :XZZ}

      iex> Cldr.Currency.make_currency_code("aaa")
      {:error,
       "Invalid currency code \\"AAA\\".  Currency codes must start with 'X' followed by 2 alphabetic characters only."}

  Note that since this function creates atoms, its important that this
  function not be called with arbitrary user input since that risks
  overflowing the atom table.
  """
  @valid_currency_code Regex.compile!("^X[A-Z]{2}$")
  @spec make_currency_code(binary | atom) :: {:ok, atom} | {:error, binary}
  def make_currency_code(code) do
    currency_code = code
    |> to_string
    |> String.upcase

    if String.match?(currency_code, @valid_currency_code) do
      {:ok, String.to_atom(currency_code)}
    else
      {:error, "Invalid currency code #{inspect currency_code}.  " <>
        "Currency codes must start with 'X' followed by 2 alphabetic characters only."}
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
  def for_code(currency_code, locale \\ Cldr.get_current_locale()) do
    case validate_currency_code(currency_code) do
      {:error, {_exception, _message}} = error ->
        error
      {:ok, code} ->
        locale
        |> for_locale
        |> Map.get(code)
    end
  end

  @doc """
  Returns the currency metadata for a locale.
  """
  @spec for_locale(Cldr.locale) :: Map.t
  def for_locale(locale \\ Cldr.get_current_locale())

  for locale <- Cldr.Config.known_locales() do
    currencies =
      locale
      |> Cldr.Config.get_locale
      |> Map.get(:currencies)

    def for_locale(unquote(locale)) do
      unquote(Macro.escape(currencies))
      |> Enum.map(fn {k, v} -> {k, struct(__MODULE__, v)} end)
      |> Enum.into(%{})
    end
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
  def normalize_currency_code!(currency_code)
  when is_binary(currency_code) or is_atom(currency_code) do
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
