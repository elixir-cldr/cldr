defmodule Cldr.Number.Generate.ShortFormats do
  @moduledoc """
  Generates a set of functions to process the various
  :short and :long formats for numbers.
  """

  @docp """
  To format a number N, the greatest type less than or equal to N is
  used, with the appropriate plural category. N is divided by the type, after
  removing the number of zeros in the pattern, less 1. APIs supporting this
  format should provide control over the number of significant or fraction
  digits.

  If the value is precisely 0, or if the type is less than 1000, then the
  normal number format pattern for that sort of object is supplied. For
  example, formatting 1200 would result in “$1.2K”, while 990 would result in
  simply “$990”.

  Thus N=12345 matches <pattern type="10000" count="other">00 K</pattern> . N
  is divided by 1000 (obtained from 10000 after removing "00" and restoring one
  "0". The result is formatted according to the normal decimal pattern. With no
  fractional digits, that yields "12 K".
  """

  alias Cldr.Number.{System, Format}
  alias __MODULE__

  defmacro __using__(_options \\ []) do
    def_to_string() ++ def_do_to_string()
  end

  @docp """
  Generates one function for each type of short format (currently there
  are three defined:  :decimal_short, :decimal_long, :currency_short).
  The function signature matches that of the other `to_string/3` functions
  defined in Cldr.Number.  However these functions retain a format as an
  atom which means these short forms will dispatch to the functions defined
  below.  This lets us preserve the internal api which is
  `to_string(number, format, options)` but branch to the specific functions
  that then decompose each of the different short formats.
  """
  defp def_to_string do
    for style <- Format.short_format_styles() do
      quote do
        defp to_string(number, unquote(style), options) do
          locale = options[:locale]

          number_system = options[:number_system]
          |> System.system_name_from(locale)

          number
          |> do_to_short_string(unquote(style), locale, number_system, options)
        end
      end
    end
  end

  @docp """
  Generates one function for the cartesian product of local, number_system,
  style and format.  Thats about 2 * 3 * 10 functions per locale.  There are
  511 locales in total used in testing which so far means compilation never
  ends.  In development (7 locales) and most production environments (< 30
  locales) this would not appear to be an issue.  But a better solution is
  required.
  """
  defp def_do_to_string do
    for locale  <- Cldr.known_locales(),
        number_system <- System.number_system_names_for(locale),
        style   <- Format.short_format_styles_for(locale, number_system)
    do
      formats = Format.formats_for(locale, number_system) |> Map.get(style)
      quote do
        @spec do_to_short_string(number, atom, Locale.t, binary, Keyword.t) :: List.t
        def do_to_short_string(number, unquote(style), unquote(locale), unquote(number_system), options) do
          format = ShortFormats.choose_format(number, unquote(formats), options)
          number = ShortFormats.normalise_number(number, format)
          to_string(number, elem(format,1), options)
        end
      end
    end
  end

  @doc false
  def choose_format(number, _rules, options) when is_number(number) and number < 1000 do
    format = options[:locale]
    |> Format.formats_for(options[:number_system])
    |> Map.get(:standard)
    {number, format}
  end

  @doc false
  def choose_format(number, rules, _options) when is_number(number) do
    {range, rule} = rules
    |> Enum.filter(fn {range, _rules} -> range <= number end)
    |> Enum.reverse
    |> hd

    mod = number
    |> trunc
    |> rem(range)

    plural = Cldr.Number.Cardinal.plural_rule(mod)
    {range, rule[plural] || rule[:other]}
  end

  def choose_format(%Decimal{} = number, rules, options) do
    number
    |> Decimal.round(0, :floor)
    |> Decimal.to_integer
    |> choose_format(rules, options)
  end

  @doc false
  @one_thousand Decimal.new(1000)
  def normalise_number(%Decimal{} = number, {range, format}) do
    if Decimal.cmp(number, @one_thousand) == :lt do
      number
    else
      Decimal.div(number, Decimal.new(adjustment(range, format)))
    end
  end

  def normalise_number(number, _format) when number < 1000 do
    number
  end

  def normalise_number(number, {range, format}) do
    number / adjustment(range, format)
  end

  @doc false
  # TODO: We can precompute these at compile time which would
  # save this lookup
  @zeros Regex.compile!("(?<zeros>0+)")
  def adjustment(range, format) do
    count = Regex.named_captures(@zeros, format)["zeros"] |> String.length
    range / :math.pow(10, count - 1)
  end
end
