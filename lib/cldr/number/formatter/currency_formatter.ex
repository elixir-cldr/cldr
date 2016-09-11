defmodule Cldr.Number.Formatter.Currency do
  @moduledoc """
  Format a number in a `:long` format for a :currency.

  This formatter implements formatting a currency in a long form. This
  is not the same as decimal formatting with a currency placeholder.

  To explain the difference, look at the following examples:

      iex> Number.to_string 123, format: :currency, currency: "USD"
      "$123.00"

      iex> Number.to_string 123, format: :long, currency: "USD"
      "123.00 US dollars"

  In the first example the format is defined by a decimal mask. In this example
  the format mask comes from:

      iex> Cldr.Number.Format.decimal_formats_for("en").latn.currency
      "¤#,##0.00"

  In the second example we are using a format that combines the number with
  a language translation of the currency name.  In this example the format
  comes from:

      iex> Number.Format.decimal_formats_for("en").latn.currency_long
      [one: "{0} {1}", other: "{0} {1}"]

  Where "{0}" is replaced with the number formatted using the `:standard`
  decimal format and "{1} is replaced with locale-specific name of the
  currency adjusted for the locales plural rules."
  """

  alias Cldr.Number.Format
  alias Cldr.Number.System
  alias Cldr.Number
  alias Cldr.Currency

  def to_string(number, :currency_long, options) do
    locale = options[:locale]

    number_system = options[:number_system]
    |> System.system_name_from(locale)

    if !(formats = Format.formats_for(locale, number_system).currency_long) do
      raise ArgumentError, message: "No :currency_long format known for " <>
      "locale #{inspect locale} and number system #{inspect number_system}."
    end

    count = Number.Cardinal.plural_rule(number, locale)
    currency = Currency.for_code(options[:currency], locale)

    format = formats[count] || formats[:other]
    options = Keyword.delete(options, :format) |> Keyword.put(:format, :standard)
    currency_string = currency.count[count]
    number_string = Number.to_string(number, options)

    format
    |> String.replace("{0}", number_string)
    |> String.replace("{1}", currency_string)
  end
end
