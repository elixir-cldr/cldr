defmodule Cldr.Number.Symbol do
  @moduledoc """
  Functions to manage the symbol definitions for a locale and
  number system.
  """

  alias  Cldr.Number
  alias  Cldr.Locale

  defstruct [:decimal, :group, :exponential, :infinity, :list, :minus_sign,
            :nan, :per_mille, :percent_sign, :plus_sign,
            :superscripting_exponent, :time_separator]

  @doc """
  Returns a list of the number symbols for all number systems of a locale.

  * `locale` is any locale known to `Cldr`.  See `Cldr.known_locales()`.

  ## Example:

      iex> Symbol.number_symbols_for("th")
      [latn: %{decimal: ".", exponential: "E", group: ",", infinity: "∞", list: ";",
         minus_sign: "-", nan: "NaN", per_mille: "‰", percent_sign: "%",
         plus_sign: "+", superscripting_exponent: "×", time_separator: ":"},
       thai: %{decimal: ".", exponential: "E", group: ",", infinity: "∞", list: ";",
         minus_sign: "-", nan: "NaN", per_mille: "‰", percent_sign: "%",
         plus_sign: "+", superscripting_exponent: "×", time_separator: ":"}]
  """
  @spec number_symbols_for(Locale.t) :: Keyword.t
  def number_symbols_for(locale) do
    Locale.get_locale(locale).number_symbols
  end

  @doc """
  Returns the number sysbols for a specific locale and number system.

  * `locale` is any locale known to `Cldr`.  See `Cldr.known_locales()`.

  * `number_system` which defaults to `:default` and is either:

    * an `atom` in which case it is interpreted as a `number system type`
    in the given locale.  Typically this would be either `:default` or
    `:native`. See `Cldr.Number.Format.format_types_for/1` for the number
    system types available for a given `locale`.

    * a `binary` in which case it is used to look up the number system
    directly (for exmple `"latn"` which is common for western european
    languages). See `Cldr.Number.Format.formats_for/1` for the
    available formats for a `locale`.

  ## Example

      iex> Cldr.Number.Symbol.number_symbols_for("th", "thai")
      %{decimal: ".", exponential: "E", group: ",", infinity: "∞", list: ";",
        minus_sign: "-", nan: "NaN", per_mille: "‰", percent_sign: "%",
        plus_sign: "+", superscripting_exponent: "×", time_separator: ":"}
  """
  @spec number_symbols_for(Local.t, atom | binary) :: %Number.Symbol{}
  def number_symbols_for(locale, number_system) do
    number_system = Number.System.system_name_from(number_system, locale)
    number_symbols_for(locale)[number_system]
  end
end
