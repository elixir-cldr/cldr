defmodule Cldr.Number do
  @moduledoc """
  The main public API for the formatting of numbers and currencies.

  Provides the public API for the formatting of numbers based upon
  CLDR's decimal formats specification documentated [Unicode TR35](http://unicode.org/reports/tr35/tr35-numbers.html#Number_Formats)

  ### Non-Scientific Notation Formatting

  The following description applies to formats that do not use scientific
  notation or significant digits:

  * If the number of actual integer digits exceeds the maximum integer digits,
    then only the least significant digits are shown. For example, 1997 is
    formatted as "97" if the maximum integer digits is set to 2.

  * If the number of actual integer digits is less than the minimum integer
    digits, then leading zeros are added. For example, 1997 is formatted as
    "01997" if the minimum integer digits is set to 5.

  * If the number of actual fraction digits exceeds the maximum fraction
    digits, then half-even rounding it performed to the maximum fraction
    digits. For example, 0.125 is formatted as "0.12" if the maximum fraction
    digits is 2. This behavior can be changed by specifying a rounding
    increment and a rounding mode.

  * If the number of actual fraction digits is less than the minimum fraction
    digits, then trailing zeros are added. For example, 0.125 is formatted as
    "0.1250" if the minimum fraction digits is set to 4.

  * Trailing fractional zeros are not displayed if they occur j positions after
    the decimal, where j is less than the maximum fraction digits. For example,
    0.10004 is formatted as "0.1" if the maximum fraction digits is four or
    less.

  ### Scientific Notation Formatting

  Numbers in scientific notation are expressed as the product of a mantissa and
  a power of ten, for example, 1234 can be expressed as 1.234 x 10^3. The
  mantissa is typically in the half-open interval [1.0, 10.0) or sometimes
  [0.0, 1.0), but it need not be. In a pattern, the exponent character
  immediately followed by one or more digit characters indicates scientific
  notation. Example: "0.###E0" formats the number 1234 as "1.234E3".

  * The number of digit characters after the exponent character gives the
    minimum exponent digit count. There is no maximum. Negative exponents are
    formatted using the localized minus sign, not the prefix and suffix from
    the pattern. This allows patterns such as "0.###E0 m/s". To prefix positive
    exponents with a localized plus sign, specify '+' between the exponent and
    the digits: "0.###E+0" will produce formats "1E+1", "1E+0", "1E-1", and so
    on. (In localized patterns, use the localized plus sign rather than '+'.)

  * The minimum number of integer digits is achieved by adjusting the exponent.
    Example: 0.00123 formatted with "00.###E0" yields "12.3E-4". This only
    happens if there is no maximum number of integer digits. If there is a
    maximum, then the minimum number of integer digits is fixed at one.

  * The maximum number of integer digits, if present, specifies the exponent
    grouping. The most common use of this is to generate engineering notation,
    in which the exponent is a multiple of three, for example, "##0.###E0". The
    number 12345 is formatted using "##0.####E0" as "12.345E3".

  * When using scientific notation, the formatter controls the digit counts
    using significant digits logic. The maximum number of significant digits
    limits the total number of integer and fraction digits that will be shown
    in the mantissa; it does not affect parsing. For example, 12345 formatted
    with "##0.##E0" is "12.3E3". Exponential patterns may not contain grouping
    separators.

  ### Significant Digits

  There are two ways of controlling how many digits are shows: (a)
  significant digits counts, or (b) integer and fraction digit counts. Integer
  and fraction digit counts are described above. When a formatter is using
  significant digits counts, it uses however many integer and fraction digits
  are required to display the specified number of significant digits. It may
  ignore min/max integer/fraction digits, or it may use them to the extent
  possible.
  """

  require Cldr
  alias Cldr.Number.Formatter
  alias Cldr.Number.Format.Compiler
  import Cldr.Number.Format, only: [formats_for: 2]

  @type format_type ::
    :standard |
    :decimal_short |
    :decimal_long |
    :currency_short |
    :currency_long |
    :percent |
    :accounting |
    :scientific |
    :currency

  @default_options [
    format:        :standard,
    currency:      nil,
    cash:          false,
    rounding_mode: :half_even,
    number_system: :default,
    locale:        Cldr.get_current_locale()
  ]

  @short_format_styles [
    :currency_short,
    :currency_long,
    :decimal_short,
    :decimal_long
  ]

  @doc """
  Returns a number formatted into a string according to a format pattern and options.

  * `number` is an integer, float or Decimal to be formatted

  * `options` is a keyword list defining how the number is to be formatted. The
    valid options are:

      * `format`: the format style or a format string defining how the number is
        formatted. See `Cldr.Number.Format` for how format strings can be constructed.
        See `Cldr.Number.Format.format_styles_for/1` to return available format styles
        for a locale. The default `format` is `:standard`.

      * If `:format` is set to `:long` or `:short` then the formatting depends on
        whether `:currency` is specified. If not specified then the number is
        formatted as `:decimal_long` or `:decimal_short`. If `:currency` is
        specified the number is formatted as `:currency_long` or
        `:currency_short` and `:fractional_digits` is set to 0 as a default.

      * `:format` may also be a format defined by CLDR's Rules Based Number
        Formats (RBNF).  Further information is found in the module `Cldr.Rbnf`.
        The most commonly used formats in this category are to spell out the
        number in a the locales language.  The applicable formats are `:spellout`,
        `:spellout_year`, `:ordinal`.  A number can also be formatted as roman
        numbers by using the format `:roman` or `:roman_lower`.

      * `currency`: is the currency for which the number is formatted. For
        available currencies see `Cldr.Currency.known_currencies/0`. This option
        is required if `:format` is set to `:currency`.  If `currency` is set
        and no `:format` is set, `:format` will be set to `:currency` as well.

      * `:cash`: a boolean which indicates whether a number being formatted as a
        `:currency` is to be considered a cash value or not. Currencies can be
        rounded differently depending on whether `:cash` is `true` or `false`.

      * `:rounding_mode`: determines how a number is rounded to meet the precision
        of the format requested. The available rounding modes are `:down`,
        :half_up, :half_even, :ceiling, :floor, :half_down, :up. The default is
        `:half_even`.

      * `:number_system`: determines which of the number systems for a locale
        should be used to define the separators and digits for the formatted
        number. If `number_system` is an `atom` then `number_system` is
        interpreted as a number system. See
        `Cldr.Number.System.number_systems_for/1`. If the `:number_system` is
        `binary` then it is interpreted as a number system name. See
        `Cldr.Number.System.number_system_names_for/1`. The default is `:default`.

      * `:locale`: determines the locale in which the number is formatted. See
        `Cldr.known_locales/0`. THe default is `Cldr.get_current_locale/0` which is the
        locale currently in affect for this `Process` and which is set by
        `Cldr.put_locale/1`.

      * `:fractional_digits` is set to a positive integer value then the number
        will be rounded to that number of digits and displayed accordingly overriding
        settings that would be applied by default.  For example, currencies have
        fractional digits defined reflecting each currencies minor unit.  Setting
        `:fractional_digits` will override that setting.

  ## Examples

      iex> Cldr.Number.to_string 12345
      {:ok, "12,345"}

      iex> Cldr.Number.to_string 12345, locale: "fr"
      {:ok, "12 345"}

      iex> Cldr.Number.to_string 12345, locale: "fr", currency: "USD"
      {:ok, "12 345,00 $US"}

      iex> Cldr.Number.to_string 12345, format: "#E0"
      {:ok, "1.2345E4"}

      iex> Cldr.Number.to_string 12345, format: :accounting, currency: "THB"
      {:ok, "THB12,345.00"}

      iex> Cldr.Number.to_string -12345, format: :accounting, currency: "THB"
      {:ok, "(THB12,345.00)"}

      iex> Cldr.Number.to_string 12345, format: :accounting, currency: "THB", locale: "th"
      {:ok, "THB12,345.00"}

      iex> Cldr.Number.to_string 12345, format: :accounting, currency: "THB", locale: "th", number_system: :native
      {:ok, "THB๑๒,๓๔๕.๐๐"}

      iex> Cldr.Number.to_string 1244.30, format: :long
      {:ok, "1 thousand"}

      iex> Cldr.Number.to_string 1244.30, format: :long, currency: "USD"
      {:ok, "1,244 US dollars"}

      iex> Cldr.Number.to_string 1244.30, format: :short
      {:ok, "1K"}

      iex> Cldr.Number.to_string 1244.30, format: :short, currency: "EUR"
      {:ok, "€1K"}

      iex> Cldr.Number.to_string 1234, format: :spellout
      {:ok, "one thousand two hundred thirty-four"}

      iex> Cldr.Number.to_string 1234, format: :spellout_verbose
      {:ok, "one thousand two hundred and thirty-four"}

      iex> Cldr.Number.to_string 1989, format: :spellout_year
      {:ok, "nineteen eighty-nine"}

      iex> Cldr.Number.to_string 123, format: :ordinal
      {:ok, "123rd"}

      iex(4)> Cldr.Number.to_string 123, format: :roman
      {:ok, "CXXIII"}

  ## Errors

  An error tuple `{:error, reason}` will be returned if an error is detected.
  The two most likely causes of an error return are:

    * A format cannot be compiled. In this case the error tuple will look like:

  ```
      iex> Cldr.Number.to_string(12345, format: "0#")
      {:error, {Cldr.FormatCompileError,
        "Decimal format compiler: syntax error before: \\"#\\""}}
  ```

    * A currency was not specific for a format type of `format: :currency` or
      `format: :accounting` or any other format that specifies a currency
      symbol placeholder. In this case the error return looks like:

  ```
      iex> Cldr.Number.to_string(12345, format: :accounting)
      {:error, {Cldr.FormatError, "currency format \\"¤#,##0.00;(¤#,##0.00)\\" requires that " <>
      "options[:currency] be specified"}}
  ```

    * The format style requested is not defined for the `locale` and
      `number_system`. This happens typically when the number system is
      `:algorithmic` rather than the more common `:numeric`. In this case the error
      return looks like:

  ```
      iex> Cldr.Number.to_string(1234, locale: "he", number_system: "hebr")
      {:error, {Cldr.UnknownFormatError,
      "The locale \\"he\\" with number system \\"hebr\\" does not define a format :standard."}}
  ```
  """
  @spec to_string(number, Keyword.t | Map.t) :: {:ok, String.t} | {:error, {atom, String.t}}
  def to_string(number, options \\ @default_options) do
    {format, options} = options
    |> normalize_options(@default_options)
    |> detect_negative_number(number)

    with :ok <- currency_format_has_code(format, currency_format?(format), options[:currency]) do
      case to_string(number, format, options) do
        {:error, reason} -> {:error, reason}
        string -> {:ok, string}
      end
    else
      {:error, _} = error -> error
    end
  end

  @doc """
  Same as the execution of `to_string/2` but raises an exception if an error would be
  returned.

  ## Examples

      iex> Cldr.Number.to_string! 12345
      "12,345"

      iex> Cldr.Number.to_string! 12345, locale: "fr"
      "12 345"
  """
  @spec to_string!(number, Keyword.t | String.t) :: String.t | Exception.t
  def to_string!(number, options \\ @default_options) do
    case to_string(number, options) do
      {:error, {exception, message}} ->
        raise exception, message
      {:ok, string} ->
        string
    end
  end

  # For ordinal numbers
  @format :digits_ordinal
  defp to_string(number, :ordinal, options) do
    if @format in Cldr.Rbnf.Ordinal.rule_sets(options[:locale]) do
      Cldr.Rbnf.Ordinal.digits_ordinal(number, options[:locale])
    else
      {:error, rbnf_error(options[:locale], @format)}
    end
  end

  # For spellout numbers
  @format :spellout_cardinal
  defp to_string(number, :spellout, options) do
    if @format in Cldr.Rbnf.Spellout.rule_sets(options[:locale]) do
      Cldr.Rbnf.Spellout.spellout_cardinal(number, options[:locale])
    else
      {:error, rbnf_error(options[:locale], @format)}
    end
  end

  # For spellout numbers
  defp to_string(number, :spellout_numbering = format, options) do
    if format in Cldr.Rbnf.Spellout.rule_sets(options[:locale]) do
      Cldr.Rbnf.Spellout.spellout_numbering(number, options[:locale])
    else
      {:error, rbnf_error(options[:locale], format)}
    end
  end

  # For spellout numbers
  @format :spellout_cardinal_verbose
  defp to_string(number, :spellout_verbose, options) do
    if @format in Cldr.Rbnf.Spellout.rule_sets(options[:locale]) do
      Cldr.Rbnf.Spellout.spellout_cardinal_verbose(number, options[:locale])
    else
      {:error, rbnf_error(options[:locale], @format)}
    end
  end

  # For spellout years
  @format :spellout_numbering_year
  defp to_string(number, :spellout_year, options) do
    if @format in Cldr.Rbnf.Spellout.rule_sets(options[:locale]) do
      Cldr.Rbnf.Spellout.spellout_numbering_year(number, options[:locale])
    else
      {:error, rbnf_error(options[:locale], @format)}
    end
  end

  # For spellout ordinal
  defp to_string(number, :spellout_ordinal = format, options) do
    if format in Cldr.Rbnf.Spellout.rule_sets(options[:locale]) do
      Cldr.Rbnf.Spellout.spellout_ordinal(number, options[:locale])
    else
      {:error, rbnf_error(options[:locale], format)}
    end
  end

  # For spellout ordinal verbose
  defp to_string(number, :spellout_ordinal_verbose = format, options) do
    if format in Cldr.Rbnf.Spellout.rule_sets(options[:locale]) do
      Cldr.Rbnf.Spellout.spellout_ordinal_verbose(number, options[:locale])
    else
      {:error, rbnf_error(options[:locale], format)}
    end
  end

  # For Roman numerals
  defp to_string(number, :roman, _options) do
    Cldr.Rbnf.NumberSystem.roman_upper(number, "root")
  end

  defp to_string(number, :roman_lower, _options) do
    Cldr.Rbnf.NumberSystem.roman_lower(number, "root")
  end

  # For the :currency_long format only
  defp to_string(number, :currency_long = format, options) do
    Formatter.Currency.to_string(number, format, options)
  end

  # For all other short formats
  defp to_string(number, format, options)
  when is_atom(format) and format in @short_format_styles do
    Formatter.Short.to_string(number, format, options)
  end

  # For all other formats
  defp to_string(number, format, options) when is_binary(format) do
    Formatter.Decimal.to_string(number, format, options)
  end

  # For all other formats.  The known atom-based formats are described
  # above so this must be a format name expected to be defined by a
  # locale but its not there.
  defp to_string(_number, {:error, _} = error, _options) do
    error
  end

  defp to_string(_number, format, options) when is_atom(format)do
    {:error, {Cldr.UnknownFormatError, "The locale #{inspect options[:locale]} with number system " <>
      "#{inspect options[:number_system]} does not define a format " <>
      "#{inspect format}."}}
  end

  @doc """
  Converts a number from the latin digits `0..9` into
  another number system.  Returns `{:ok, sttring}` or
  `{:error, reason}`.

  * `number` is an integer, float.  Decimal is supported only for
  `:numeric` number systems, not `:algorithmic`.  See `Cldr.Number.System.to_system/2`
  for further information.

  * `system` is any number system returned by `Cldr.Number.System.known_number_systems/0`

  ## Examples

      iex> Cldr.Number.to_number_system 123, :hant
      {:ok, "一百二十三"}

      iex> Cldr.Number.to_number_system 123, :hebr
      {:ok, "ק׳"}

  """
  @spec to_number_system(number, atom) :: String.t | {:error, {Exception.t, String.t}}
  def to_number_system(number, system) do
    Cldr.Number.System.to_system(number, system)
  end

  @doc """
  Converts a number from the latin digits `0..9` into
  another number system. Returns the converted number
  or raises an exception on error.

  * `number` is an integer, float.  Decimal is supported only for
  `:numeric` number systems, not `:algorithmic`.  See `Cldr.Number.System.to_system/2`
  for further information.

  * `system` is any number system returned by `Cldr.Number.System.known_number_systems/0`

  ## Example

      iex> Cldr.Number.to_number_system! 123, :hant
      "一百二十三"

  """
  def to_number_system!(number, system) do
    Cldr.Number.System.to_system!(number, system)
  end

  # Merge options and default options with supplied options always
  # the winner.  If :currency is specified then the default :format
  # will be format: currency
  defp normalize_options(options, defaults) do
    options =
      defaults
      |> merge(options, fn _k, _v1, v2 -> v2 end)
      |> adjust_for_currency(options[:currency], options[:format])
      |> resolve_standard_format
      |> adjust_short_forms

    {options[:format], options}
  end

  defp merge(defaults, options, fun) when is_list(options) do
    defaults
    |> Keyword.merge(options, fun)
    |> Cldr.Map.from_keyword
  end

  defp merge(defaults, options, fun) when is_map(options) do
    defaults
    |> Cldr.Map.from_keyword
    |> Map.merge(options, fun)
  end

  defp resolve_standard_format(options) do
    if options[:format] in @short_format_styles do
      options
    else
      Map.put(options, :format, lookup_standard_format(options[:format], options))
    end
  end

  defp adjust_short_forms(options) do
    options
    |> check_options(:short, options[:currency],  :currency_short)
    |> check_options(:long,  options[:currency],  :currency_long)
    |> check_options(:short, !options[:currency], :decimal_short)
    |> check_options(:long,  !options[:currency], :decimal_long)
  end

  defp adjust_for_currency(options, currency, nil) when not is_nil(currency) do
    Map.put(options, :format, :currency)
  end

  defp adjust_for_currency(options, _currency, _format) do
    options
  end

  defp lookup_standard_format(format, options) when is_atom(format) do
    with {:ok, formats} <- formats_for(options[:locale], options[:number_system]) do
      Map.get(formats, options[:format]) || format
    end
  end

  defp lookup_standard_format(format, _options) when is_binary(format) do
    format
  end

  # if the format is :short or :long then we set the full format name
  # based upon whether there is a :currency set in options or not.
  defp check_options(options, format, check, finally) do
    if options[:format] == format && check do
      Map.put(options, :format, finally)
    else
      options
    end
  end

  defp detect_negative_number({format, options}, number)
  when (is_float(number) or is_integer(number)) and number < 0 do
    {format, Map.put(options, :pattern, :negative)}
  end

  defp detect_negative_number({format, options}, %Decimal{sign: sign})
  when sign < 0 do
    {format, Map.put(options, :pattern, :negative)}
  end

  defp detect_negative_number({format, options}, _number) do
    {format, Map.put(options, :pattern, :positive)}
  end

  defp currency_format_has_code(format, true, nil) do
    {:error, {Cldr.FormatError, "currency format #{inspect format} requires that " <>
      "options[:currency] be specified"}}
  end

  defp currency_format_has_code(_format, true, currency) do
    case Cldr.Currency.validate_currency_code(currency) do
      {:error, _} = error -> error
      {:ok, _} -> :ok
    end
  end

  defp currency_format_has_code(_format, _boolean, _currency) do
    :ok
  end

  defp currency_format?(format) when is_atom(format) do
    format == :currency_short
  end

  defp currency_format?(format) when is_binary(format) do
    format && String.contains?(format, Compiler.placeholder(:currency))
  end

  defp currency_format?(_format) do
    false
  end

  defp rbnf_error(locale, format) do
    {Cldr.NoRbnf, "Locale #{inspect locale} does not define an rbnf ruleset #{inspect format}"}
  end
end
