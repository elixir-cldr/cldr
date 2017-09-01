## Changelog for Cldr v0.6.0 September 1st, 2017

### Breaking Changes

* `Cldr.Rbnf.Config.get_locale/1` now returns `{ok, rbnf}` or `{:error, reason}`.  The original behaviour is now implemented in `Cldr.Rbnf.Config.get_locale!/1` which will return `rbnf` or raise an exception.  This function is typically used only at compile time to generate ruleset functions so is unlikely to affect user code.  However it is a breaking change hence the version adjustment.

### Enhancements

* Add `Cldr.Currency.pluralize/3` to pluralize a currency's name

* Add `Cldr.Number.to_number_system/2` to convert a number to a specific number system.  This is number system conversion only - there is no number formatting applied.

* Add `Cldr.Number.System.to_system/2` that provides the conversion that underpins `Cldr.Number.to_number_system/2`

* Add `Cldr.Number.known_number_systems/0` that returns all the number systems defined in CLDR.

* `Cldr.Number.Formatter.Decimal` and `Cldr.Decimal.Format.Compiler` have been refactored to generate a specific formatting pipeline for each of the known decimal formats at compile time. The intent is to be able to optimize the pipeline for each format to maximise performance.  There is definitely room for optimization.  This change does not affect the public API.

* `Cldr.Rbnf.Config.get_locale/1` used to generate functions to hold RBNF data.  This data is nearly 1Mb per locale and since it is only used at compile time to generate ruleset functions it was an unnecessary memory overhead.  On a development environment with 11 locales, memory usage dropped from 46Mb to 37Mb with this change.  Current behaviour now reads the RBNF data from the source data files when requested.  Since this content is cached in ETS at compile time via `Cldr.Config.get_locale/1` in a change introduced in version 0.5.0 the additional compilation overhead seems acceptable.

