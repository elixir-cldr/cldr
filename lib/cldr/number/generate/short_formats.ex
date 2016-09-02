defmodule Cldr.Number.Generate.ShortFormats do
  @moduledoc """
  Generates a set of functions to process the various
  :short and :long formats for numbers.
  """

  alias Cldr.Number.{System, Format}

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
  def def_do_to_string do
    for locale  <- Cldr.known_locales(),
        number_system <- System.number_system_names_for(locale),
        style   <- Format.short_format_styles_for(locale, number_system)
    do
      formats = Format.formats_for(locale, number_system) |> Map.get(style)
      quote do
        @spec do_to_short_string(number, atom, Locale.t, binary, Keyword.t) :: List.t
        def do_to_short_string(number, unquote(style), unquote(locale), unquote(number_system), options) do
          unquote(formats)
        end
      end
    end
  end
end
