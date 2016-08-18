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
  alias Cldr.Number.Format.Compiler
  
  @type format_type :: :standard | :short | :long | :percent | :accounting | :scientific

  @default_options [as:            :standard,
                    locale:        Cldr.default_locale(),
                    number_system: :default, 
                    currency:      nil, 
                    rounding:      :half_even, 
                    precision:     Cldr.Number.Math.default_rounding()]
  
  @spec to_string(number, [Keyword.t]) :: String.t
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
  
  # Compile the known decimal formats extracted from the 
  # current configuration of Cldr.  This avoids having to tokenize
  # parse and analyse the format on each invokation.  There
  # are around 74 Cldr defined decimal formats so this isn't
  # to burdensome on the compiler of the BEAM.
  #
  # TODO:  Is it worth precompiling even further using "en"
  # locale?
  Enum.each Cldr.Number.Format.decimal_format_list(), fn format ->
    meta = Compiler.decode(format)
    defp to_string(number, unquote(format), options) do
      do_to_string(number, unquote(Macro.escape(meta)), options)
    end
  end
  
  # For formats not predefined we need to compile first
  # and then process
  defp to_string(number, format, options) do
    meta = Compiler.decode(format)
    do_to_string(number, meta, options)
  end
  
  # Now we have the number to be formatted, the meta data that 
  # defines the formatting and the options to be applied 
  # (which is related to localisation of the final format)
  defp do_to_string(_number, _meta, _options) do
    
  end

  # us the `number_system` as a key to retrieve the format.  If you look
  # at `Cldr.Number.System.number_systems_for("en") as an example you'll see a map
  # of number systems keyed by a `type`.  This is a good abstract way to get to the
  # formats when you're not interested in the details of a particular number system.
  defp format_from(locale, number_system) when is_atom(number_system) do
    system = System.number_systems_for(locale)[number_system].name |> String.to_existing_atom
    Format.decimal_formats_for(locale)[system]
  end
  
  # ...If however you already know the number system you want, then just specify
  # it as a `String` for the `number_system` and it'll be directly retrieved.
  defp format_from(locale, number_system) when is_binary(number_system) do
    system = String.to_existing_atom(number_system)
    Format.decimal_formats_for(locale)[system]
  end
  
  # Merge options and default options with supplied options always
  # the winner.
  defp normalize_options(options, defaults) do
    Keyword.merge defaults, options, fn _k, _v1, v2 -> v2 end
  end
  
end 