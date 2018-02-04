defmodule Cldr.Currency.Evaluator do
  @moduledoc """
  Simple analysis of the differences between the
  currencies defined in Cldr and those defined by
  ISO 4217.
  """

  @doc """
  Run some analysis of the differences between
  ISO 4217 and Cldr currency data.
  """
  def check do
    currencies =
      Cldr.get_current_locale
      |> Map.get(:cldr_locale_name)
      |> Cldr.Config.get_locale
      |> Map.get(:currencies)

    currency_has_no_iso =
      Enum.reduce currencies, [], fn {code, _currency}, acc ->
        if !Keyword.get(Cldr.IsoCurrency.currencies, code) do
          [code | acc]
        else
          acc
        end
      end

    iso_has_no_currency =
      Enum.filter Cldr.IsoCurrency.currencies, fn {code, _digits} ->
        is_nil(currencies[code])
      end

    digits_are_different =
      Enum.reduce currencies, %{}, fn {code, currency}, acc ->
        if currency[:digits] != currency[:iso_digits] && code not in currency_has_no_iso do
          Map.put(acc, code, %{digits: currency[:digits], iso_digits: currency[:iso_digits]})
        else
          acc
        end
      end

    tender_with_different_digits =
      Enum.filter digits_are_different, fn {code, _digits} -> currencies[code][:tender]
    end

    iso_nil_is_tender =
      Enum.filter currency_has_no_iso, fn code -> currencies[code][:tender]
    end

    %{
      currency_definition_has_no_iso_definition: currency_has_no_iso,
      digits_are_different_between_cldr_and_iso: digits_are_different,
      legal_tender_with_different_digits: tender_with_different_digits,
      legal_tender_but_no_iso: iso_nil_is_tender,
      iso_has_no_currency_definiton: iso_has_no_currency
    }
  end
end
