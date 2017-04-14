# Elixir Cldr
![Build Status](http://sweatbox.noexpectations.com.au:8080/buildStatus/icon?job=cldr) ![Deps Status](https://beta.hexfaktor.org/badge/all/github/kipcole9/cldr.svg)

## Getting Started

`Cldr` is an Elixir library for the [Unicode Consortium's](http://unicode.org) [Common Locale Data Repository (CLDR)](http://cldr.unicode.org).  The intentions of CLDR, and this library, it to simplify the locale specific formatting of numbers, lists, currencies, calendars, units of measure and dates/times.  As of March 2017 and Version 0.1.0, `Cldr` is based upon [CLDR version 31.0.0](http://cldr.unicode.org).

## Installation

Add `ex_cldr` as a dependency to your `mix` project:

    defp deps do
      [
        {:ex_cldr, "~> 0.1.3"}
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

* If installed from github then all 516 locales are installed when the repo is cloned into your application deps.

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

The `Cldr.Unit` module provides unit localization.  The public API for unit localization is `Cldr.Unit.to_string/3`.  Some examples:

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

## Formatting Dates, Times

Not currently supported, but they're next on the development priority list.

* Dates/times on track to ship in March 2017 (delayed from an original January plan).

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
* The locales known to `Cldr` can be retrieved by `Cldr.known_locales/0` to get the locales known to this configuration of `Cldr` and `Cldr.all_locales/0` to get the locales available in the CLDR data repository.

## Testing

Tests cover the full 516 locales defined in CLDR. Since `Cldr` attempts to maximumize the work done at compile time in order to minimize runtime execution, the compilation phase for tests is several minutes.

Tests are run on Elixir 1.3.4 and 1.4.2.

**Note that on 1.3 it is possible that `ExUnit` will timeout loading the tests.**  There is a fixed limit of 60 seconds to load tests which, for 516 locales, may not be enough.  This timeout is configurable on Elixir 1.4. You can configure it in `config.exs` (or `test.exs`) as follows:

    config :ex_unit,
      case_load_timeout: 120_000,
      timeout: 120_000

### Updating the CDLR data repository if installing from Github

The CLDR data is maintained in JSON format by the Unicode Consortium on github at https://github.com/unicode-cldr/cldr-json  The appropriate content is maintained as submodules in the `data` directory of this Cldr repository.

To update the CDLR data, `git pull` each of the submodules.  For example:

    git submodule -q foreach git pull -q origin master

After updating the respository, the locales need to be consolidated into the format used by Cldr.  This is done by:

    mix cldr.consolidate
