# Getting Started with Cldr
![Build Status](http://sweatbox.noexpectations.com.au:8080/buildStatus/icon?job=cldr)
[![Hex pm](http://img.shields.io/hexpm/v/ex_cldr.svg?style=flat)](https://hex.pm/packages/ex_cldr)
[![License](https://img.shields.io/badge/license-Apache%202-blue.svg)](https://github.com/kipcole9/cldr/blob/master/LICENSE)

## Getting Started

`Cldr` is an Elixir library for the [Unicode Consortium's](http://unicode.org) [Common Locale Data Repository (CLDR)](http://cldr.unicode.org).  The intentions of CLDR, and this library, is to simplify the locale specific formatting of numbers, lists, currencies, calendars, units of measure and dates/times.  As of February 4th and Version 1.4, `Cldr` is based upon [CLDR version 32.0.1](http://cldr.unicode.org/index/downloads/cldr-32).

The functions you are mostly likely to use are in the modules `Cldr` and `Cldr.Locale`.  In particular:

* `Cldr.default_locale/0`
* `Cldr.set_current_locale/1`
* `Cldr.get_current_locale/0`
* `Cldr.known_locale_names/0`
* `Cldr.Locale.new/1`

To access the raw Cldr data for a locale the `Cldr.Config` module is available.  Note that the functions in `Cldr.Config` are typically used by library authors.  The most useful function is:

* `Cldr.Config.get_locale/1` which returns a map of all the CLDR data known to `Cldr`.  Since this data is read from a file, parsed and then formatted it is a function that should be used with care due to the material performance implications.  `Cldr` uses this function during compilation to build functions that return the relevant data with higher performance and these functions are to be preferred over the use of `Cldr.Config.get_locale/1`.

## Use this package when you have a requirement to...

* Support multiple languages and locales in your application and need to support formatting numbers, dates, times, date-times, SI units and lists in a locale-specific manner

* Access the data maintained in the CLDR repository in a functional manner

* Parse an [Accept-Language](https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4) http header or a [language tag](https://tools.ietf.org/html/bcp47)

**It is highly likely that you will also want to install one or more of the dependent packages that provide localization and formatting for a particular data domain.  See [Additional Cldr Packages](#additional-cldr-packages) below**.

## Elixir Version Requirements

* [ex_cldr](https://hex.pm/packages/ex_cldr) requires Elixir 1.5 or later.

## Installation

Add `ex_cldr` as a dependency to your `mix` project:

    defp deps do
      [
        {:ex_cldr, "~> 1.0"},
        # Posion or any other compatible json library
        # that implements `encode!/1` and `decode!/1`
        # {:jason, "~> 1.0 or ~> 1.0-rc"}
        {:poison, "~> 2.1 or ~> 3.0"}
      ]
    end

then retrieve `ex_cldr` from [hex](https://hex.pm/packages/ex_cldr):

    mix deps.get
    mix deps.compile

Although `Cldr` is purely a library application, it should be added to your application list so that it gets bundled correctly for release.  This applies for Elixir versions up to 1.3.x; version 1.4 and later will automatically do this for you.

    def application do
      [applications: [:ex_cldr]]
    end

## Additional Cldr Packages

`ex_cldr` includes only basic functions to maintain the CLDR data repository in an accessible manner and to manage locale definitions.  Additional functionality is available by adding additional packages:

* Number formatting: [ex_cldr_numbers](https://hex.pm/packages/ex_cldr_numbers)
* List formatting: [ex_cldr_lists](https://hex.pm/packages/ex_cldr_lists)
* Unit formatting: [ex_cldr_units](https://hex.pm/packages/ex_cldr_units)
* Date/Time/DateTime formatting: [ex_cldr_dates_times](https://hex.pm/packages/ex_cldr_dates_times)
* Territories localization and information: [ex_cldr_territories](https://hex.pm/packages/ex_cldr_territories) by @Schultzer
* Languages localization: [ex_cldr_languages](https://hex.pm/packages/ex_cldr_languages) by @lostkobrakai

Each of these packages includes `ex_cldr` as a dependency so configuring any of these additional packages will automatically install `ex_cldr`.

## Configuration

`Cldr` attempts to maximise runtime performance at the expense of additional compile time.  Where possible `Cldr` will create functions to encapsulate data at compile time.  To perform these optimizations for all 523 locales known to Cldr wouldn't be an effective use of your time or your computer's.  Therefore `Cldr` requires that you configure the locales you want to use. You can do this in your `mix.exs` by specifying the locales you want to configure or by telling `Cldr` about a `Gettext` module you may already have configured - in which case `Cldr` will configure whatever locales you have configured in `Gettext` as well.

Here's an example configuration that uses all of the available configuration keys:

     config :ex_cldr,
       default_locale: "en",
       locales: ["fr", "en", "bs", "si", "ak", "th"],
       gettext: MyApp.Gettext,
       data_dir: "./priv/cldr",
       precompile_number_formats: ["¤¤#,##0.##"],
       precompile_transliterations: [{:latn, :arab}, {:thai, :latn}],
       json_library: Poison

### Configuration Keys

The configuration keys available for `Cldr` are:

 * `default_locale` specifies the default locale to be used if none has been set by `Cldr.put_locale/2` and none has been set in a configured `Gettext` module.  The default locale in case no other locale has been set is `"en"`.  Default locale calculated by:

     * If set by the `:default_locale` key, then this is the priority
     * If no `:default_locale` key, then a configured `Gettext` default locale is chosen
     * If no `:default_locale` key is specified and no `Gettext` module is configured, or is configured but has no default set, then the default locale will be `en-001`

 * `locales`: Defines what locales will be configured in `Cldr`.  Only these locales will be available and an exception `Cldr.UnknownLocaleError` will be raised if there is an attempt to use an unknown locale.  This is the same behaviour as `Gettext`.  Locales are configured as a list of binaries (strings).  For convenince it is possible to use wildcard matching of locales which is particulalry helpful when there are many regional variances of a single language locale.  For example, there are over 100 regional variants of the "en" locale in CLDR.  A wildcard locale is detected by the presence of `.`, `[`, `*` and `+` in the locale string.  This locale is then matched using the pattern as a `regex` to match against all available locales.  The example below will configure all locales that start with `en-` and the locale `fr`.


          config :ex_cldr,
            default_locale: "en",
            locales: ["en-*", "fr"]

   There is one additional setting which is `:all` which will configure all 523 locales.  **This is highly discouraged** since it will take many minutes to compile your project and will consume more memory than you really want.  This setting is there to aid in running the test suite.  Really, don't use this setting.

 * `gettext`: configures `Cldr` to use a `Gettext` module as an additional source of locales you want to configure.  Since `Gettext` uses the Posix locale name format (locales with an '\_' in them) and `Cldr` uses the Unicode format (a '-' as the subtag separator), `Cldr` will transliterate locale names from `Gettext` into the `Cldr` canonical form.

 * `data_dir`: indicates where downloaded locale files will be stored.  The default is `:code.priv_dir(:ex_cldr)`. It is highly recommended you do not change this setting.

 * `precompile_number_formats`: provides a means to have user-defined format strings precompiled at application compile time.  This has a performance benefit since precompiled formats execute approximately twice as fast as formats that are not precompiled.

 * `precompile_transliterations`: defines those transliterations between the digits of two different number systems that will be precompiled.  The is a list of 2-tuples where each tuple is of the form `{from_number_system, to_number_system}` where each number system is expressed as an atom.  The available  number systems is returned by `Cldr.Number.System.systems_with_digits/0`.  The default is the empty list `[]`.

 * `json_library`: Configures the json library to be used for decoding the locale definition files. The default is `Jason` if available then `Poison` if not.  Any library that provides the functions `encode!/1` and `decode!/1` can be used.  One alternative to `Poison` is [Jason](https://hex.pm/packages/jason).  **Since the json library is configurable it will also need to be configured in the project's `mix.exs`**.

### Recompiling after a configuration change

Cldr includes a "compiler" that will detect locale configuration changes and compile the necessary components of Cldr that depend on that configuration.  To make this automatic recompilation happen the `[:cldr]` compiler needs to be added to you `mix.exs`.  For example:

```
  def project do
    [
      app: :app_name,
      compilers: Mix.compilers ++ [:cldr],
      ...
    ]
  end
```

Note the addition of `[:cldr]` as the **last** compiler on the list.  This is a firm requirement.

## Downloading Configured Locales

`Cldr` can be installed from either [github](https://github.com/kipcole9/cldr)
or from [hex](https://hex.pm/packages/ex_cldr).

* If installed from github then all 523 locales are installed when the repo is cloned into your application deps.

* If installed from hex then only the locales "en", "en-001" and "root" are installed.  When you configure additional locales these will be downloaded during application compilation.  Please note above the requirement for a force recompilation in this situation.

## Localizing and Formatting Numbers

The `Cldr.Number` module implemented in the [ex_cldr_numbers](https://hex.pm/packages/ex_cldr_numbers) package provides number formatting.  The public API for number formatting is `Cldr.Number.to_string/2`.  Some examples:

    iex> Cldr.Number.to_string 12345
    "12,345"

    iex> Cldr.Number.to_string 12345, locale: "fr"
    "12 345"

    iex> Cldr.Number.to_string 12345, locale: "fr", currency: "USD"
    "12 345,00 $US"

    iex> Cldr.Number.to_string 12345, format: "#E0"
    "1.2345E4"

    iex(> Cldr.Number.to_string 1234, format: :roman
    "MCCXXXIV"

    iex> Cldr.Number.to_string 1234, format: :ordinal
    "1,234th"

    iex> Cldr.Number.to_string 1234, format: :spellout
    "one thousand two hundred thirty-four"

See `h Cldr.Number` and `h Cldr.Number.to_string` in `iex` for further information.

## Localizing Lists

The `Cldr.List` module provides list formatting and is implemented in the [ex_cldr_lists](https://hex.pm/packages/ex_cldr_lists) package.  The public API for list formating is `Cldr.List.to_string/2`.  Some examples:

    iex> Cldr.List.to_string(["a", "b", "c"], locale: "en")
    "a, b, and c"

    iex> Cldr.List.to_string(["a", "b", "c"], locale: "en", format: :unit_narrow)
    "a b c"

    iex> Cldr.List.to_string(["a", "b", "c"], locale: "fr")
    "a, b et c"

Seer `h Cldr.List` and `h Cldr.List.to_string` in `iex` for further information.

## Localizing Units

The `Cldr.Unit` module provides unit localization and is implemented in the [ex_cldr_units](https://hex.pm/packages/ex_cldr_units) package.  The public API for unit localization is `Cldr.Unit.to_string/3`. Some examples:

      iex> Cldr.Unit.to_string 123, :gallon
      "123 gallons"

      iex> Cldr.Unit.to_string 1234, :gallon, format: :long
      "1 thousand gallons"

      iex> Cldr.Unit.to_string 1234, :gallon, format: :short
      "1K gallons"

      iex> Cldr.Unit.to_string 1234, :megahertz
      "1,234 megahertz"

      iex> Cldr.Unit.available_units
      [:acre, :acre_foot, :ampere, :arc_minute, :arc_second, :astronomical_unit, :bit,
       :bushel, :byte, :calorie, :carat, :celsius, :centiliter, :centimeter, :century,
       :cubic_centimeter, :cubic_foot, :cubic_inch, :cubic_kilometer, :cubic_meter,
       :cubic_mile, :cubic_yard, :cup, :cup_metric, :day, :deciliter, :decimeter,
       :degree, :fahrenheit, :fathom, :fluid_ounce, :foodcalorie, :foot, :furlong,
       :g_force, :gallon, :gallon_imperial, :generic, :gigabit, :gigabyte, :gigahertz,
       :gigawatt, :gram, :hectare, :hectoliter, :hectopascal, :hertz, :horsepower,
       :hour, :inch, ...]

See `h Cldr.Unit` and `h Cldr.Unit.to_string` in `iex` for further information.

## Localizing Dates, Times and DateTimes

Formatting of relative dates and date times is supported in the `Cldr.DateTime.Relative` module implemented in the [ex_cldr_dates_times](https://hex.pm/packages/ex_cldr_dates_times) package.  The public API is `Cldr.DateTime.to_string/2` and `Cldr.DateTime.Relative.to_string/2`.  Some examples:

      iex> Cldr.Date.to_string Date.utc_today()
      {:ok, "Aug 18, 2017"}

      iex> Cldr.Time.to_string Time.utc_now
      {:ok, "11:38:55 AM"}

      iex> Cldr.DateTime.to_string DateTime.utc_now
      {:ok, "Aug 18, 2017, 11:39:08 AM"}

      iex> Cldr.DateTime.Relative.to_string 1, unit: :day, format: :narrow
      {:ok, "tomorrow"}

      iex> Cldr.DateTime.Relative.to_string(1, unit: :day, locale: "fr")
      "demain"

      iex> Cldr.DateTime.Relative.to_string(1, unit: :day, format: :narrow)
      "tomorrow"

      iex> Cldr.DateTime.Relative.to_string(1234, unit: :year)
      "in 1,234 years"

      iex> Cldr.DateTime.Relative.to_string(1234, unit: :year, locale: "fr")
      "dans 1 234 ans"

## Gettext Backend Pluralization Support

There is an experimental plurals module for Gettext called `Cldr.Gettext.Plural`.  It is configured in `Gettext` by:

    defmodule MyApp.Gettext do
      use Gettext, plural_forms: Cldr.Gettext.Plural
    end

`Cldr.Gettext.Plural` will fall back to `Gettext` pluralisation if the locale is not known to `Cldr`.  This module is only compiled if `Gettext` is configured as a dependency in your project.

Note that `Cldr.Gettext.Plural` does not guarantee to return the same `plural index` as `Gettext`'s own pluralization engine which can introduce some compatibility issues if you plan to mix plural engines.

## Plugs

`Cldr` provides two plugs to aid integration into an HTTP workflow.  These two plugs are:

* `Cldr.Plug.AcceptLanguage` which will parse an `accept-language` header and resolve the best matched and configured `Cldr` locale. The result is stored in `conn.private[:cldr_locale]` which is also returned by `Cldr.Plug.AcceptLanguage.get_cldr_locale/1`.

* `Cldr.Plug.SetLocale` which will look for a locale in the several places and then call `Cldr.set_current_locale/1` and `Gettext.put_locale/2` if configured so to do. Finally, The result is stored in `conn.private[:cldr_locale]` which is then available through `Cldr.Plug.SetLocale.get_cldr_locale/1`. The plug will look for a locale in the following locations depending on the plug configuration:

  * `url_params`
  * `query_params`
  * `body_params`
  * `cookies`
  * `accept-language` header
  * the `session`

* See `Cldr.Plug.SetLocale` for a description of how to configure the plug.

## About Language Tags and Locale strings

Note that `Cldr` defines locale strings according to the [IETF standard](https://en.wikipedia.org/wiki/IETF_language_tag) as defined in [RFC5646](https://tools.ietf.org/html/rfc5646).  `Cldr` also implements the `u` extension as defined in [RFC6067](https://tools.ietf.org/html/rfc6067) and the `t` extension defined in [RFC6497](https://tools.ietf.org/html/rfc6497). This is also the standard used by [W3C](https://www.w3.org/TR/ltli/).

The IETF standard is slightly different to the [ISO/IEC 15897](http://www.open-std.org/jtc1/sc22/wg20/docs/n610.pdf) standard used by Posix-based systems; primarily in that ISO 15897 uses a "_" separator whereas IETF and W3C use "-".

Locale string are case insensitive but there are common conventions:

* Language codes are lower-cased
* Territory codes are upper-cased
* Script names are capital-cased

### Notes

* A language code is an ISO3166 language code.
* Potentially one or more modifiers separated by `-` (dash), not a `_`. (underscore).  If you configure a `Gettext` module then `Cldr` will transliterate `Gettext`'s `_` into `-` for compatibility.
* Typically the modifier is a territory code.  This is commonly a two-letter uppercase combination.  For example `pt-PT` is the locale referring to Portugese as used in Portugal.
* In `Cldr` a locale name is always a `binary` and never an `atom`.  Internally a locale is parsed and stored as a `Cldr.LanguageTag` struct.
* The locales known to `Cldr` can be retrieved by `Cldr.known_locale_names/0` to get the locales known to this configuration of `Cldr` and `Cldr.all_locale_names/0` to get the locales available in the CLDR data repository.

## Testing

Tests cover the full 523 locales defined in CLDR. Since `Cldr` attempts to maximize the work done at compile time in order to minimize runtime execution, the compilation phase for tests is several minutes.

Tests are run on Elixir 1.5.x.  `Cldr` will not run on Elixir versions before 1.5.

### Updating the CDLR data repository if installing from Github

The CLDR data is maintained in [JSON format by the Unicode Consortium](https://github.com/unicode-cldr/cldr-json).  The appropriate content is maintained as submodules in the `data` directory of this `Cldr` repository.

If this repo has just been cloned then first of all you will need to initialize and retrieve the submodules:

    git submodule update --init data/*

When CLDR releases new data then the submodules in this repo also need to be updated.  To update the CDLR data, `git pull` each of the submodules.  For example:

    git submodule -q foreach git pull -q origin master

From time-to-time ISO will update the repository of ISO3166 language codes.  Ensure you have the latest version downloaded:

    mix cldr.download.iso_currency

After updating the respository, the locales need to be consolidated into the format used by Cldr.  This is done by:

    mix cldr.consolidate

Then you will need to regenerate the `language_tags.ebin` file by executing the following.  Note that `MIX_ENV=test` is essential since thats how we guarantee all locales are configured.

    MIX_ENV=test mix cldr.generate_language_tags
