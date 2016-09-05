defmodule Cldr.Number.Generate.CurrencyFormats do
  @moduledoc """
  Function to format a number in a :long format for a :currency
  """
  alias Cldr.Number.Format
  alias Cldr.Number
  alias Cldr.Currency

  defmacro __using__(_options \\ []) do
    def_to_currency_long()
  end

  def def_to_currency_long do
    quote do
      def do_to_short_string(number, :currency_long, locale, number_system, options) do
        if !(formats = Format.formats_for(locale, number_system).currency_long) do
          raise ArgumentError, message: "No :currency_long format known for " <>
          "locale #{inspect locale} and number system #{inspect number_system}."
        end

        count = Number.Cardinal.plural_rule(number, locale)
        currency = Currency.for_locale(locale)[options[:currency]]

        format = formats[count] || formats[:other]
        currency_string = currency.count[count]
        options = Keyword.delete(options, :format) |> Keyword.put(:format, :standard)
        number_string = Number.to_string(number, options)

        format
        |> String.replace("{0}", number_string)
        |> String.replace("{1}", currency_string)
      end
    end
  end
end
