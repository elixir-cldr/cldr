# Unit Localization

The `Cldr.Unit` module provides unit formatting.  The public API for unit formating is `Cldr.Unit.to_string/3`.

## Public API

  Supports the CLDR Units definitions which provide for the localization of many
  unit types.

  The public API defines two primary functions:

  * `Cldr.Unit.to_string/3` which, given a number and a unit name will output a localized string

  * `Cldr.Unit.available_units/0` identifies the available units for localization

## Examples

```elixir
iex> Cldr.Unit.to_string 123, :volume_gallon
{:ok, "123 gallons"}

iex> Cldr.Unit.to_string 1234, :volume_gallon, format: :long
{:ok, "1 thousand gallons"}

iex> Cldr.Unit.to_string 1234, :volume_gallon, format: :short
{:ok, "1K gallons"}

iex> Cldr.Unit.to_string 1234, :frequency_megahertz
{:ok, "1,234 megahertz"}

iex> Cldr.Unit.available_units
[:volume_gallon, :pressure_pound_per_square_inch, :digital_terabyte,
 :digital_bit, :digital_gigabit, :digital_kilobit, :volume_pint,
 :speed_kilometer_per_hour, :concentr_part_per_million, :energy_calorie,
 :volume_milliliter, :length_fathom, :length_foot, :volume_cubic_yard,
 :mass_microgram, :length_nautical_mile, :volume_deciliter,
 :consumption_mile_per_gallon, :volume_bushel, :volume_cubic_centimeter,
 :length_light_year, :volume_gallon_imperial, :speed_meter_per_second,
 :power_kilowatt, :power_watt, :length_millimeter, :digital_gigabyte,
 :duration_nanosecond, :length_centimeter, :volume_cup_metric,
 :length_kilometer, :angle_degree, :acceleration_g_force, :electric_ampere,
 :volume_quart, :duration_century, :angle_revolution, :volume_hectoliter,
 :area_square_meter, :digital_megabyte, :light_lux, :duration_year,
 :energy_kilocalorie, :frequency_megahertz, :power_horsepower,
 :volume_cubic_meter, :area_hectare, :frequency_hertz, :length_furlong,
 :length_astronomical_unit, ...]
```

See `h Cldr.Unit` and `h Cldr.Unit.to_string` in `iex` for further information.

## Localizing Units

The primary public API, `Cldr.Unit.to_string/3`, supports three arguments:

  * `number` is any number (integer, float or Decimal)

  * `unit` is any unit returned by `Cldr.Unit.available_units/0`

  * `options` are:

    * `locale` is any configured locale. See `Cldr.known_locales()`. The default
    is `locale: Cldr.get_locale()`

    * `style` is one of those returned by `Cldr.Unit.available_styles`.
    THe current styles are `:long`, `:short` and `:narrow`.  The default is `style: :long`

    * Any other options are passed to `Cldr.Number.to_string/2` which is used to format the `number`