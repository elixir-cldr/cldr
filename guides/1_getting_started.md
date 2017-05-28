# Getting Started

`Cldr` is an Elixir library for the [Unicode Consortium's](http://unicode.org) [Common Locale Data Repository (CLDR)](http://cldr.unicode.org).  The intentions of CLDR, and this library, it to simplify the locale specific formatting of numbers, lists, currencies, calendars, units of measure and dates/times.  As of April 2017 and Version 0.1.0, `Cldr` is based upon [CLDR version 31.0.1](http://cldr.unicode.org).

## Installation

Add `ex_cldr` as a dependency to your `mix` project:

    defp deps do
      [
        {:ex_cldr, "~> 0.4.0"}
      ]
    end

then retrieve `ex_cldr` from [hex](https://hex.pm/packages/ex_cldr):

    mix deps.get
    mix deps.compile

Although `Cldr` is purely a library application, it should be added to your application list so that it gets bundled correctly for release.  This applies for Elixir versions up to 1.3.x; version 1.4 will automatically do this for you.

    def application do
      [applications: [:ex_cldr]]
    end

## Quick Configuration

Without any specific configuration Cldr will support the "en" locale only.  To support additional locales update your `config.exs` file (or the relevant environment version).

    config :ex_cldr,
      default_locale: "en",
      locales: ["fr-*", "pt-BR", "en", "pl", "ru", "th", "he"],
      gettext: MyApp.Gettext

Configures a default locale of "en" (which is itself the `Cldr` default).  Additional locales are configured with the `:locales` key.  In this example, all locales starting with "fr-" will be configured along with Brazilian Portugues, English, Polish, Russian, Thai and Hebrew.

### Recompiling after a configuration change

Note that Elixir can't determine dependencies based upon configuration so when you make changes to your `Cldr` configuration a forced recompilation is required in order for the changes to take affect.  To recompile:

    iex> mix deps.compile ex_cldr --force

`Cldr` pre-computes a lot of the CLDR specification and compiles them into functions to provide better runtime performance.  Needing to recompile the dependency after a configuration change comes as a result of that.

## Downloading Configured Locales

`Cldr` can be installed from either [github](https://github.com/kipcole9/cldr)
or from [hex](https://hex.pm/packages/ex_cldr).

* If installed from github then all 514 locales are installed when the repo is cloned into your application deps.

* If installed from hex then only the locales "en" and "root" are installed.  When you configure additional locales these will be downloaded during application compilation.  Please note above the requirement for a force recompilation in this situation.

## Localizing & Formatting Numbers

The `Cldr.Number` module provides number formatting.  The public API for number formatting is `Cldr.Number.to_string/2`.  Some examples:

    iex> Cldr.Number.to_string 12345
    "12,345"

    iex> Cldr.Number.to_string 12345, locale: "fr"
    "12 345"

    iex> Cldr.Number.to_string 12345, locale: "fr", currency: "USD"
    "12 345,00 $US"

    iex(4)> Cldr.Number.to_string 12345, format: "#E0"
    "1.2345E4"

    iex(> Cldr.Number.to_string 1234, format: :roman
    "MCCXXXIV"

    iex> Cldr.Number.to_string 1234, format: :ordinal
    "1,234th"

    iex> Cldr.Number.to_string 1234, format: :spellout
    "one thousand two hundred thirty-four"

See `h Cldr.Number` and `h Cldr.Number.to_string` in `iex` for further information.

## Localizing Lists

The `Cldr.List` module provides list formatting.  The public API for list formating is `Cldr.List.to_string/2`.  Some examples:

    iex> Cldr.List.to_string(["a", "b", "c"], locale: "en")
    "a, b, and c"

    iex> Cldr.List.to_string(["a", "b", "c"], locale: "en", format: :unit_narrow)
    "a b c"

    iex> Cldr.List.to_string(["a", "b", "c"], locale: "fr")
    "a, b et c"

Seer `h Cldr.List` and `h Cldr.List.to_string` in `iex` for further information.

## Localizing Units

The `Cldr.Unit` module provides unit formatting.  The public API for unit formating is `Cldr.Unit.to_string/3`.  Some examples:

      iex> Cldr.Unit.to_string 123, :volume_gallon
      "123 gallons"

      iex> Cldr.Unit.to_string 1234, :volume_gallon, format: :long
      "1 thousand gallons"

      iex> Cldr.Unit.to_string 1234, :volume_gallon, format: :short
      "1K gallons"

      iex> Cldr.Unit.to_string 1234, :frequency_megahertz
      "1,234 megahertz"

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

See `h Cldr.Unit` and `h Cldr.Unit.to_string` in `iex` for further information.

## Localizing Dates, DateTimes

As of version 0.2.0, formatting of relative dates and date times is supported with the `Cldr.Date.Relative` module.  The public API is `Cldr.Date.Relative.to_string/2`.  Some examples:

      iex> Cldr.Date.Relative.to_string(-1)
      "1 second ago"

      iex> Cldr.Date.Relative.to_string(1)
      "in 1 second"

      iex> Cldr.Date.Relative.to_string(1, unit: :day)
      "tomorrow"

      iex> Cldr.Date.Relative.to_string(1, unit: :day, locale: "fr")
      "demain"

      iex> Cldr.Date.Relative.to_string(1, unit: :day, format: :narrow)
      "tomorrow"

      iex> Cldr.Date.Relative.to_string(1234, unit: :year)
      "in 1,234 years"

      iex> Cldr.Date.Relative.to_string(1234, unit: :year, locale: "fr")
      "dans 1 234 ans"

      iex> Cldr.Date.Relative.to_string(31)
      "in 31 seconds"

      iex> Cldr.Date.Relative.to_string(~D[2017-04-29], relative_to: ~D[2017-04-26])
      "in 3 days"

      iex> Cldr.Date.Relative.to_string(310, format: :short, locale: "fr")
      "dans 5 min"

      iex> Cldr.Date.Relative.to_string(310, format: :narrow, locale: "fr")
      "+5 min"

      iex> Cldr.Date.Relative.to_string 2, unit: :wed, format: :short
      "in 2 Wed."

      iex> Cldr.Date.Relative.to_string 1, unit: :wed, format: :short
      "next Wed."

      iex> Cldr.Date.Relative.to_string -1, unit: :wed, format: :short
      "last Wed."

      iex> Cldr.Date.Relative.to_string -1, unit: :wed
      "last Wednesday"

      iex> Cldr.Date.Relative.to_string -1, unit: :quarter
      "last quarter"

      iex> Cldr.Date.Relative.to_string -1, unit: :mon, locale: "fr"
      "lundi dernier"

      iex> Cldr.Date.Relative.to_string(~D[2017-04-29], unit: :ziggeraut)
      {:error,
       "Unknown time unit :ziggeraut.  Valid time units are [:day, :hour, :minute, :month, :second, :week, :year, :mon, :tue, :wed, :thu, :fri, :sat, :sun, :quarter]"}

## Gettext Integration

There is an experimental plurals module for Gettext called `Cldr.Gettext.Plural`.  **Its not yet fully tested**. It is configured in `Gettext` by:

    defmodule MyApp.Gettext do
      use Gettext, plural_forms: Cldr.Gettext.Plural
    end

`Cldr.Gettext.Plural` will fall back to `Gettext` pluralisation if the locale is not known to `Cldr`.  This module is only compiled if `Gettext` is configured as a dependency in your project.

## Phoenix Integration

There is an imcomplete (ie development not finished) implemenation of a `Plug` intended to parse the HTTP `accept-language` header into `Cldr` compatible locale and number system.  Since it's not development complete it definitely won't work yet.  Comments and ideas (and pull requests) are, however, welcome.

## About Locale strings

Note that `Cldr` defines locale string according to the Unicode standard:

* Language codes are two lowercase letters (ie "en", not "EN")
* Potentially one or more modifiers separated by "-" (dash), not a "\_". (underscore).  If you configure a `Gettext` module then `Cldr` will transliterate `Gettext`'s "\_" into "-" for compatibility.
* Typically the modifier is a territory code.  This is commonly a two-letter uppercase combination.  For example "pt-BR" is the locale referring to Brazilian Portugese.
* In `Cldr` a locale is always a `binary` and never an `atom`.  Locale strings are often passed around in HTTP headers and converting to atoms creates an attack vector we can do without.
* The locales known to `Cldr` can be retrieved by `Cldr.known_locales` to get the locales known to this configuration of `Cldr` and `Cldr.all_locales` to get the locales available in the CLDR data repository.

## Testing

Tests cover the full 514 locales defined in CLDR. Since `Cldr` attempts to maximumize the work done at compile time in order to minimize runtime execution, the compilation phase for tests is several minutes.

Tests are run on Elixir 1.4.x.  Elixir below 1.4 is not supported.
