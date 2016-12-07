defmodule Cldr.Number.Format do
  @moduledoc """
  Functions to manage the collection of number patterns defined in Cldr.

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
  [Unicode documentation](http://unicode.org/reports/tr35/tr35-numbers.html#Number_Format_Patterns)
  """

  @type format :: String.t
  @short_format_styles [:decimal_long, :decimal_short, :currency_short,
                        :currency_long]

  @format_styles       [:standard, :currency, :accounting, :scientific,
                        :percent] ++ @short_format_styles

  defstruct @format_styles ++ [:currency_spacing]
  alias Cldr.Number.System
  alias Cldr.Locale

  def short_format_styles do
    @short_format_styles
  end

  @doc """
  Returns the list of decimal formats in the configured locales.

  This function exists to allow the decimal formatter
  to precompile all the known formats at compile time.

  ## Example

      Cldr.Number.Format.decimal_format_list ["#", "#,##,##0%",
      #=> "#,##,##0.###", "#,##,##0.00¤", "#,##,##0.00¤;(#,##,##0.00¤)",
      "#,##,##0 %", "#,##0%", "#,##0.###", "#,##0.00 ¤",
      "#,##0.00 ¤;(#,##0.00 ¤)", "#,##0.00¤", "#,##0.00¤;(#,##0.00¤)",
      "#,##0 %", "#0%", "#0.######", "#0.00 ¤", "#E0", "%#,##0", "% #,##0",
      "0", "0.000000E+000", "0000 M ¤", "0000¤", "000G ¤", "000K ¤", "000M ¤",
      "000T ¤", "000mM ¤", "000m ¤", "000 Bio'.' ¤", "000 Bln ¤", "000 Bn ¤",
      "000 B ¤", "000 E ¤", "000 K ¤", "000 MRD ¤", "000 Md ¤", "000 Mio'.' ¤",
      "000 Mio ¤", "000 Mld ¤", "000 Mln ¤", "000 Mn ¤", "000 Mrd'.' ¤",
      "000 Mrd ¤", "000 Mr ¤", "000 M ¤", "000 NT ¤", "000 N ¤", "000 Tn ¤",
      "000 Tr ¤", ...]
  """
  @spec decimal_format_list :: [format]
  def decimal_format_list do
    Cldr.known_locales()
    |> Enum.map(&decimal_format_list_for/1)
    |> List.flatten
    |> Enum.uniq
    |> Enum.sort
  end

  @doc """
  Returns the list of decimal formats for a configured locale.

  * `locale` is any locale configured in the system.  See `Cldr.known_locales/0`

  This function exists to allow the decimal formatter
  to precompile all the known formats at compile time.

  ## Example

      iex> Cldr.Number.Format.decimal_format_list_for "en"
      ["#,##0%", "#,##0.###", "#E0", "0 billion", "0 million", "0 thousand",
       "0 trillion", "00 billion", "00 million", "00 thousand", "00 trillion",
       "000 billion", "000 million", "000 thousand", "000 trillion", "000B", "000K",
       "000M", "000T", "00B", "00K", "00M", "00T", "0B", "0K", "0M", "0T",
       "¤#,##0.00", "¤#,##0.00;(¤#,##0.00)", "¤000B", "¤000K", "¤000M",
       "¤000T", "¤00B", "¤00K", "¤00M", "¤00T", "¤0B", "¤0K", "¤0M", "¤0T"]
  """
  def decimal_format_list_for(locale) do
    Locale.get_locale(locale)
    |> get_in([:number_formats])
    |> Map.delete(:minimum_grouping)
    |> Map.values
    |> Enum.map(fn m ->
        Map.delete(m, :currency_spacing)
        |> Map.delete(:currency_long) end)
    |> hd
    |> Map.values
    |> List.flatten
    |> Enum.map(&extract_formats/1)
    |> List.flatten
    |> Enum.reject(&(&1 == Cldr.Number.Format || is_nil(&1)))
    |> Enum.uniq
    |> Enum.sort
  end

  @doc """
  The decimal formats defined for a given locale or
  for a given locale and number system.

  * `locale` is any locale configured in the system.  See `Cldr.known_locales/0`

  ## Examples

      Cldr.Number.Format.decimal_formats_for("en")
      #=> %{latn: %Cldr.Number.Format{
        accounting: "¤#,##0.00;(¤#,##0.00)",
        currency: "¤#,##0.00",
        percent: "#,##0%",
        scientific: "#E0",
        standard: "#,##0.###",
        currency_short: [{"1000", [one: "¤0K", other: "¤0K"]},
         {"10000", [one: "¤00K", other: "¤00K"]},
         {"100000", [one: "¤000K", other: "¤000K"]},
         {"1000000", [one: "¤0M", other: "¤0M"]},
         {"10000000", [one: "¤00M", other: "¤00M"]},
         {"100000000", [one: "¤000M", other: "¤000M"]},
         {"1000000000", [one: "¤0B", other: "¤0B"]},
         {"10000000000", [one: "¤00B", other: "¤00B"]},
         {"100000000000", [one: "¤000B", other: "¤000B"]},
         {"1000000000000", [one: "¤0T", other: "¤0T"]},
         {"10000000000000", [one: "¤00T", other: "¤00T"]},
         {"100000000000000", [one: "¤000T", other: "¤000T"]}],
         ....
        }

  """
  @spec all_formats_for(Cldr.locale) :: Map.t
  def all_formats_for(locale) do
    Locale.get_locale(locale).number_formats
  end

  @doc """
  Return the format mask for a given `locale` and `number_system`.

  * `locale` is any locale configured in the system.  See `Cldr.known_locales/0`

  * `number_system` is either:

    * an `atom` in which case it is interpreted as a `number system type`
    in the given locale.  Typically this would be either `:default` or
    `:native`. See `Cldr.Number.Format.format_types_for/1` for the number
    system types available for a given `locale`.

    * a `binary` in which case it is used to look up the number system
    directly (for exmple `"latn"` which is common for western european
    languages). See `Cldr.Number.Format.formats_for/1` for the
    available formats for a `locale`.

  ## Example

      Cldr.Number.Format.formats_for "fr", :native
      #=> %Cldr.Number.Format{
        accounting: "#,##0.00 ¤;(#,##0.00 ¤)",
        currency: "#,##0.00 ¤",
        percent: "#,##0 %",
        scientific: "#E0",
        standard: "#,##0.###"
        currency_short: [{"1000", [one: "0 k ¤", other: "0 k ¤"]},
         {"10000", [one: "00 k ¤", other: "00 k ¤"]},
         {"100000", [one: "000 k ¤", other: "000 k ¤"]},
         {"1000000", [one: "0 M ¤", other: "0 M ¤"]},
         {"10000000", [one: "00 M ¤", other: "00 M ¤"]},
         {"100000000", [one: "000 M ¤", other: "000 M ¤"]},
         {"1000000000", [one: "0 Md ¤", other: "0 Md ¤"]},
         {"10000000000", [one: "00 Md ¤", other: "00 Md ¤"]},
         {"100000000000", [one: "000 Md ¤", other: "000 Md ¤"]},
         {"1000000000000", [one: "0 Bn ¤", other: "0 Bn ¤"]},
         {"10000000000000", [one: "00 Bn ¤", other: "00 Bn ¤"]},
         {"100000000000000", [one: "000 Bn ¤", other: "000 Bn ¤"]}],
         ...
        }

  """
  @spec formats_for(Cldr.locale, atom | String.t) :: Map.t
  def formats_for(locale \\ Cldr.get_locale(), number_system \\ :default)

  def formats_for(locale, number_system) do
    system = System.system_name_from(number_system, locale)
    all_formats_for(locale)[system]
  end

  @doc """
  Returns the format styles available for a `locale`.

  * `locale` is any locale configured in the system.  See `Cldr.known_locales/0`

  * `number_system` which defaults to `:default` and is either:

    * an `atom` in which case it is interpreted as a `number system type`
    in the given locale.  Typically this would be either `:default` or
    `:native`. See `Cldr.Number.Format.format_types_for/1` for the number
    system types available for a given `locale`.

    * a `binary` in which case it is used to look up the number system
    directly (for exmple `"latn"` which is common for western european
    languages). See `Cldr.Number.Format.formats_for/1` for the
    available formats for a `locale`.

  Format styles standardise the access to a format defined for a common
  use.  These types are `:standard`, `:currency`, `:accounting`, `:scientific`
  and :percent, :currency_short, :decimal_short, :decimal_long.

  These types can be used when formatting a number for output.  For example
  `Cldr.Number.to_string(123.456, format: :percent)`.

  ## Example

      iex> Cldr.Number.Format.format_styles_for("en")
      [:accounting, :currency, :currency_long, :currency_short,
      :decimal_long, :decimal_short, :percent, :scientific, :standard]
  """
  @spec format_styles_for(Cldr.locale, atom | String.t) :: [atom]
  def format_styles_for(locale \\ Cldr.get_locale(), number_system \\ :default) do
    formats_for(locale, number_system)
    |> Map.to_list
    |> Enum.reject(fn {k, v} -> is_nil(v) || k == :__struct__  || k == :currency_spacing end)
    |> Enum.into(%{})
    |> Map.keys
  end

  @doc """
  Returns the short formats available for a locale.

  * `locale` is any locale configured in the system.  See `Cldr.known_locales/0`

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

      iex> Cldr.Number.Format.short_format_styles_for("he")
      [:currency_short, :decimal_long, :decimal_short]
  """
  @isnt_really_a_short_format [:currency_long]
  def short_format_styles_for(locale, number_system \\ :default) do
    formats = locale
    |> format_styles_for(number_system)
    |> MapSet.new

    short_formats = (@short_format_styles -- @isnt_really_a_short_format)
    |> MapSet.new

    MapSet.intersection(formats, short_formats)
    |> MapSet.to_list
  end

  @doc """
  Returns the decimal format styles that are supported by
  `Cldr.Number.Formatter.Decimal`.

  * `locale` is any locale configured in the system.  See `Cldr.known_locales/0`

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

      iex> Cldr.Number.Format.decimal_format_styles_for "en"
      [:accounting, :currency, :currency_long, :percent,
       :scientific, :standard]
  """
  def decimal_format_styles_for(locale, number_system \\ :default) do
    format_styles_for(locale, number_system)
      -- short_format_styles_for(locale, number_system)
      -- [:currency_long, :currency_spacing]
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

      iex> Cldr.Number.Format.format_system_types_for "pl"
      [:default, :native]

      iex> Cldr.Number.Format.format_system_types_for "ru"
      [:default, :native]

      iex> Cldr.Number.Format.format_system_types_for "th"
      [:default, :native]
  """
  @spec format_system_types_for(Cldr.locale) :: [atom]
  def format_system_types_for(locale \\ Cldr.get_locale()) do
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
      [:latn, :thai]

      iex> Cldr.Number.Format.format_system_names_for("pl")
      [:latn]
  """
  @spec format_system_names_for(Cldr.locale) :: [String.t]
  def format_system_names_for(locale \\ Cldr.get_locale()) do
    Cldr.Number.System.number_system_names_for(locale)
  end

  def minimum_grouping_digits_for(locale) do
    get_in(Locale.get_locale(locale), [:minimum_grouping_digits])
  end

  # Extract number formats from short and long lists
  defp extract_formats(formats = %{}) do
    Map.values(formats)
  end

  defp extract_formats(format) when is_number(format) do
    nil
  end

  defp extract_formats(short_format) do
    short_format
  end
end
