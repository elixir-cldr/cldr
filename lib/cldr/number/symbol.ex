defmodule Cldr.Number.Symbol do
  @moduledoc """
  Functions to manage the symbol definitions for a locale and
  number system.
  """

  require Cldr
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
  @spec number_symbols_for(Locale.name) :: Keyword.t
  def number_symbols_for(locale \\ Cldr.get_current_locale())

  for locale <- Cldr.Config.known_locales() do
    symbols =
      locale
      |> Cldr.Config.get_locale
      |> Map.get(:number_symbols)

    def number_symbols_for(unquote(locale)) do
      symbols =
        unquote(Macro.escape(symbols))
        |> Enum.map(fn
            {k, nil} -> {k, nil}
            {k, v} -> {k, struct(__MODULE__, v)}
           end)
        |> Enum.into(%{})

      {:ok, symbols}
    end
  end

  def number_symbols_for(locale) do
    {:error, Locale.locale_error(locale)}
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
  @spec number_symbols_for(Local.t, atom | binary) ::
    {:ok, Map.t} | {:no_symbols, String.t} | {:error, String.t}

  def number_symbols_for(locale, number_system) do
    with {:ok, system_name} <- Number.System.system_name_from(number_system, locale),
         {:ok, symbols} <- number_symbols_for(locale)
    do
      symbols
      |> Map.get(system_name)
      |> get_symbols_return(locale, number_system)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp get_symbols_return(nil, locale, number_system) do
    {:no_symbols, "The locale #{inspect locale} does not have " <>
        "any symbols for number system #{inspect number_system}"}
  end

  defp get_symbols_return(symbols, _locale, _number_system) do
    {:ok, symbols}
  end
end
