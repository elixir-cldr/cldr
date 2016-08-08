defmodule Cldr.Number.Format do
  defstruct [:standard, :currency, :accounting, :scientific, :percent]
  alias Cldr.File
  
  @moduledoc """
  Functions for introspecting on the number formats in CLDR.
  
  These functions would normally be used at compile time
  to generate functions for formatting numbers.
  
  Details of the number formats are described in the 
  [Unicode documentation](http://unicode.org/reports/tr35/tr35-numbers.html#Number_Format_Patterns)
  """
  
  @type format :: String.t

  @doc """
  The decimal formats in configured locales.
  
  Example:
  
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
  
  Example:
  
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
  @decimal_format_list Enum.map(@decimal_formats, fn {_locale, formats} -> Map.values(formats) end)
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
  
  Examples:
  
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
end 