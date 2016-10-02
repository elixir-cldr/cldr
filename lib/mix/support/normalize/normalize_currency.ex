defmodule Cldr.Normalize.Currency do

  def normalize(content, locale) do
    content
    |> normalize_currencies(locale)
  end

  def normalize_currencies(content, _locale) do
    currency_data = get_currency_data()
    default = currency_data["DEFAULT"]
    currencies = get_in(content, ["numbers", "currencies"])
    currencies = Enum.map(currencies, fn {code, currency} ->
      code = String.upcase(to_string(code))
      currency_map = %Cldr.Currency{
        code:          code,
        name:          currency["display_name"],
        symbol:        currency["symbol"],
        narrow_symbol: currency["symbol_alt_narrow"],
        tender:        String.to_atom(currency_data[code]["_tender"]   || "true"),
        digits:        String.to_integer(currency_data[code]["_digits"] || default["_digits"]),
        rounding:      String.to_integer(currency_data[code]["_rounding"] || default["_rounding"]),
        cash_digits:   String.to_integer(currency_data[code]["_cash_digits"] || currency_data[code]["_digits"]   || default["_digits"]),
        cash_rounding: String.to_integer(currency_data[code]["_cash_rounding"] || currency_data[code]["_rounding"] || default["_rounding"]),
        count:         currency_counts(currency)
      }
      {code, currency_map}
    end)
    |> Enum.into(%{})

    Map.put(content, "currencies", currencies)
  end

  @count_types [:zero, :one, :two, :few, :many, :other]
  @spec currency_counts(Currency.t) :: Map.t
  def currency_counts(currency) do
    Enum.reduce @count_types, %{}, fn (category, counts) ->
      if display_count = currency["display_name_count_#{category}"] do
        Map.put(counts, category, display_count)
      else
        counts
      end
    end
  end

  @currency_path Path.join(Cldr.Consolidate.download_data_dir(),
    ["cldr-core", "/supplemental", "/currencyData.json"])

  def get_currency_data do
    @currency_path
    |> File.read!
    |> Poison.decode!
    |> Cldr.Map.underscore_keys
    |> get_in(["supplemental", "currency_data", "fractions"])
    |> upcase_currency_codes
  end

  defp upcase_currency_codes(currencies) do
    Enum.map(currencies, fn {k, v} -> {String.upcase(k), v} end)
    |> Enum.into(%{})
  end
end