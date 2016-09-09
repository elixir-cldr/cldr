defmodule Cldr.Number.Symbol do
  @moduledoc """
  Functions to manage the symbol definitions for a locale and
  number system.
  """

  import Cldr.Map
  alias Cldr.File
  alias Cldr.Number
  alias Cldr.Locale

  defstruct [:decimal, :group, :exponential, :infinity, :list, :minus_sign,
            :nan, :per_mille, :percent_sign, :plus_sign,
            :superscripting_exponent, :time_separator]

  Enum.each Cldr.known_locales, fn (locale) ->
    numbers = File.read(:numbers, locale)
    number_system_names = Number.System.number_system_names_for(locale)
    minimum_grouping_digits = String.to_integer(numbers[:minimum_grouping_digits])

    @doc """
    Returns the minimum number of grouping digits for a locale.

    ## Example

        iex> Cldr.Number.Symbol.minimum_grouping_digits_for("en")
        1
    """
    @spec minimum_grouping_digits_for(Local.t) :: integer
    def minimum_grouping_digits_for(unquote(locale)) do
      unquote(minimum_grouping_digits)
    end

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
    def number_symbols_for(unquote(locale)) do
      Enum.map Cldr.Number.System.number_system_names_for(unquote(locale)), fn name ->
        {String.to_existing_atom(name), number_symbols_for(unquote(locale), name)}
      end
    end

    @doc """
    Returns the number sysbols for a specific locale and number system.

    * `locale` is any locale known to `Cldr`.  See `Cldr.known_locales()`.

    * `system_name` is an atom or binary representing a number system. If the
      system_name is an atom then it is a key into the number systems for the
      locale (:default, :native, etc) which we use to look up the system name.
      If `system_name` is a binary then it is considered as the number system
      name itself ("latn", ...).  See `Cldr.Number.System.number_systems/0` and
      `Cldr.Number.System.number_systems_for/1`

    ## Example

        iex> Cldr.Number.Symbol.number_symbols_for("th", "thai")
        %{decimal: ".", exponential: "E", group: ",", infinity: "∞", list: ";",
          minus_sign: "-", nan: "NaN", per_mille: "‰", percent_sign: "%",
          plus_sign: "+", superscripting_exponent: "×", time_separator: ":"}
    """
    @spec number_symbols_for(Local.t, atom | binary) :: %Number.Symbol{}
    def number_symbols_for(locale, system_name)
    when is_atom(system_name) do
      number_system = Number.System.number_systems_for(locale)[system_name].name
      number_symbols_for(locale, number_system)
    end

    Enum.each number_system_names, fn (system_name) ->
      symbol_info = numbers["symbols-numberSystem-#{system_name}"]
      |> underscore_keys
      |> atomize_keys

      if is_nil(symbol_info) do
        def number_symbols_for(unquote(locale), unquote(system_name)) do
          %Number.Symbol{}
        end
      else
        def number_symbols_for(unquote(locale), unquote(system_name)) do
          symbols = unquote(Macro.escape(symbol_info))
          %Number.Symbol{
            group:          symbols.group,
            decimal:        symbols.decimal,
            exponential:    symbols.exponential,
            infinity:       symbols.infinity,
            list:           symbols.list,
            minus_sign:     symbols.minus_sign,
            nan:            symbols.nan,
            per_mille:      symbols.per_mille,
            percent_sign:   symbols.percent_sign,
            plus_sign:      symbols.plus_sign,
            time_separator: symbols.time_separator,
            superscripting_exponent:  symbols.superscripting_exponent
          }
        end
      end
    end
  end

  def number_symbols_for(locale, system_name) do
    raise Cldr.UnknownLocaleError,
      "Unknown locale #{inspect locale} or number system #{inspect system_name}."
  end

  def number_symbols_for(locale) do
    raise Cldr.UnknownLocaleError, "The locale #{inspect locale} is not known."
  end

  def minimum_grouping_digits_for(locale) do
    raise Cldr.UnknownLocaleError, "The locale #{inspect locale} is not known."
  end
end
