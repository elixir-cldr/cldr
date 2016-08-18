# http://icu-project.org/apiref/icu4c/classRuleBasedNumberFormat.html
defmodule Cldr.Number do
  @moduledoc """
  ## Cldr formatting for numbers.
  
  Formatting is guided by several parameters, all of which can be specified either using a 
  pattern. The following description applies to formats that do not use scientific notation 
  or significant digits.

  * If the number of actual integer digits exceeds the maximum integer digits, then only 
  the least significant digits are shown. For example, 1997 is formatted as "97" if the 
  maximum integer digits is set to 2.
  
  * If the number of actual integer digits is less than the minimum integer digits, then 
  leading zeros are added. For example, 1997 is formatted as "01997" if the minimum integer 
  digits is set to 5.
  
  * If the number of actual fraction digits exceeds the maximum fraction digits, then 
  half-even rounding it performed to the maximum fraction digits. For example, 0.125 is 
  formatted as "0.12" if the maximum fraction digits is 2. This behavior can be changed 
  by specifying a rounding increment and a rounding mode.
  
  * If the number of actual fraction digits is less than the minimum fraction digits, 
  then trailing zeros are added. For example, 0.125 is formatted as "0.1250" if the minimum 
  fraction digits is set to 4.
  
  * Trailing fractional zeros are not displayed if they occur j positions after the decimal, 
  where j is less than the maximum fraction digits. For example, 0.10004 is formatted as 
  "0.1" if the maximum fraction digits is four or less.
  """

  alias Cldr.Number.System
  alias Cldr.Number.Format
  
  @type format :: :standard | :short | :long | :percent | :accounting | :scientific
  
  @spec to_string(number, [Keyword.t]) :: String.t
  
  @default_options [as:            :standard,
                    locale:        Cldr.default_locale(),
                    number_system: :default, 
                    currency:      nil, 
                    rounding:      :half_even, 
                    precision:     Cldr.Number.Math.default_rounding()]
  
  def to_string(number, options) do
    options = normalize_options(options, @default_options)
    if options[:format] do
      options = options |> Keyword.delete(:as)
      format = options[:format]
      to_string(number, format, options)
    else
      options = options |> Keyword.delete(:format)
      format = format_from(options[:locale], options[:number_system]) |> Map.get(options[:as])
      to_string(number, format, options)
    end
  end
  
  defp to_string(_number, _format, _options) do
    
  end

  defp format_from(locale, number_system) when is_atom(number_system) do
    system = System.number_systems_for(locale)[number_system].name |> String.to_existing_atom
    Format.decimal_formats_for(locale)[system]
  end
  defp format_from(locale, number_system) when is_binary(number_system) do
    system = String.to_existing_atom(number_system)
    Format.decimal_formats_for(locale)[system]
  end
  
  defp normalize_options(options, defaults) do
    Keyword.merge defaults, options, fn _k, _v1, v2 -> v2 end
  end
  
end 