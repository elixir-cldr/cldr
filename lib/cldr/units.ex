defmodule Cldr.Unit do
  @moduledoc """
  Supports the CLDR Units definitions which provide for the localization of many
  unit types.

  The public API defines two primary functions:

  * `Cldr.Unit.to_string/3` which, given a number and a unit name will output a localized string

  * `Cldr.Unit.available_units/0` identifies the available units for localization
  """

  require Cldr
  alias Cldr.Substitution

  @unit_styles [:long, :short, :narrow]
  @default_style :long

  @doc """
  Formats a number into a string according to a unit definition for a locale.

  * `number` is any number (integer, float or Decimal)

  * `unit` is any unit returned by `Cldr.Unit.available_units/0`

  * `options` are:

    * `locale` is any configured locale. See `Cldr.known_locales()`. The default
    is `locale: Cldr.get_currenct_locale()`

    * `style` is one of those returned by `Cldr.Unit.available_styles`.
    THe current styles are `:long`, `:short` and `:narrow`.  The default is `style: :long`

    * Any other options are passed to `Cldr.Number.to_string/2` which is used to format the `number`

  ## Examples

      iex> Cldr.Unit.to_string 123, :volume_gallon
      "123 gallons"

      iex> Cldr.Unit.to_string 1, :volume_gallon
      "1 gallon"

      iex> Cldr.Unit.to_string 1, :volume_gallon, locale: "af"
      "1 gelling"

      iex> Cldr.Unit.to_string 1, :volume_gallon, locale: "af-NA"
      "1 gelling"

      iex> Cldr.Unit.to_string 1, :volume_gallon, locale: "bs"
      "1 galona"

      iex> Cldr.Unit.to_string 1234, :volume_gallon, format: :long
      "1 thousand gallons"

      iex> Cldr.Unit.to_string 1234, :volume_gallon, format: :short
      "1K gallons"

      iex> Cldr.Unit.to_string 1234, :frequency_megahertz
      "1,234 megahertz"

      iex> Cldr.Unit.to_string 1234, :frequency_megahertz, style: :narrow
      "1,234MHz"

      Cldr.Unit.to_string 123, :digital_megabyte, locale: "en-XX"
      {:error, {Cldr.UnknownLocaleError, "The locale \"en-XX\" is not known."}}

      Cldr.Unit.to_string 123, :digital_megabyte, locale: "en", style: :unknown
      {:error, {Cldr.UnknownFormatError, "The unit style :unknown is not known."}}
  """
  @spec to_string(Cldr.Math.number_or_decimal, atom, Keyword.t) :: String.t | {:error, {atom, binary}}
  def to_string(number, unit, options \\ []) do
    case normalize_options(options) do
      {:error, {_exception, _message}} = error ->
        error
      {locale, style, options} ->
        case result = to_string(number, unit, locale, style, options) do
          {:error, _} -> result
          _           -> :erlang.iolist_to_binary(result)
        end
    end
  end

  @doc """
  Formats a list using `to_string/3` but raises if there is
  an error.
  """
  @spec to_string!(List.t, atom, Keyword.t) :: String.t | Exception.t
  def to_string!(number, unit, options \\ []) do
    case string = to_string(number, unit, options) do
      {:error, {exception, message}} ->
        raise exception, message
      _ ->
        string
    end
  end

  defp to_string(number, unit, locale, style, options) do
    number_string = Cldr.Number.to_string(number, options ++ [locale: locale])
    if patterns = pattern_for(locale, style, unit) do
      pattern = Cldr.Number.Ordinal.pluralize(number, locale, patterns)
      Substitution.substitute([number_string], pattern)
    else
      verify_unit(locale, style, unit)
    end
  end

  @doc """
  Returns the available units for a given locale and style.

  * `locale` is any configured locale. See `Cldr.known_locales()`. The default
    is `locale: Cldr.get_current_locale()`

  * `style` is one of those returned by `Cldr.Unit.available_styles`.
    The current styles are `:long`, `:short` and `:narrow`.  The default is `style: :long`

  ## Example

      Cldr.Unit.available_units
      [:acceleration_g_force, :acceleration_meter_per_second_squared,
       :angle_arc_minute, :angle_arc_second, :angle_degree, :angle_radian,
       :angle_revolution, :area_acre, :area_hectare, :area_square_centimeter,
       :area_square_foot, :area_square_inch, :area_square_kilometer,
       :area_square_meter, :area_square_mile, :area_square_yard, :concentr_karat,
       :concentr_milligram_per_deciliter, :concentr_millimole_per_liter,
       :concentr_part_per_million, :consumption_liter_per_100kilometers,
       :consumption_liter_per_kilometer, :consumption_mile_per_gallon,
       :consumption_mile_per_gallon_imperial, :coordinate_unit, :digital_bit,
       :digital_byte, :digital_gigabit, :digital_gigabyte, :digital_kilobit,
       :digital_kilobyte, :digital_megabit, :digital_megabyte, :digital_terabit,
       :digital_terabyte, :duration_century, :duration_day, :duration_hour,
       :duration_microsecond, :duration_millisecond, :duration_minute,
       :duration_month, :duration_nanosecond, :duration_second, :duration_week,
       :duration_year, :electric_ampere, :electric_milliampere, :electric_ohm,
       :electric_volt, ...]
  """
  def available_units(locale \\ Cldr.get_current_locale(), style \\ @default_style)

  defp pattern_for(locale \\ Cldr.get_current_locale(), style \\ @default_style, unit)

  # Generate the functions that encapsulate the unit data from CDLR
  for locale <- Cldr.Config.known_locales() do
    locale_data =
      locale
      |> Cldr.Config.get_locale
      |> Map.get(:units)

    for style <- @unit_styles do
      units = Map.get(locale_data, style)

      def available_units(unquote(locale), unquote(style)) do
        unquote(Map.keys(units) |> Enum.sort)
      end

      defp pattern_for(unquote(locale), unquote(style), unit) do
        unquote(Macro.escape(units))
        |> Map.get(unit)
      end
    end
  end


  @doc """
  Returns the available styles for a unit localiation.

  ## Example

      iex> Cldr.Unit.available_styles
      [:long, :short, :narrow]
  """
  def available_styles do
    @unit_styles
  end

  @doc false
  def unit_error(unit) do
    {Cldr.UnknownUnitError, "The unit #{inspect unit} is not known."}
  end

  def style_error(style) do
    {Cldr.UnknownFormatError, "The unit style #{inspect style} is not known."}
  end


  defp normalize_options(options) do
    locale = options[:locale] || Cldr.get_current_locale()
    style = options[:style] || @default_style
    options = Keyword.delete(options, :locale) |> Keyword.delete(:style)

    with {:ok, _} <- Cldr.valid_locale?(locale),
         :ok <- verify_style(style)
    do
      {locale, style, options}
    else
      {:error, _} = error -> error
    end
  end

  defp verify_unit(locale, style, unit) do
    if !pattern_for(locale, style, unit) do
      {:error, unit_error(unit)}
    else
      :ok
    end
  end

  defp verify_style(style) do
    if !(style in @unit_styles) do
      {:error, style_error(style)}
    else
      :ok
    end
  end

end
