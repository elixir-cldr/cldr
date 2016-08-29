# Getting Started

`Cldr` is an Elixir library for the [Unicode Consortium's](http://unicode.org) [Common Locale Data Repository (CLDR)](http://cldr.unicode.org).  The intentions of CLDR, and this library, it to simplify the locale specific formatting of numbers, lists, currencies, calendars, units of measure and dates/times.  As of August 2016, `Cldr` is based upon [CLDR version 29](http://cldr.unicode.org). Version 30 of CLDR is expected to be released in the third week of September (as is usual each year) and this library will be updated with that CLDR version's data before the end of September.

## Installation

Add `cldr` as a dependency to your `mix` project:

```elixir
defp deps do
  [
    {:cldr, "~> 0.0.1"}
  ]
end
```

then retrieve `cldr` from [hex](http://hex.pm):

```elixir
mix deps.get
mix deps.compile
```

That's it.  You're ready to go with a default configuration of one locale, "en".

## Configuration

For the default english locale "en" no configuration is required.  If you want to configure additional locales then add a `config` key to `config.exs` or your environment specific `.exs` per the below:

```elixir
# mix.exs
use Mix.Config

config :cldr,
  default_locale: "en",
  locales: ["fr", "en", "pl", "ru", "th"]
```

There are other configuration options that are available, including configuring `Cldr` to use locales defined in `Gettext`.  For further information see the [configuration guide](config.html).

