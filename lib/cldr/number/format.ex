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

  *Number Pattern Examples*
  
  | Pattern	      | Currency	      | Text        |
  |---------------|-----------------|-------------|
  | #,##0.##	    | n/a	            | 1 234,57    |
  | #,##0.###	    | n/a	            | 1 234,567   |
  | ###0.#####	  | n/a	            | 1234,567    |
  | ###0.0000#	  | n/a	            | 1234,5670   |
  | 00000.0000	  | n/a	            | 01234,5670  |
  | #,##0.00 ¤	  | EUR	            | 1 234,57 €  |
  |               | JPY	            | 1 235 ¥JP   |
            
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
  
  defstruct [:standard, :currency, :accounting, :scientific, :percent]
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
    raise ArgumentError, "Unknown locale #{inspect locale} or number_system #{inspect number_system}."
  end
  
  # use the `number_system` as a key to retrieve the format.  If you look
  # at `Cldr.Number.System.number_systems_for("en") as an example you'll 
  # see a map of number systems keyed by a `type`.  This is a good abstract 
  # to get to theformats when you're not interested in the details of a 
  # particular number system.
  def format_from(locale, number_system) when is_atom(number_system) do
    system = System.number_systems_for(locale)[number_system].name 
    |> String.to_existing_atom
    decimal_formats_for(locale)[system]
  end
  
  # ...If however you already know the number system you want, then just specify
  # it as a `String` for the `number_system` and it'll be directly retrieved.
  def format_from(locale, number_system) when is_binary(number_system) do
    system = String.to_existing_atom(number_system)
    decimal_formats_for(locale)[system]
  end
 
end 