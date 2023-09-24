defmodule Cldr.Normalize.Currency do
  @moduledoc false

  def normalize(content, locale) do
    content
    |> normalize_currencies(locale)
  end

  def normalize_currencies(content, _locale) do
    currency_data = get_currency_data()["fractions"]
    default = currency_data["DEFAULT"]
    currencies = get_in(content, ["numbers", "currencies"])

    currencies =
      Enum.map(currencies, fn {code, currency} ->
        code = String.upcase(to_string(code))

        currency_map = %{
          code: code,
          name: currency["display_name"],
          symbol: currency["symbol"],
          narrow_symbol: currency["symbol_alt_narrow"],
          tender: String.to_atom(currency_data[code]["_tender"] || "true"),
          digits: String.to_integer(currency_data[code]["_digits"] || default["_digits"]),
          rounding: String.to_integer(currency_data[code]["_rounding"] || default["_rounding"]),
          cash_digits:
            String.to_integer(
              currency_data[code]["_cash_digits"] || currency_data[code]["_digits"] ||
                default["_digits"]
            ),
          cash_rounding:
            String.to_integer(
              currency_data[code]["_cash_rounding"] || currency_data[code]["_rounding"] ||
                default["_rounding"]
            ),
          count: currency_counts(currency),
          iso_digits: Cldr.IsoCurrency.currencies()[String.to_atom(code)],
          decimal_separator: currency["decimal"],
          grouping_separator: currency["group"]
        }

        {code, currency_map}
      end)
      |> Enum.into(%{})

    Map.put(content, "currencies", currencies)
  end

  @count_types [:zero, :one, :two, :few, :many, :other]
  @spec currency_counts(%{}) :: %{}
  def currency_counts(currency) do
    Enum.reduce(@count_types, %{}, fn category, counts ->
      if display_count = currency["display_name_count_#{category}"] do
        Map.put(counts, category, display_count)
      else
        counts
      end
    end)
  end

  @currency_path Path.join(Cldr.Config.download_data_dir(), [
                   "cldr-core",
                   "/supplemental",
                   "/currencyData.json"
                 ])

  def get_currency_data do
    @currency_path
    |> File.read!()
    |> Jason.decode!()
    |> Cldr.Map.underscore_keys()
    |> get_in(["supplemental", "currency_data"])
    |> upcase_currency_codes
    |> upcase_territory_codes
  end

  defp upcase_currency_codes(currencies) do
    fractions =
      currencies["fractions"]
      |> Enum.map(fn {k, v} -> {String.upcase(k), v} end)
      |> Enum.into(%{})

    Map.put(currencies, "fractions", fractions)
  end

  defp upcase_territory_codes(currencies) do
    regions =
      currencies["region"]
      |> Enum.map(fn {k, v} -> {String.upcase(k), v} end)
      |> Enum.map(fn {k, v} ->
        {k, Enum.map(v, &Cldr.Map.remove_leading_underscores/1)}
      end)
      |> Enum.map(fn {k, v} ->
        {
          k,
          Enum.map(v, fn list ->
            Enum.map(list, fn {k, v} -> {String.upcase(k), v} end) |> Enum.into(%{})
          end)
          |> make_list
        }
      end)
      |> Enum.into(%{})

    Map.put(currencies, "region", regions)
  end

  defp make_list(list) when is_list(list) do
    List.flatten(list)
  end
end
