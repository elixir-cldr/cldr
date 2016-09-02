defmodule Cldr.Number.Generate.ShortFormats do
  @moduledoc """
  Generates a set of functions to process the various
  :short and :long formats for numbers.
  """

  alias Cldr.Number.{System, Format}

  defmacro __using__(_options \\ []) do
    def_to_string() ++ def_do_to_string()
  end

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

  def def_do_to_string do
    for locale  <- Cldr.known_locales(),
        number_system <- System.number_system_names_for(locale),
        style   <- Format.short_format_styles_for(locale, number_system),
        format  <- Format.formats_for(locale, number_system) |> Map.get(style)
    do
      range = String.to_integer(elem(format, 0))
      quote do
        def do_to_short_string(number, unquote(style), unquote(locale), unquote(number_system), options)
        when number <= unquote(range) do
          IO.puts "do_to_string for range #{inspect unquote(range)}"
        end
      end
    end
  end
end
