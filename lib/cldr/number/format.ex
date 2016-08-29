defmodule Cldr.Number.Format do
  @moduledoc """
  Manages the collection of number patterns defined in Cldr.

  Number patterns affect how numbers are interpreted in a localized context.
  Here are some examples, based on the French locale. The "." shows where the
  decimal point should go. The "," shows where the thousands separator should
  go. A "0" indicates zero-padding: if the number is too short, a zero (in the
  locale's numeric set) will go there. A "#" indicates no padding: if the
  number is too short, nothing goes there. A "¤" shows where the currency sign
  will go. The following illustrates the effects of different patterns for the
  French locale, with the number "1234.567". Notice how the pattern characters
  ',' and '.' are replaced by the characters appropriate for the locale.

  ## Number Pattern Examples

  | Pattern	      | Currency	      | Text        |
  | ------------- | :-------------: | ----------: |
  | #,##0.##	    | n/a	            | 1 234,57    |
  | #,##0.###	    | n/a	            | 1 234,567   |
  | ###0.#####	  | n/a	            | 1234,567    |
  | ###0.0000#	  | n/a	            | 1234,5670   |
  | 00000.0000	  | n/a	            | 01234,5670  |
  | #,##0.00 ¤	  | EUR	            | 1 234,57 €  |

  The number of # placeholder characters before the decimal do not matter,
  since no limit is placed on the maximum number of digits. There should,
  however, be at least one zero some place in the pattern. In currency formats,
  the number of digits after the decimal also do not matter, since the
  information in the supplemental data (see Supplemental Currency Data) is used
  to override the number of decimal places — and the rounding — according to
  the currency that is being formatted. That can be seen in the above chart,
  with the difference between Yen and Euro formatting.

  Details of the number formats are described in the
  [Unicode documentation]
  (http://unicode.org/reports/tr35/tr35-numbers.html#Number_Format_Patterns)
  """

  @type format :: String.t
  @format_types [:standard, :currency, :accounting, :scientific, :percent]

  defstruct @format_types
  defdelegate minimum_grouping_digits_for(locale), to: Cldr.Number.Symbol
  alias Cldr.File
  alias Cldr.Number.System

  @doc """
  The decimal formats in configured locales.

  ## Example

      Cldr.Number.Format.decimal_formats
      %{"en" => %{
          latn: %Cldr.Number.Format{accounting: "¤#,##0.00;(¤#,##0.00)",
           currency: "¤#,##0.00", percent: "#,##0%", scientific: "#E0",
           standard: "#,##0.###"}},
        "th" => %{
          latn: %Cldr.Number.Format{accounting: "¤#,##0.00;(¤#,##0.00)",
           currency: "¤#,##0.00", percent: "#,##0%", scientific: "#E0",
           standard: "#,##0.###"},
          thai: %Cldr.Number.Format{accounting: "¤#,##0.00;(¤#,##0.00)",
           currency: "¤#,##0.00", percent: "#,##0%", scientific: "#E0",
           standard: "#,##0.###"}}}
  """
  @decimal_formats File.read(:decimal_formats)
  def decimal_formats do
    @decimal_formats
  end

  @doc """
  Returns the list of decimal formats in the
  CLDR repository.

  ## Example

      iex(1)> Cldr.Number.Format.decimal_format_list
      ["#", "#,##,##0%", "#,##,##0.###", "#,##,##0.00¤",
      "#,##,##0.00¤;(#,##,##0.00¤)", "#,##,##0 %", "#,##0%",
      "#,##0.###", "#,##0.00 ¤", "#,##0.00 ¤;(#,##0.00 ¤)",
      "#,##0.00¤", "#,##0.00¤;(#,##0.00¤)", "#,##0 %", "#0%",
      "#0.######", "#0.00 ¤", "#E0", "%#,##0", "% #,##0",
      "0.000000E+000", "[#E0]", "¤#,##,##0.00",
      "¤#,##,##0.00;(¤#,##,##0.00)", "¤#,##0.00",
      "¤#,##0.00;(¤#,##0.00)", "¤#,##0.00;¤-#,##0.00",
      "¤#,##0.00;¤- #,##0.00", "¤ #,##,##0.00", "¤ #,##0.00",
      "¤ #,##0.00;(¤ #,##0.00)", "¤ #,##0.00;¤-#,##0.00",
      "¤ #,##0.00;¤ #,##0.00-", "¤ #,##0.00;¤ -#,##0.00",
      "¤ #0.00", "‎¤#,##0.00", "‎¤#,##0.00;‎(¤#,##0.00)"]
  """
  @decimal_format_list @decimal_formats
  |> Enum.map(fn {_locale, formats} -> Map.values(formats) end)
  |> Enum.map(&(hd(&1)))
  |> Enum.map(&(Map.values(&1)))
  |> List.flatten
  |> Enum.reject(&(&1 == Cldr.Number.Format || is_nil(&1)))
  |> Enum.uniq
  |> Enum.sort

  @spec decimal_format_list :: [format]
  def decimal_format_list do
    @decimal_format_list
  end

  @doc """
  The decimal formats defined for a given locale or
  for a given locale and number system.

  * `locale` is any locale configured in the system.  See `Cldr.known_locales/0`

  ## Examples

      iex(2)> Cldr.Number.Format.decimal_formats_for "en"
      %{latn: %Cldr.Number.Format{accounting: "¤#,##0.00;(¤#,##0.00)", currency: "¤#,##0.00",
      percent: "#,##0%", scientific: "#E0", standard: "#,##0.###"}}

      iex(1)> Cldr.Number.Format.decimal_formats_for "th"
      %{latn: %Cldr.Number.Format{accounting: "¤#,##0.00;(¤#,##0.00)", currency: "¤#,##0.00",
      percent: "#,##0%", scientific: "#E0", standard: "#,##0.###"},
      thai: %Cldr.Number.Format{accounting: "¤#,##0.00;(¤#,##0.00)", currency: "¤#,##0.00",
      percent: "#,##0%", scientific: "#E0", standard: "#,##0.###"}}

      iex(2)> Cldr.Number.Format.decimal_formats_for "th", :thai
      %Cldr.Number.Format{accounting: "¤#,##0.00;(¤#,##0.00)", currency: "¤#,##0.00",
      percent: "#,##0%", scientific: "#E0", standard: "#,##0.###"}
  """
  @spec decimal_formats_for(Cldr.locale) :: Map.t
  @spec decimal_formats_for(Cldr.locale, Cldr.Number.System.name) :: Map.t
  Enum.each @decimal_formats, fn {locale, formats} ->
    def decimal_formats_for(unquote(locale)) do
      unquote(Macro.escape(formats))
    end

    Enum.each formats, fn {number_system, system_formats} ->
      def decimal_formats_for(unquote(locale), unquote(number_system)) do
        unquote(Macro.escape(system_formats))
      end
    end
  end

  def decimal_formats_for(locale) do
    raise ArgumentError, "Unknown locale #{inspect locale}."
  end

  def decimal_formats_for(locale, number_system) do
    raise ArgumentError,
    "Unknown locale #{inspect locale} or number system #{inspect number_system}."
  end

  @doc """
  Return the format mask for a given `locale` and `number_system`.

  * `locale` is any locale configured in the system.  See `Cldr.known_locales/0`

  * `number_system` is either:

    * an `atom` in which case it is interpreted as a `number system type`
    in the given locale.  Typically this would be either `:default` or
    `:native`. See `Cldr.Number.Format.format_types_for/1` for the number
    system types available for a given `locale`.

    * a `String.t` in which case it is used to look up the number system
    directly (for exmple `"latn"` which is common for western european
    languages). See `Cldr.Number.Format.decimal_formats_for/1` for the
    available formats for a `locale`.

  ## Examples

      iex> Cldr.Number.Format.formats_for "en", "latn"
      %Cldr.Number.Format{accounting: "¤#,##0.00;(¤#,##0.00)",
       currency: "¤#,##0.00", percent: "#,##0%", scientific: "#E0",
       standard: "#,##0.###"}

      iex> Cldr.Number.Format.formats_for "en", :default
      %Cldr.Number.Format{accounting: "¤#,##0.00;(¤#,##0.00)",
       currency: "¤#,##0.00", percent: "#,##0%", scientific: "#E0",
       standard: "#,##0.###"}

      iex> Cldr.Number.Format.formats_for "fr", :native
      %Cldr.Number.Format{accounting: "#,##0.00 ¤;(#,##0.00 ¤)",
       currency: "#,##0.00 ¤", percent: "#,##0 %", scientific: "#E0",
       standard: "#,##0.###"}
  """
  @spec formats_for(Cldr.locale, atom | String.t) :: Map.t
  def formats_for(locale \\ Cldr.default_locale(), number_system \\ :default)

  def formats_for(locale, number_system) when is_atom(number_system) do
    system = System.number_systems_for(locale)[number_system].name
    |> String.to_existing_atom
    decimal_formats_for(locale)[system]
  end

  def formats_for(locale, number_system) when is_binary(number_system) do
    system = String.to_existing_atom(number_system)
    decimal_formats_for(locale)[system]
  end

  @doc """
  Returns the format types available for a `locale`.

  * `locale` is any locale configured in the system.  See `Cldr.known_locales/0`

  Format types standardise the access to a format task defined for a common
  use.  These types are `:standard`, `:currency`, `:accounting`, `:scientific`
  and :percent.

  These types can be used when formatting a number for output.  For example
  `Cldr.Number.to_string(123.456, as: :percent)`.

  ## Example

      iex(34)> Cldr.Number.Format.format_types_for
      [:accounting, :currency, :percent, :scientific, :standard]
  """
  @spec format_types_for(Cldr.locale, atom | String.t) :: [atom]
  def format_types_for(locale \\ Cldr.default_locale(), number_system \\ :default) do
    formats_for(locale, number_system)
    |> Map.to_list
    |> Enum.reject(fn {k, v} -> is_nil(v) || k == :__struct__ end)
    |> Enum.into(%{})
    |> Map.keys
  end


  @doc """
  Returns the number system types available for a `locale`

  * `locale` is any locale configured in the system.  See `Cldr.known_locales/0`

  A number system type is an identifier that categorises number systems
  that comprise a site of digits or rules for transliterating or translating
  digits and a number system name for determining plural rules and format
  masks.

  If that all sounds a bit complicated then the default `number system type`
  called `:default` is probably what you want nearly all the time.

  ## Examples

      iex(10)> Cldr.Number.Format.format_system_types_for "pl"
      [:default, :native]

      iex(11)> Cldr.Number.Format.format_system_types_for "ru"
      [:default, :native]

      iex(12)> Cldr.Number.Format.format_system_types_for "th"
      [:default, :native]
  """
  @spec format_system_types_for(Cldr.locale) :: [atom]
  def format_system_types_for(locale \\ Cldr.default_locale()) do
    Cldr.Number.System.number_systems_for(locale)
    |> Map.keys
  end

  @doc """
  Returns the names of the number systems for the `locale`.

  * `locale` is any locale configured in the system.  See `Cldr.known_locales/0`

  Delegates to `Cldr.Number.System.number_system_names_for(locale)` and
  is here for convenience.

  ## Examples

      iex> Cldr.Number.Format.format_system_names_for("th")
      ["latn", "thai"]

      iex> Cldr.Number.Format.format_system_names_for("pl")
      ["latn"]
  """
  @spec format_system_names_for(Cldr.locale) :: [String.t]
  def format_system_names_for(locale \\ Cldr.default_locale()) do
    Cldr.Number.System.number_system_names_for(locale)
  end
end
