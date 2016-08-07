defmodule Cldr.Number.Format do
  @moduledoc """
  Functions for introspecting on the number formats in CLDR.
  
  These functions would normally be used at compile time
  to generate functions for formatting numbers.
  
  Details of the number formats are described in the 
  [Unicode documentation](http://unicode.org/reports/tr35/tr35-numbers.html#Number_Format_Patterns)
  """
  @type format :: String.t
  
  @decimal_formats      Cldr.Number.Metadata.decimal_formats
  @decimal_format_list  Cldr.Number.Metadata.decimal_format_list
    
  @doc """
  The decimal formats in configured locales.
  """
  @spec decimal_formats :: %{}
  def decimal_formats do
    @decimal_formats
  end
  
  @doc """
  Returns the list of decimal formats in the 
  CLDR repository.
  
  Example:
  
      iex(1)> Cldr.Number.Format.decimal_format_list
      ["#,##0.00¤", "#,##0%", "#E0", "#,##0.###",
      "#,##0.00 ¤;(#,##0.00 ¤)", "#,##0.00 ¤", "#,##0 %",
      "¤#,##0.00;¤-#,##0.00", "#", "¤ #,##0.00",
      "¤#,##0.00;(¤#,##0.00)", "¤#,##0.00", "¤ #0.00", "#0%",
      "0.000000E+000", "#0.######", "¤ #,##,##0.00", "#,##,##0%",
      "#,##,##0.###", "¤ #,##0.00;(¤ #,##0.00)",
      "¤ #,##0.00;¤ -#,##0.00", "#0.00 ¤",
      "¤ #,##0.00;¤-#,##0.00", "‎¤#,##0.00;‎(¤#,##0.00)",
      "‎¤#,##0.00", "¤#,##,##0.00;(¤#,##,##0.00)", "¤#,##,##0.00",
      "[#E0]", "#,##,##0.00¤;(#,##,##0.00¤)", "#,##,##0.00¤",
      "#,##,##0 %", "¤#,##0.00;¤- #,##0.00", "%#,##0",
      "¤ #,##0.00;¤ #,##0.00-", "% #,##0", "#,##0.00¤;(#,##0.00¤)"]
  """
  @spec decimal_format_list :: [format]
  def decimal_format_list do
    @decimal_format_list
  end

  @doc """
  The decimal formats defined for a given locale or
  for a given locale and number system.
  
  Examples:
  
      iex(2)> Cldr.Number.Format.decimal_formats_for "en"
      %{latn: %{accounting: "¤#,##0.00;(¤#,##0.00)", currency: "¤#,##0.00",
      percent: "#,##0%", scientific: "#E0", standard: "#,##0.###"}}
      
      iex(1)> Cldr.Number.Format.decimal_formats_for "th"
      %{latn: %{accounting: "¤#,##0.00;(¤#,##0.00)", currency: "¤#,##0.00",
      percent: "#,##0%", scientific: "#E0", standard: "#,##0.###"},
      thai: %{accounting: "¤#,##0.00;(¤#,##0.00)", currency: "¤#,##0.00",
      percent: "#,##0%", scientific: "#E0", standard: "#,##0.###"}}
      
      iex(2)> Cldr.Number.Format.decimal_formats_for "th", :thai
      %{accounting: "¤#,##0.00;(¤#,##0.00)", currency: "¤#,##0.00",
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