* The approach to caching locale data during compilation is now encapsulated in module `Cldr.Locale.Cache`. This architecture improves the cache hit rate and reduces compilation time by 24% over [ex_cldr version 0.5.2](https://hex.pm/packages/ex_cldr/0.5.2) and by 40% over [version 0.4.2](https://hex.pm/packages/ex_cldr/0.4.2).  These comparisons are all using Elixir 1.5.1 on OTP 20.

  | Cldr version | Compile time for 516 locales | % Improvement |
  | ------------ | ---------------------------: | ------------: |
  | 0.4.2        | 137s                         |  -            |
  | 0.5.2        | 108s                         |  21%          |
  | 0.6.0        | 82s                          |  24%          |

## Changelog for Cldr v0.5.2 August 24, 2017

### Enhancements

* Revert the commit that produced the message "[ex_cldr] Installing locale ..." since it's too noisy

## Changelog for Cldr v0.5.1 August 23, 2017

## Bug Fixes

* Refactor locale downloading to ensure that the downloading process is single-threaded.  The mechanism in v0.5.0 downloaded locales during compilation but because of multiple compilations happening in parallel this created a window whereby locales were being downloaded multiple times and a race condition could also create an exception at compile time.

* `Cldr.version/0` was returning the version as a 3-tuple of strings.  The correct format should have been a 3-tuple of integers.  This is now corrected.

## Changelog for Cldr v0.5.0 August 19, 2017

### Breaking Changes

* ex_cldr now requires Elixir 1.5 or greater since it required support for `Calendar` conversion funcitons and for utf-8 atoms.

* Cldr is now broken into separate packages. This package [ex_cldr](https://hex.pm/packages/ex_cldr) is a dependency for all other Cldr packages.  It includes the core functionality required by all modules, including number formatting.

* `Cldr.List` and `Cldr.Unit` which were previously included in the the [ex_cldr](https://hex.pm/packages/ex_cldr) package are now in their own packages which must be added separately as dependencies.  These packages are [ex_cldr_lists](https://hex.pm/packages/ex_cldr_lists) and [ex_cldr_units](https://hex.pm/packages/ex_cldr_units)

* `Cldr.DateTime.Relative` is not included in this package.  It will be reintroduced into `ex_cldr` version 0.7.0 along with full date, time and datetime localisation.

### Enhancements

* Adds `Cldr.valid_locale?/1` that returns an `{:ok, locale}` or `{:error, {exception, message}}` that is friendlier to use in a `with` function

* Standardise `to_string/2` functions return either a `{:ok, result}` or `{:error, reason}` tuple.  The various "!" versions such as `to_string!/2` return a result string or raise an exception.

## Changelog for Cldr v0.4.2 July 9, 2017

### Bug Fixes

* Installation of a new default locale was failing due a compilation order dependency issue.  Fixes #17.

## Changelog for Cldr v0.4.1 May 29, 2017

### Enhancements

* Replace the two deprecated calls to `Integer.to_char_list/1` with `Integer.to_charlist/1` for Elixir 1.5 compatibility

## Changelog for Cldr v0.4.0 May 29, 2017

This release introduces some breaking changes as described below.  However the changes do not affect the primary public api of `to_string/2` used in `Cldr.Number`, `Cldr.List`, `Cldr.Unit`except insofaras an error return is now standardised as an `{:error, {exception, nessage}}` tuple.  Therefore chances are that library users won't notice.

### Breaking Changes

* `Cldr.get_locale/0` is renamed to `Cldr.get_current_locale/0` to better reflect its intent

* `Cldr.set_locale/1` is renamed to `Cldr.set_current_locale/1` to better reflects its intent

* `Cldr.Locale.get_locale/1` has moved to `Cldr` and is now invoked as `Cldr.get_locale/1`.

* `Cldr.get_locale/1` now returns a type `%Cldr.Locale{}` rather than the previous `Map.t`.  This will affect applications that use the `Access` behaviour or `Enumerable` protocol on a `Locale` since this are not supported on `structs`.

* Functions that used to `raise` on error now do not.  Instead a standard error tuple is returned of the form `{:error, {exception_module, message}}`.  For many of these functions a `bang` version also now exists which will raise on error.  This change reflects the community view that library packages shouldn't raise exceptions.

## Changelog for Cldr v0.3.0 May 22, 2017

### Breaking Change

* Module `Cldr.Date.Relative` is renamed to `Cldr.DateTime.Relative`.  Since this is a breaking change, a minor version bump to 0.3.0 is made.

### Enhancements

* Allow configuration of number system digit transliterations that are precompiled. See `Cldr.Number.Transliteration` module docs for further information.

### Bug Fixes

* Fixed a bug whereby `Cldr.Number.Transliterate/3` with a `binary` number system would fail

## Changelog for Cldr v0.2.1 May 22, 2017

### Enhancements

* Added `Cldr.Number.Transliterate/3` to transliterate a binary of digits from one number system to another.

## Changelog for Cldr v0.2.0 April 27, 2017

### Enhancements

* Adds module `Cldr.Date.Relative` to provide relative date and datetime formatting such as "2 days ago" or "in 1 week" or "yesterday". See `Cldr.Date.Relative`, in particular `Cldr.Date.Relative.to_string/2`

* Supports Elixir 1.4.x only (`Cldr.DateTime.Relative` uses `Date.utc_today/0` and `DateTime.utc_now` which are not in earlier versions of Elixir).

* Support `Poison` as "~> 2.1 or ~> 3.0"

* Update all dependencies to latest versions

## Changelog for Cldr v0.1.3 April 17, 2017

### Enhancements

* Support the creation of custom currencies.  The currency code must follow the ISO4217 format for custom currencies which must start with an 'X' followed by 2 alphabetic characters.  See `Cldr.Currency.new/2`

* Improve error handling for `Cldr.Number.to_string/2` to return a standardised error tuple of the form `{:error, {exception_module, binary_message}}`

* Increased test timeout from the default 60,000 to 120,000 since slow machines may not complete the tests in time

* Update to CLDR 30.0.1.  Version can always be determined from `Cldr.version/0`

## Changelog for Cldr v0.1.2 April 11, 2017

### Enhancements

* Improves the sourcing of avaialable currency codes with a small performance improvement in detecting known currency codes

## Changelog for Cldr v0.1.1 April 8, 2017

### Enhancements

* Improves the validation of currency codes as well as the related tests

## Changelog for Cldr v0.1.0 March, 23, 2017

### Enhancements

* Updates to CLDR release 31.  There are some minor output differences (for example, ordinal number formatting for negative numbers in the Indonesian locale) therefore the minor version bump.  Further information can be found in the [CLDR Release Notes](http://cldr.unicode.org/index/downloads/cldr-31)

### Bug Fixes

* Ads an assertion to the data consolidation process to ensure that required files are configured in `mix.exs` package files

## Changelog for Cldr v0.0.20 February 27th, 2017

### Bug Fixes

* Adds `version.json` to the package definition, the lack of which was preventing compilation for the hex package (was not an issue with a github installation)

## Changelog for Cldr v0.0.19 February 26th, 2017

### Enhancements

* Adds `Cldr.Unit` to support CLDR units localization.  See `Cldr.Unit` and `Cldr.Unit.to_string/3`

### Bug Fixes

* Corrects pluralization for locales that have a territory element (like "en-AU").  Plural rules are only defined on base locales (like "en") so when pluralizing we always use the base local to look up the plural rules

## Changelog for Cldr v0.0.18 February 21st, 2017

### Enhancements

* `Cldr.version/0` returns the version of the CLDR repository in use.  This is now automatically derived from the library data.

## Changelog for Cldr v0.0.17 February 20th, 2017

### Bug fixes

* Fixes `Cldr.Number.PluralRule.pluralize/3` by adding support for `%Decimal{}`.  Thanks to @jayjun

## Changelog for Cldr v0.0.17 February 19th, 2017

### Bug fixes

* Removes Ecto as a dependency since it is not required

### Enhancements

* Updated CLDR to version 30.0.2

* Changed the result of `Cldr.version()` to return the version of the `CLDR` data repository being used.  As of now this is a manual update, in the future it will be derived automatically.  Currently the version is `{30,0,2}`.

* Allows configuration-defined number formats that are precompiled.  Precompiled formats execute approximately twice as fast since the lex/parse process is not required.  In your `config.exs` use the key `precompile_number_formats`.

```
  config :ex_cldr,
    precompile_number_formats: ["¤¤#,##0.##"]
```

## Changelog for Cldr v0.0.16

This release is primarily about optmising parts of the number formatting pipeline through a combination of code optimization and additional compile-time calculations.

The comparison below shows that for an integer formatted with the standard format (default) this version is reduced from 42 µs/op to 10 µs/op or about 70% performnce improvement.  However, its worth remembering that this is more than two orders of magnitude slower than simply calling `Integer.to_string/1`.

The performance improvements come from hand tuning the pipeline for the default format for integers and floats.  Uncompiled formats are the slowest since they have to pass through the lexing and parsing phases.  For locales other than "en", the overhead of transliterating the digits and symbols adds additional time.  Currency formatting adds about 10% to a normal float time for the lookup of the currency symbol and rounding information as well as assembling the final format.

### v0.0.15 Number.Format.Test
benchmark name                              iterations   average time
Decimal.to_string                             10000000   0.51 µs/op
Format compiled standard format: integer         50000   42.00 µs/op
Format compiled currency {en, latn}              50000   51.78 µs/op
Format compiled number {fr, latn}                50000   54.74 µs/op
Format uncompiled number                         10000   117.74 µs/op
Significant digits format                        10000   147.83 µs/op

### v0.0.16 Number.Format.Test
benchmark name                                 iterations   average time
Format Integer.to_string                        100000000   0.01 µs/op
Decimal.to_string                                10000000   0.52 µs/op
Format compiled standard format: integer           100000   10.16 µs/op
Format compiled number {fr, latn}: integer         100000   29.17 µs/op
Format compiled number standard format: float       50000   44.10 µs/op
Format compiled currency {en, latn}                 50000   46.02 µs/op
Format compiled number {fr, latn}: float            50000   71.21 µs/op
Significant digits format                           10000   105.23 µs/op
Format uncompiled format: float                     10000   113.80 µs/op

All tests run on a first generation Macbook which is no speed demon.  The absolute numbers are less important than the relative performance.

### Enhancements

* Adds support for a `:fractional_digits` option for `Cldr.Number.to_string/2` which overrides the number of fractional digits to be displayed.  The number is rounded to this number of digits before display.

* Add hand-tuned formatting pipeline for integer and floats that use the standard format.  Performance in these circumstances is improved by about 70%.

* Improved algorithm for grouping digits in `Cldr.Number.to_string/2` is 30% faster than the previous implementation

* Precompile the list substitution templates used by `Cldr.List.to_string/2` delivers around 100x performance improvement.  This affects the format types :currency_long positively as well.

* Precompile the number of 0 digits in a short format which improves performance of short number formatting by 50%

### Bug fixes

* Fixed number formatting error that occured when a small fraction would round to zero

* Fixed number formatting error that produced "-0" instead of "0" for small fractions that rounded to zero

* Fixed short and long formatting of currencies which would previously display the default currency number of fractional digits.  These now correctly default to zero.

## Changelog for Cldr v0.0.15 December 12, 2016

### Bug fixes

* Fixed a bug whereby Cldr.Math.log would return invalid results for a Decimal with precision greater 64 bits.

* Added poison and decimal to the application section of mix.exs

## Changelog for Cldr v0.0.14 December 11, 2016

### Enhancements

* Additional updates to docs content and formatting

* Significant refactoring of decimal formatting engine.  About 10% faster than the previous implementation.  This version works on io_lists rather than strings and there is room for performance optimisation.

* Fixed an issue whereby compiled formats weren't being inserted into the AST.  Compiled formats now execute approximately twice as fast as non-compiled formats.  All formats defined in CLDR are compiled so most applications should benefit from the speedup.

## Changelog for Cldr v0.0.13 December 11, 2016

### Bug fixes

* `Cldr.Plug` is not complete and won't compile if `Plug` is loaded as it will be for Phoenix applications.  For now, `Cldr.Plug` will not be compiled.

## Changelog for Cldr v0.0.12 December 6, 2016

The last set of bugs have come from areas of the code which depends on different compilation environments:

* Whether `gen_stage` is installed (its used in the locale consolidation process only, and that process isn't relevant to anyone except a Cldr developer)

* Whether all locales are installed or not and hence whether a locale needs to be donwloaded.  Locales are installed at compile time and which locales depends on configuration.

Neither of these test case is easy to test with the standard `ExUnit` assertions for good reasons.  Following advice from José I'll look at what Phoenix does and craft a test harness prior to releasing version 0.1.0.

### Enhancements

* Moved the files related to json consolidation out of the hex package since the process of downloading and transforming the CLDR repository is not a packages responsibility - only a developers.

### Bug fixes

* Fixed compilation error when gen_stage is installed.

* Fixed some formatting issues in README.md and noted that we use now using CLDR 30.0.2

* `Cldr.Number.to_string 1234, currency: :AUD` should default to format `:currency` but it was defaulting to format `:standard`.

## Changelog for Cldr v0.0.11 December 5, 2016

### Bug fixes

* Fixed a small issue that would prevent locales from downloading if ex_cldr was being run from the github repo

## Changelog for Cldr v0.0.10 December 5, 2016

### Bug fixes

* Detecting the version of Cldr at compile time fixed by checking both the mixfile version number if there's no existing ex_cldr app and checking the application spec if there is

## Changelog for Cldr v0.0.9 December 5, 2016

### Bug Fixes

* Cldr is intended to download configured locales during compilation is the specified locale is not already installed.  Due to a developer misunderstanding of how the build process works and the treatment of the `priv` dir the download process was failing for packages installed from hex.  The process was not triggered for packages installed from github since all locales are configured in that case. The changes in this release do a much better job of managing the download process and of reflecting any errors that occur during the download.


## Changelog for Cldr v0.0.8 December 4, 2016

### Bug Fixes

* Ensure "root" locale is always configured since it is required for some RBNF functions

## Changelog for Cldr v0.0.7 December 3, 2016

### Enhancements

* Added `Cldr.Number.Ordinal.pluralize/3` and `Cldr.Number.Ordinal.pluralize/3` which takes a number and uses plural rules to resolve a key used to return a map value.  For example:

```
  iex> Cldr.Number.Ordinal.pluralize 1, "en", %{one: "one"}
  "one"
```

* Now uses the [Unicode CDLR](https://github.com/unicode-cldr) repository as the source of CLDR json data.  Removed the now-obsolete mix tasks `cldr.download` and `cldr.convert`

* Adds support for RBNF (Rule based number formatting) to output numbers in words, as a year, in roman numerals and in several other locale-depeendent formats

### Bug Fixes

* Fixed issue #5 so that `Number.to_string/2` will correctly resolve the appropriate number system for the specified locale

* Fixed issue #6 whereby RBNF rulesets which have access "private" were being defined by :def and are now :defp

## Changelog for Cldr v0.0.6 November 25, 2016

### Enhancements

* Updated the CLDR repository to 30.0.2 released on 2016-10-17.  See [the CLDR web site](http://cldr.unicode.org/index/downloads/cldr-30) for release details

## Changelog for Cldr v0.0.5 October 9, 2016

### Enhancements

* Add new function `Cldr.Number.Math.root/2` which calculates the nth root of a number.

## Changelog for Cldr v0.0.4 October 6, 2016

### Bug Fixes

* Remove the test and bench dirs from the hex build

### Enhancements

* Revised the format of the json packaging used to generate `Cldr` functions.  As a result, the keys for currencies are now upcased atoms (previously they were downcased atoms) which more closely mirrors ISO4217

* Generated json for a locale now includes RBNF rule definitions.  These rules are not yet used but serve as the platform for the including RBNF generation in a near future release

## Changelog for Cldr v0.0.3 September 12, 2016

### Bug fixes

* Ensures that the client application data directory is created before installing additional locales

## Changelog for Cldr v0.0.2 September 12, 2016

### Enhancements

* Unbundled the CLDR repository data from hex package.  Locales are now downloaded at compile time if a configured locale is not already installed in the application.

### Bug fixes

* Fixes scientific formatting error whereby a forced "+" sign on the exponent was not displayed.  Closes #3.

## Changelog for Cldr v.0.0.1 September 6, 2016

* Initial release.