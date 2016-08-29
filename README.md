# Cldr Introduction  ![Build Status](http://sweatbox.noexpectations.com.au:8080/buildStatus/icon?job=cldr) ![Deps Status](https://beta.hexfaktor.org/badge/all/github/kipcole9/cldr.svg)

**Common locale libary for Elixir**

Just starting implementation and not ready for use.

* Current work is focused on number formatting (ordinal, cardinal, currency) followed then by RBNF
* List formatting is completed
* Time, date and units will follow

**Source data**

Data is from the ICU's CLDR project when is downloaded in XML format.  For ease of consumption it is then converted to `json` format with the following commands:

    java -DCLDR_DIR=. -jar ../tools/tools/java/cldr.jar ldml2json -t main -p true -r true
    java -DCLDR_DIR=. -jar ../tools/tools/java/cldr.jar ldml2json -t supplemental -p true -r true

**Compilation**

A lot of functions are generated during the compilation phase.  If all 511 locales are configured (an unlikely production use case) then compilation can take several minutes.  This is most typically when running `cldr` tests.

**Configuration**

`Cldr` tries to be a good neighbour to `Gettext` and will use `Gettext`'s locale configuration if that is available.  In some cases its also useful to configure locales indpendently of `Gettext` and `Cldr` provides for this.  A typical configuration file would look like the following which will use whatever locales are configured in `Gettext` as well as the locales `"fr", "en", "bs", "si", "ak", "th"` whether or not they are configured in `Gettext`.

     config :cldr,
      default_locale: "en",
      locales: ["fr", "en", "bs", "si", "ak", "th"],
      gettext: Cldr.Gettext

Its also perfectly ok to use `Cldr` without `Gettext`:

     config :cldr,
      default_locale: "en",
      locales: ["fr", "en", "bs", "si", "ak", "th"]

All locales (currently 511) can be configured by specifying `:all` in the `locales:` key.

     config :cldr,
      default_locale: "en",
      locales: :all

Note that this is rarely the right production strategy: compilation takes minutes for a start.  But it is useful for testing 'Cldr' itself.

***Default locale***

The default locale can be specified, and it is not specified then the default locale becomes `en`
