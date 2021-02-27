# Changelog for Cldr v2.20.0

## Enhancements

* Updates to [CLDR version 39](http://cldr.unicode.org/index/downloads/cldr-39) data.

* Add locale display name data to the locale files. This data can be used to format a locale for UI usage.

* Add grammatical features to the repository. This data is used in [ex_cldr_units](https://github.com/elixir-cldr/cldr_units). See also `Cldr.Config.grammatical_features/0`.

# Changelog for Cldr v2.19.0

This is the changelog for Cldr v2.19.0 released on February 6th, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

## Breaking change

* A parsed langauge tag would previously turn the `tz` parameter of the `u` extension into a timezone ID. For example, the language tag `en-AU-u-tz-ausyd` would decode `ausyd` into `Australia/Sydney`. From this release, parsing no longer decodes the `tz` parameter since doing so means that `to_string/1` does not work correctly.  Use `Cldr.Locale.timezone_from_locale/1` instead.

## Enhancements

* Updates to [CLDR 38.1](https://unicode-org.github.io/cldr-staging/charts/38.1/delta/index.html)

* Includes the display name and where available the gender for units in the locale data to support generating UI elements in the upcoming version 3.4.0 of [ex_cldr_units](https://github.com/elixir-cldr/cldr_units)

* Add `Cldr.Locale.timezone_from_locale/{1,2}` to extract a timezone ID from a language tag

* Add option `:format` to `Cldr.ellipsis/2`. This option is either `:word` or `:sentence`.  `:sentence` is the default. Using the locale `en` as an example, the differences in formatting are:

```elixir
# Default style: :sentence
iex> Cldr.ellipsis "And furthermore"
"And furthermore…"

iex> Cldr.ellipsis ["And furthermore", "there is much to be done"], locale: "ja"
"And furthermore…there is much to be done"

# With style: :word
iex> Cldr.ellipsis "And furthermore", style: :word
"And furthermore …"

iex> Cldr.ellipsis ["And furthermore", "there is much to be done"], locale: "ja", format: :word
"And furthermore … there is much to be done"
```

# Changelog for Cldr v2.18.2

This is the changelog for Cldr v2.18.2 released on November 9th, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

## Enhancements

* Add `Cldr.Locale.territory_from_locale/1` for string language tags

# Changelog for Cldr v2.18.1

This is the changelog for Cldr v2.18.1 released on November 7th, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

## Enhancements

* Add `<backend>.Locale.territory_from_locale/1`

## Bug Fixes

* Fixes `Cldr.LanguageTag.to_string/1` when the `u` extenion is empty. Closes #140. Thanks to @Zurga.

# Changelog for Cldr v2.18.0

This is the changelog for Cldr v2.18.0 released on November 1st, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

## Enhancements

* Update to [CLDR 38](http://cldr.unicode.org/index/downloads/cldr-38)

* Removed the `mix cldr.compile` mix task (it was deprecated several releases ago)

* Removed the `mix cldr.download.core_data` mix task since the current development process does not require it.

* The script `ldml2json` now rebuilds to tools on each run and instead of hardcoded environment variables it uses existing ones if set and only applies defaults if required. This is applicable only to `ex_cldr` developers and maintainers.

* Warn on duplicate providers being configured for a backend and then ignore the duplicates.

* Omit stacktrace when warning about use of the global configuration

* Deprecate `Cldr.default_backend/0` in favour of `Cldr.default_backend!/0` which more clearly expresses that the function will raise if no default backend is configured.

* Changes the behaviour of `Cldr.put_locale/{1, 2}`. In previous releases the intent was that a process would store a locale for a given backend. Logically however, it is more appropropriate to store a locale on a per-process basis, not per backend per process.  The backend is an important asset, but only insofaras it hosts locale-specific content.  Therefore in this release, `Cldr.put_locale/{1, 2}` always stores the locale on a per-process basis and there is only one locale, not one specialised per backend. This also simplifies `Cldr.get_locale/0` which now returns the process's locale or the default locale.

* Support plural categories of "compact decimals". These are represented as `{number, formatting_exponent}`. See [TR35](https://unicode-org.github.io/cldr/ldml/tr35-numbers.html#Plural_rules_syntax) for more information. This notation is only supported for `Cldr.Number.PluralRule.plural_type/2`. In CLDR version 38 only the locale "fr" includes rules that differ for some compact formats. For example:
```
# For all locales except "fr" the plural type is the same
# for all exponents
iex> Cldr.Number.PluralRule.plural_type {1234567, 3}, locale: "en"
:other
iex> Cldr.Number.PluralRule.plural_type {1234567, 6}, locale: "en"
:other

# For "fr", compact formats pluralize differently in some cases
iex> Cldr.Number.PluralRule.plural_type {1234567, 3}, locale: "fr"
:other
iex> Cldr.Number.PluralRule.plural_type {1234567, 6}, locale: "fr"
:many
```

# Changelog for Cldr v2.17.2

This is the changelog for Cldr v2.17.2 released on September 30th, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

## Bug Fixes

* When configuring a Cldr backend, warn then omit any Gettext locales configured that aren't actually available in CLDR. Thanks to @mikl. Closes #138.

# Changelog for Cldr v2.17.1

This is the changelog for Cldr v2.17.1 released on September 26th, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

## Bug Fixes

* Significantly improve the performance of `Cldr.default_locale/0`. In previously releases, the default locale was being parsed on each access. In this release it is parsed once and cached in the application environment. This improves performance by about 40x.  Thanks to @Phillipp who brought this to attention in [Elixir Forum](https://elixirforum.com/t/cldr-number-parser-parse-quite-slow/34572)

# Changelog for Cldr v2.17.0

This is the changelog for Cldr v2.17.0 released on September 8th, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

## Enhancements

* Support `Decimal` version `~> 1.6` and `~> 2.0`

## Bug Fixes

* Corrects `Cldr.Plug.SetLocale` testing for body parameters. Previous version of `Plug` would parse body parameters for an HTTP `get` verb which is not standard behaviour. The test now uses the HTTP `put` verb where body paramters are expected to be parsed.

* Corrects internal links to the readme.

# Changelog for Cldr v2.16.2

This is the changelog for Cldr v2.16.2 released on August 29th, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

## Bug Fixes

* Fix compiler warning for Elixir 1.11 when calling a remote function that is based upon a module name that is a variable.

# Changelog for Cldr v2.16.1

This is the changelog for Cldr v2.16.1 released on June 7th, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

## Bug Fixes

* Do not send `Connection: close` header when downloading locales.

* Do not convert `charlist` data from `:httpc` before saving it as a locale file. Fixes an issue whereby the saved locale file is shorter than expected due to an extraneous use of `:erlang.list_to_binary/1` which is not `UTF8` friendly. Thanks to @halostatue for the patience and persistence working this issue through on a weekend. Fixes #137.

# Changelog for Cldr v2.16.1-rc.0

This is the changelog for Cldr v2.16.1-rc.0 released on June 7th, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Do not send `Connection: close` header when downloading locales.

* Do not convert `charlist` data from `:httpc` before saving it as a locale file. Probably fixes an issue whereby the saved locale file is shorter than expected.

# Changelog for Cldr v2.16.0

This is the changelog for Cldr v2.16.0 released on June 6th, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Add configuration key `:force_locale_download` for backend and the global configuration. Locale data is `ex_cldr` version dependent. When a new version of `ex_cldr` is installed, no locales are installed and therefore locales are downloaded at compilation time as required. This ensures that the right version of the locale data is always associated with the right version of `ex_cldr`.

However:

* If locale data is being cached in CI/CD there is some possibility that there can be a version mismatch.  Since reproducable builds are important, using the `force_locale_download: true` in a backend or in global configuration adds additional certainty.  The default setting is `false` thereby retaining compatibility with existing behaviour. The configuration can also be made dependent on `mix` environment as shown in this example:

```elixir
defmodule MyApp.Cldr do
  use Cldr,
	  locales: ["en", "fr"],
		default_locale: "en",
		force_locale_download: Mix.env() == :prod

```

### Bug Fixes

* Validate configured locales in a backend case insensitively and with either BCP 47 or Poxix ("-" or "_") separators.

# Changelog for Cldr v2.15.0

This is the changelog for Cldr v2.15.0 released on May 27th, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

Starting with `ex_cldr` the development process now requires the CLDR repository be cloned to the development machine; that the CLDR json data is generated on that machine and the shell variable `CLDR_PRODUCTION_DATA` must be set to the directory where the generated json data is stored.  For more information on the development process for `ex_cldr` consult `DEVELOPMENT.md`

This change is relevant only to the developers of `ex_cldr`. It is not applicable to users of the library.

### Enhancements

* Adds data to support lenient parsing of dates and numbers

# Changelog for Cldr v2.14.1

This is the changelog for Cldr v2.14.1 released on May 15th, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Fix compilation order for backends configured in `Cldr.Plug.SetLocale`. Thanks to @syfgkjasdkn. Closes #135.

# Changelog for Cldr v2.14.0

This is the changelog for Cldr v2.14.0 released on May 2nd, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

The primary purpose of this release is to support the new data for units that standardize
a means for conversion.  In addition, some data file names are changed to be more consistent in naming.

### Summary

* Updates the data source to [CLDR release 37](http://cldr.unicode.org/index/downloads/cldr-37).

* Require that a certificate trust store be configured in order to download locales. A system trust store will be automatically detected in many situations. In other cases configuring [castore](https://hex.pm/packages/castore) or [certifi](https://hex.pm/pacakges/certifi) will be automatically detected. A specific trust store can be configured under the `:cacertfile` key of the `:ex_cldr` configuration in `config.exs`. Note that on Windows either `castore`, `certifi` or a configured trust store will be requried.

* Add `Cldr.put_default_locale/{1, 2}` to set the system-wide default locale. The removes the need to configure a default locale in `config.exs` in keeping with modern Elixir app configuration strategies.

* Adds the `Cldr.Chars` protocol and the `Cldr.to_string/1` function intended to be a drop-in replacement for `Kernel.to_string/1` to make it easier to develop localised applications.

* Add the new data Units introduced in [CLDR version 37](http://cldr.unicode.org/index/downloads/cldr-37). This data is used in an updated `ex_cldr_units` package.

* The plugs `Cldr.Plug.AcceptLanguage` and `Cldr.Plug.SetLocale` no longer require a backend be configured. The `Cldr.default_backend/0` will be used if no specific backend is configured.

* Add territory subdivisions. The are a geographic level below territory and typically represent states/provinces of a country. In some cases large cities or counties are also known.

* Add calendar preferences.  `Cldr.Config.calendar_preferences/0` returns the map of territory to the desired calendar list in descending order or preference.

* Add "yue" locale now that the data is complete in CLDR 37. There are now 566 locales up from 541 in CLDR 36.  See the [release notes](http://cldr.unicode.org/index/downloads/cldr-37) for further information.

### Breaking changes (that you should not notice)

Although these are breaking changes, they are changes that affect functions in `Cldr.Config` which is considered a private module and therefore client applications are not expected to be impacted.

* Minimal supported version of Elixir is 1.6 (it was 1.5)

* Adds `Cldr.LanguageTag.U` to formalise the structure of the BCP47 `U` extension. This changes the data format of a `LanguageTag` that has a `U` extension. Additionally, most fields of this struct are now atoms, not binaries.

* Adds `Cldr.LanguageTag.T` to formalise the structure of the BCP47 `T` extension. This changes the data format of a `LanguageTag` that has a `T` extension.

* Rename `Cldr.Config.calendar_data/0` to `Cldr.Config.calendars/0`

* Rename `Cldr.Config.territory_info/0` to `Cldr.Config.territories/0`

* Rename `Cldr.Config.territory_info/1` to `Cldr.Config.territory/1`

* Rename `Cldr.Config.week_data/0` to `Cldr.Config.weeks/0`

* Rename `Cldr.Config.territory_containment/0` to `Cldr.Config.territory_containers/0`

* Remove `priv/cldr/measurement_system_preferences.json`. This data is returned in `Cldr.Config.territories/0`

* Use canonical measurement system names throughout. This changes some data returned by `Cldr.Config.territory/0` and `Cldr.Config.measurement_system_preferences/0`

* Rename `priv/cldr/week_data.json` to `priv/cldr/weeks.json`

* Rename `priv/cldr/calendar_data.json` to `priv/cldr/calendars.json`

* Rename `priv/cldr/territory_info.json` to `priv/cldr/territories.json`

### Bug Fixes

* Correct the preferred measurement system for temperature in some territories (including the US)

### Enhancements

* Require that a certificate trust store be configured in order to download locales

* Add the `Cldr.Chars` protocol which defines `to_string/1` and it invoked from `Cldr.to_string/1`. It is intended as a drop-in replacement for `Kernel.to_string/1` excepting that it produces localised output. Then intent is to continue making it easier for developers to build localised applications.

* The plug `Cldr.Plug.AcceptLanguage` no longer requires that a backend be configured. The backend returned by `Cldr.default_backend/0` will be used by default.

* The plug `Cldr.Plug.SetLocale` no longer requires that a backend be configured. The backend returned by `Cldr.default_backend/0` will be used by default.

* `t:Cldr.LanguageTag.t` now includes a `:backend` field which is populated during parsing. This allows the implementation of the `Cldr.Chars` protocol.

* CLDR has introduced unit conversion data. This data is now packaged as `Cldr.Config.units/0` which is used for [ex_cldr_units version 3.0](https://hex.pm/packages/ex_cldr_units/3.0.0)

* Unit Preferences now consistently use underscore in names and values instead of dashes.

* Add `Cldr.validate_backend/1` to validate if a module is a CLDR backend module

* Add `Cldr.validate_measurement_system/1` to validate a measurement system name

* Add `Cldr.Config.measurement_systems/0` to return a map of known measurement systems

* Add `Cldr.Config.time_preferences/0` to return a map of time preferences for a given locale or territory. This data is used in [ex_cldr_dates_times](https://github/com/elixir-cldr/cldr_dates_times) from version `2.4`

* Add `Cldr.Config.territory_containment/0` that returns a map of territories to a list of lists of the territories in which it is contained. A territory may be contained by more than one list of containers. For example, `:GB` is contained like this: `[[:"154", :"150", :"001"], [:UN], [:EU]]`.

* Add `Cldr.known_territory_subdivisons/0` to return a map of regions and subdivisions and their children

* Add `Cldr.known_territory_subdivision_containment/0` to return a map of subdivisions and their parents

* Add `priv/cldr/units.json` which contains the new unit data and conversion information from CLDR 37

* Add `priv/cldr/measurement_systems.json`

* Add `Cldr.validate_backend/1` to confirm a backend modules existence and that it includes `use Cldr`

* Add `Cldr.Locale.territory_from_locale/1` to determine the territory to be used for localization.

* Add `Cldr.Config.calendar_preferences/0`

* Add `Cldr.the_world/0` that returns the territory code for the world which is `:001`

# Changelog for Cldr v2.13.0

This is the changelog for Cldr v2.13.0 released on January 19th, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Removes the runtime dependency on `Jason` since the RFC5646 parser is now inlined. Closes #99

* Adds `Cldr.Timezone` to support timezone mapping for language tags using the `tz` key of the `u` extension to the [Unicode locale identifier](https://unicode.org/reports/tr35/#u_Extension)

* When parsing a locale with a `u` extension containing a `cf` (currency format) key, the key is transformed to the standard `:currency` or `:accounting` atoms rather than being left as strings.

# Changelog for Cldr v2.12.1

This is the changelog for Cldr v2.12.1 released on January 14th, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Remove two lingering dialyzer errors-that-aren't-really-errors so its passes cleanly.

# Changelog for Cldr v2.12.0

This is the changelog for Cldr v2.12.0 released on January 2nd, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Remove use of `Code.ensure_compiled?/1` since its deprecated in Elixir 1.10. A new function `Cldr.Config.ensure_compiled?/1` is introduced but marked as `@doc false`.

* Adds `mix cldr.download.plural_ranges` to automate the downloading, extracting and saving of `pluralRanges.xml` from CLDR.

* Update copyright dates in LICENSE.md

# Changelog for Cldr v2.11.1

This is the changelog for Cldr v2.11.1 released on October 20th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Validate session-based locale in `Cldr.Plug.SetLocale`. Closes #131. Thanks for @Ray-Wang.

# Changelog for Cldr v2.11.0

This is the changelog for Cldr v2.11.0 released on October 10th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Update to CLDR data version 36.0.0.

# Changelog for Cldr v2.10.2

This is the changelog for Cldr v2.10.2 released on September 7th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Use `Keyword.get_lazy/3` when retrieving `Cldr.default_backend/0` to avoid exceptions when no default backend is configured.

* `Cldr.Number.PluralRule.plural_type/2` has become `Cldr.Number.PluralRule.plural_type/3` to better align with other functions that typically use `argument, backend, options` as their parameters. No user code change is expected as the function heads remain compatible.

# Changelog for Cldr v2.10.1

This is the changelog for Cldr v2.10.1 released on August 25th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Fix error in the generation of unit preference data

# Changelog for Cldr v2.10.0

This is the changelog for Cldr v2.10.0 released on August August 25th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Adds unit preference data. This data is used by [ex_cldr_units](https://hex.pm/packages/ex_cldr_units) version 2.6 and later to allow localization of units into the preferred units for a given locale or territory.

# Changelog for Cldr v2.9.0

This is the changelog for Cldr v2.9.0 released on August August 24th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Includes the compound unit fields from units in the generated locale data.  This enables formatting of compount units, like the "per" form which is used when there is no predefined unit style. This functionality is enabled in [ex_cldr_units](https://hex.pm/packages/ex_cldr_units) version 2.6.

* Add `Cldr.quote/3` and `MyApp.Cldr.quote/2` that add locale-specific quotation marks around a string.  The locale data files are updated to include this information.

* Add `Cldr.ellipsis/3` and `MyApp.Cldr.ellipsis/2` that add locale-specific ellipsis' to a string. The locale data files are updated to include this information.

* Add `Cldr.Config.measurement_system/0` that returns a mapping between a territory and a measurement system (ie does a territory/country use the metric, US or UK system)

# Changelog for Cldr v2.8.1

This is the changelog for Cldr v2.8.1 released on August 23rd, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Fix the `@spec` for `Cldr.Substitution.substitute/2`

# Changelog for Cldr v2.8.0

This is the changelog for Cldr v2.8.0 released on August 21st, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Adds `Cldr.validate_plural_type/1` which will validate if a plural type is one those returned by `Cldr.Number.PluralRule.known_plural_types/0` which is also added.  These functions are added to support message formatting in the forthcoming `ex_cldr_messages` package.

* Adds `Cldr.Number.PluralRule.plural_type/2` which returns the plural type for a number.

* Adds `message_formats` backend configuration key.  This is used by [ex_cldr_messages](https://github.com/elixir-cldr/cldr_messages) to define custom formats for messages.

### Bug Fixes

* Add `@spec` to parser combinators to remove dialyzer warnings.  Ensure that you are using `nimble_parsec` version 0.5.1 or later if running dialyzer checks.

# Changelog for Cldr v2.7.2

This is the changelog for Cldr v2.7.2 released on June 14th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Fixes a bug whereby a `Gettext` backend module may not be compiled at the time that the `Cldr` backend is being compiled. This can cause compilation errors and may cause the wrong assembly of configured locales. Closes #124.  Thanks very much to @erikreedstrom and @epilgrim.

* Fixes a bug whereby a `Cldr` backend may not be recognised during compilation of `Cldr.Plug.SetLocale`. Similar issue to #124. Thanks for @AdrianRibao for the report.

# Changelog for Cldr v2.7.1

This is the changelog for Cldr v2.7.1 released on June 2nd, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Fix `Cldr.known_number_systems/0` by removing the call to `Config.known_number_systems/0` which decodes json on each call and use `Cldr.known_number_systems/0` which does not.

# Changelog for Cldr v2.7.0

This is the changelog for Cldr v2.7.0 released on April 22nd, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Updates to CLDR version 35.1.0 which is primarily related to the change of Japanese era with the ascension of a new emporer on April 1st.

# Changelog for Cldr v2.6.2

This is the changelog for Cldr v2.6.2 released on April 16th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Adds `Cldr.flag/1` that returns a binary unicode grapheme representing a flag for a given territory

* The parameters provided to `Cldr.Plug.SetLocale.init/1` are now conformed more precisely based upon the provided options. This ensures that the keys `:cldr` and `:gettext` are set from other options if they are not provided directly.

### Bug Fixes

* `Cldr.Plug.SetLocale.init/1` would raise an exception if no `:gettext` key was specified.  This is now corrected.

# Changelog for Cldr v2.6.1

This is the changelog for Cldr v2.6.1 released on April 13th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Correctly resolves the `:data_dir` param for a backend module.  Thanks to @erikreedstrom for the report.  Closes #123.

* Raises if a backend module configures an `:otp_app` that is not known

# Changelog for Cldr v2.6.0

This is the changelog for Cldr v2.6.0 released on March 28th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Updates to [CLDR version 35.0.0](http://cldr.unicode.org/index/downloads/cldr-35) released on March 27th 2019.

There is one unresolved issue in this implementation related to plural rules for the locale "kw" (Cornish).

The plural rule definition for `:other` in the repository is:
```
"pluralRule-count-other": " @integer 4~19, 100, 1000000, … @decimal 0.1~0.9, 1.1~1.7, 10.0, 100.0, 1000.0 100000.0 1000000.0, …",
```

However in rules testing, the values `1000.0`, `10000.0` and `100000.0` are resolving to category `:two` rather than `:other`. Until this is resolved, these data points are removed from the test data.

# Changelog for Cldr v2.5.0

This is the changelog for Cldr v2.5.0 released on March 23rd, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Adds the global `:ex_cldr` configuration key `:default_backend`.

* Adds `Cldr.default_backend/0` which will return the configured default backend or will raise an exception if not is configured.

* Where appropriate, `Cldr.*` will now use `Cldr.default_backend()` as a default parameter.

# Changelog for Cldr v2.4.3

This is the changelog for Cldr v2.4.3 released on March 20th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Fix `Cldr.validate_locale/1` @spec error and remove spurious `@dialyzer` directives

# Changelog for Cldr v2.4.2

This is the changelog for Cldr v2.4.2 released on March 15th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Exclude `Cldr.Currency` from the list of known providers so that it won't be compiled twice when working with `ex_cldr_numbers`.

# Changelog for Cldr v2.4.1

This is the changelog for Cldr v2.4.1 released on March 14th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Makes generation of documentation for backend modules optional.  This is implemented by the `:generate_docs` option to the backend configuration.  The default is `true`. For example:

```
defmodule MyApp.Cldr do
  use Cldr,
    default_locale: "en-001",
    locales: ["en", "ja"],
    gettext: MyApp.Gettext,
    generate_docs: false
end
```
# Changelog for Cldr v2.4.0

This is the changelog for Cldr v2.4.0 released on March 10th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Minor restructuring of the locale files.  Calendar map keys are harmonised to have the same names and meanings. This would not normally be user visible but a change in data format suggests a minor version bump to easy version management.

* Restructure the data returned by `Cldr.Config.week_info/0` to also encode week days as numbers in the range 1..7 where 1 is Monday.

# Changelog for Cldr v2.3.2

This is the changelog for Cldr v2.3.2 released on March 8th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Does a better job of detecting a required JSON library and raising at compile time if no such library can be found.  In order of priority the search for a JSON library is:

    * the key `:json_library` under the application key `:ex_cldr`
    * a configured Phoenix `json_library`
    * a configured Ecto `json_library`
    * `Jason` if configured
    * `Poison` if configured

# Changelog for Cldr v2.3.1

This is the changelog for Cldr v2.3.1 released on March 6th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Fix dialyzer errors.  In some cases, notably related to `nimble_parsec`, errors are generated that need to be fixed in a dependency.  These errors are added to the `.dialyzer_ignore_warnings` file for now.

# Changelog for Cldr v2.3.0

This is the changelog for Cldr v2.3.0 released on March 4th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Adds `Cldr.LanguageTag.to_string/1` which converts a `Cldr.LanguageTag{}` into a language tag string. This is useful when creating a collator that is based upon `libicu` since that collator will apply the configuration specified by the `u` extension in the language tag.  For example:

```
iex> {:ok, locale} = Cldr.validate_locale "en-US-u-co-phonebk-nu-arab", MyApp.Cldr
iex> Cldr.LanguageTag.to_string(locale)
"en-Latn-US-u-ca-phonebk-nu-arab"
```

### Bug Fixes

* Fix a bug when parsing some locale strings which have extensions. An extension may have a list of "keyword-type" pairs or simply "keyword". Parsing was failing when only the "keyword" form was used.  For example the following used to fail, but is now parsed correctly:
```
iex> {:ok, locale} = Cldr.validate_locale "en-US-u-co-ca", MyApp.Cldr
{:ok,
 %Cldr.LanguageTag{
   canonical_locale_name: "en-Latn-US",
   cldr_locale_name: "en",
   extensions: %{},
   gettext_locale_name: nil,
   language: "en",
   language_subtags: [],
   language_variant: nil,
   locale: %{calendar: "gregory", collation: "standard"},
   private_use: [],
   rbnf_locale_name: "en",
   requested_locale_name: "en-US",
   script: "Latn",
   territory: "US",
   transform: %{}
 }}
```

* Fix a race condition when starting up the compile-time locale cache

# Changelog for Cldr v2.2.7

This is the changelog for Cldr v2.2.7 released on February 23rd, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

Correctly validates locales that are not pre-compiled into a backend. At compile time, all configured locales are generated from the CLDR data.  However not all valid locales can be predefined - especially those that have variants, subtags or extensions or use a different casing to the canonical form.

For example, the following would fail in prior releases even though it is perfectly valid since language tags are defined to be case insensitive:
```
iex> MyApp.Cldr.validate_locale "en-au"
{:error, {Cldr.UnknownLocaleError, "The locale \"en-au\" is not known."}}

```
Similarly, it is expected that both the POSIX and IEEE formats of a language tag are acceptable, meaning that a `-` or `_` should be acceptable. Again, in prior releases this would result in an error:
```
iex> MyApp.Cldr.validate_locale "en_AU"
{:error, {Cldr.UnknownLocaleError, "The locale \"en_AU\" is not known."}}

```
Lastly, when using locale extensions, subtags or variants the validation would fail:
```
MyApp.Cldr.validate_locale "en-u-ca-buddhist"
{:error, {Cldr.UnknownLocaleError, "The locale \"en_AU\" is not known."}}
```
Each of these examples now correctly validates:
```
iex> TestBackend.Cldr.validate_locale "en-au"
{:ok,
 %Cldr.LanguageTag{
   canonical_locale_name: "en-Latn-AU",
   cldr_locale_name: "en-AU",
   extensions: %{},
   gettext_locale_name: "en",
   language: "en",
   language_subtags: [],
   language_variant: nil,
   locale: %{},
   private_use: [],
   rbnf_locale_name: "en",
   requested_locale_name: "en-AU",
   script: "Latn",
   territory: "AU",
   transform: %{}
 }}
iex> TestBackend.Cldr.validate_locale "en_au"
{:ok,
 %Cldr.LanguageTag{
   canonical_locale_name: "en-Latn-AU",
   cldr_locale_name: "en-AU",
   extensions: %{},
   gettext_locale_name: "en",
   language: "en",
   language_subtags: [],
   language_variant: nil,
   locale: %{},
   private_use: [],
   rbnf_locale_name: "en",
   requested_locale_name: "en-AU",
   script: "Latn",
   territory: "AU",
   transform: %{}
 }}
iex> TestBackend.Cldr.validate_locale "en-u-ca-buddhist"
{:ok,
  %Cldr.LanguageTag{
    canonical_locale_name: "en-Latn-US",
    cldr_locale_name: "en",
    extensions: %{},
    gettext_locale_name: "en",
    language: "en",
    language_subtags: [],
    language_variant: nil,
    locale: %{calendar: :buddhist},
    private_use: [],
    rbnf_locale_name: "en",
    requested_locale_name: "en",
    script: "Latn",
    territory: "US",
    transform: %{}
}}
```

# Changelog for Cldr v2.2.6

This is the changelog for Cldr v2.2.6 released on February 23rd, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Adds `Cldr.Config.territory_currency_data/0` that maps a territory code (like "US") to a list of currencies reflecting the historic and current usage of currencies in that territory.

# Changelog for Cldr v2.2.5

This is the changelog for Cldr v2.2.5 released on February 18th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Remove most dialyzer errors

* Fix documentation syntax errors

* Fix regex for parsing currency names into currency strings

# Changelog for Cldr v2.2.4

This is the changelog for Cldr v2.2.4 released on February 10th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Ensure the global default locale (currently "en-001") is always configured

### Enhancements

* Log a warning if a CLDR provider module could not be found

# Changelog for Cldr v2.2.3

This is the changelog for Cldr v2.2.3 released on February 9th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Fix parsing of currency names that have date ranges or annotations within them like "US dollar (next day)" and "Afghan afghani (1927–2002)"

# Changelog for Cldr v2.2.2

This is the changelog for Cldr v2.2.2 released on February 9th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* add `Cldr.Config.currencies_for/2` to return a map of the currency definition for a locale

# Changelog for Cldr v2.2.1

This is the changelog for Cldr v2.2.1 released on January 30th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Correctly add the `gettext` locale to the language tag returned by `<backend>.default_locale` and `Cldr.default_locale/2`.  Thanks to @erikreedstrom.  Closes #106.

### Enhancements

* Added a section on migrating from `Cldr` 1.x to 2.x.

# Changelog for Cldr v2.2.0

This is the changelog for Cldr v2.2.0 released on December 23nd, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Bump `nimble_parsec` to version 0.5 which has some breaking changes from 0.4 that affects the language tag parser.

* Use `IO.warn/1` for compiler warnings related to global configuration and Cldr providers configuration for a backend.

# Changelog for Cldr v2.1.0

This is the changelog for Cldr v2.1.0 released on December 1st, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Don't issue a bogus global config deprecation warning.

### Enhancements

* Revises the Cldr provider strategy - again. Rather than try to auto-discover available provider modules and configuring them automatically they are now configured under the `:provider` key.  The [readme](/readme.html#providers) contains further information on configuring providers. For example:

```
defmodule MyApp.Cldr do
  use Cldr,
    locales: ["en", "zh"],
    default_locale: "en",
    providers: [Cldr.Number, Cldr.List]
end
```

The default behaviour is the same as `Cldr 2.0` in that all known cldr providers are configured.

# Changelog for Cldr v2.0.4

This is the changelog for Cldr v2.0.4 released on November 26th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug fixes

* Dependency plugin check was using `Mix.Project.in_project/3` which actually changes directory which during compilation is a bad thing (since compilation is in parallel and within a single Unix process).  The plugin dependency list is now static.  Thanks to @robotvert. Closes #93.

# Changelog for Cldr v2.0.3

This is the changelog for Cldr v2.0.3 released on November 25th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug fixes

* Check for a `json` library existence as early as possible in the compile cycle since it is required during compilation of `Cldr`.

# Changelog for Cldr v2.0.2

This is the changelog for Cldr v2.0.2 released on November 24th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Move minimal Decimal version to 1.5

### Bug fixes

* `Cldr.Substitution.substitute/2` now conforms to its documentation and substitutes a list of terms into a list format

# Changelog for Cldr v2.0.1

This is the changelog for Cldr v2.0.1 released on November 22, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug fixes

* Fixes a bug whereby a backend configured with locales, but no default locale (and no global configuration), would crash during compilation

# Changelog for Cldr v2.0.0

This is the changelog for Cldr v2.0.0 released on November 22, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

See also [Breaking Changes](#breaking-changes) below.

* Transforms the regex's for currency spacing to be compatible with the elixir regex engine.  This supports improved conformance for currency formatting in [ex_cldr_numbers](https://hex.pm/packages/ex_cldr_numbers)
* Removes the need for Phoenix as a dependency in tests.  Thanks to @lostkobrakai.  Closes #84.
* Print deprecation message if the global config is used for more than :json_library and :default_locale
* Align `Cldr/get_locale/1/0` and `Cldr.put_locale/2/1` with Gettext.  See `Cldr.get_locale/1`, `Cldr.get_locale/0`, `Cldr.put_locale/2` and `Cldr.put_locale/1`
* Improve performance of `Cldr.Gettext.Plural` and align its return better with `Gettext`
* Add the 'miscellaneous' number formats to the locale definition files.  This allows formatting of "at least", "approximately", "at most" and "range". These formats will be used in [ex_cldr_numbers](https://hex.pm/packages/ex_cldr_numbers).

### Purpose of the changes

Version 2.0 of Cldr is focused on re-architecting the module structure to more closely follow the model set by Phoenix, Ecto, Gettext and others that also rely on generating a public API at compile time. In Cldr version 1.x, the compile functions were all hosted within the `ex_cldr` package itself which has created several challenges:

* Only one configuration was possible per installation
* Dependency compilation order couldn't be determined which meant that when Gettext was configured a second, forced, compilation phase was required whenever the configuration changed
* Code in the ex_cldr _build directory would be modified when the configuration changed

### New structure and configuration

In line with the recommended strategy for configurable library applications, `Cldr` now requires a backend module be defined that hosts the configuration and public API.  This is similar to the strategy used by `Gettext`, `Ecto`, `Phoenix` and others.  These backend modules are defined like this:

    defmodule MyApp.Cldr do
      use Cldr, locales: ["en", "zh"]
    end

For further information on configuration, consult the [readme](/readme.html).

### Migrating from Cldr 1.x to Cldr version 2.x

Although the api structure is the same in both releases, the move to a backend module hosting configuration and the public API requires changes in applications using Cldr version 1.x.  The steps to migrate are:

1. Change the dependency in `mix.exs` to `{:ex_cldr, "~> 2.0"}`
2. Define a backend module to host the configuration and public API.  It is recommended that the module be named `MyApp.Cldr` since this will ease migration through module aliasing.
3. Change calls to `Cldr.function_name` to `MyApp.Cldr.function_name`.  The easiest way to do this is to alias the backend module.  For example:

```
defmodule MyApp.SomeModule do
# alias the backend module so that calls to Cldr functions still work
  alias MyApp.Cldr

  def some_function do
    IO.puts Cldr.known_locale_names
  end
end
```
### Breaking Changes

* Configuration has changed to focus on the backend module, then otp app, then global config.  All applications are required to define a backend module.
* The Public API moves to a configured backend module. Functions previous called on `Cldr` should be called on `MyApp.Cldr`.
* The `~L` sigil has been removed.  The public api functions support either a locale name (like "en") or a language tag.
* `Cldr.Plug.AcceptLanguage` and `Cldr.Plug.SetLocale` need to have a config key :cldr to specify the `Cldr` backend to be used.
* The `Mix` compiler `:cldr` is obsolete.  It still exists so configuration doesn't break but its no a `:noop`.  It should be removed from your configuration.
* `Cldr.Config.get_locale/1` now takes a `config` or `backend` parameter and has become `Cldr.Config.get_locale/2`.
* `Cldr.get_current_locale/0` is renamed to `Cldr.get_locale/0` to better align with `Gettext`
* `Cldr.put_current_locale/1` is renamed to `Cldr.put_locale/1` to better align with `Gettext`

