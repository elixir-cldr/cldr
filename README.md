# Elixir Cldr
![Build Status](http://sweatbox.noexpectations.com.au:8080/buildStatus/icon?job=cldr) ![Deps Status](https://beta.hexfaktor.org/badge/all/github/kipcole9/cldr.svg)

## Getting Started

`Cldr` is an Elixir library for the [Unicode Consortium's](http://unicode.org) [Common Locale Data Repository (CLDR)](http://cldr.unicode.org).  The intentions of CLDR, and this library, it to simplify the locale specific formatting of numbers, lists, currencies, calendars, units of measure and dates/times.  As of August 2016, `Cldr` is based upon [CLDR version 29](http://cldr.unicode.org). Version 30 of CLDR is expected to be released in the third week of September (as is usual each year) and this library will be updated with that CLDR version's data before the end of September.

## Installation

Add `cldr` as a dependency to your `mix` project:

    defp deps do
      [
        {:ex_cldr, "~> 0.0.7"}
      ]
    end

then retrieve `ex_cldr` from [hex](https://hex.pm/packages/ex_cldr):

    mix deps.get
    mix deps.compile

Although `Cldr` is purely a library application, it should be added to your application list so that it gets bundled correctly for release:

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

## Downloading Configured Locales

`Cldr` can be installed from either [github](https://github.com/kipcole9/cldr)
or from [hex](https://hex.pm/packages/ex_cldr).

* If installed from github then all 511 locales are installed when the repo is cloned into your application deps.

* If installed from hex then only a single locale, "en", is installed.  When you configure additional locales these will be downloaded during application compilation.

If you add additional locales to your configuration if may be necessary to force recompile of `Cldr` for these locales to be recognised. This can be done by:

    mix deps.compile ex_cldr --force

## Formatting Numbers

The `Cldr.Number` module provides number formatting.  The public API for number formatting is `Cldr.Number.to_string/2`.  Some examples:

      iex> Cldr.Number.to_string 12345
      "12,345"

      iex> Cldr.Number.to_string 12345, locale: "fr"
      "12 345"

      iex> Cldr.Number.to_string 12345, locale: "fr", currency: "USD"
      "12 345,00 $US"

      iex(4)> Cldr.Number.to_string 12345, format: "#E0"
      "1.2345E4"

See `h Cldr.Number` and `h Cldr.Number.to_string` in `iex` for further information.

## Formatting Lists

The `Cldr.List` module provides list formatting.  The public API for list formating is `Cldr.List.to_string/2`.  Some examples:

      iex> Cldr.List.to_string(["a", "b", "c"], locale: "en")
      "a, b, and c"

      iex> Cldr.List.to_string(["a", "b", "c"], locale: "en", format: :unit_narrow)
      "a b c"

      iex> Cldr.List.to_string(["a", "b", "c"], locale: "fr")
      "a, b et c"

Seer `h Cldr.List` and `h Cldr.List.to_string` in `iex` for further information.

## Formatting Dates, Times, Units and Other Stuff

Not currently supported, but they're next on the development priority list.

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
* Potentially one or more modifiers separated by "-" (dash), not a "_" (underscore).  If you configure a `Gettext` module then `Cldr` will transliterate `Gettext`'s "_" into "-" for compatibility.
* Typically the modifier is a territory code.  This is commonly a two-letter uppercase combination.  For example "pt-BR" is the locale referring to Brazilian Portugese.
* In `Cldr` a locale is always a `binary` and never an `atom`.  Locale strings are often passed around in HTTP headers and converting to atoms creates an attack vector we can do without.
* The locales known to `Cldr` can be retrieved by `Cldr.known_locales` to get the locales known to this configuration of `Cldr` and `Cldr.all_locales` to get the locales available in the CLDR data repository.

## Testing

Tests cover the full 511 locales defined in CLDR. Since `Cldr` attempts to maximumize the work done at compile time in order to minimize runtime execution, the compilation phase for tests is several minutes.

Tests are run on Elixir 1.3.2 and on master (currently 1.4.0-dev).

**Note that on 1.3.2 it is possible that `ExUnit` will timeout loading the tests.**  There is a fixed limit of 60 seconds load tests which, for 511 locales, may not be enough.  This timeout is configurable on Elixir 1.4.0-dev. You can configure it in `config.exs` (or `test.exs`) as follows:

    config :ex_unit,
      case_load_timeout: 120_000