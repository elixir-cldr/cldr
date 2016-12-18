## Changelog for Cldr v0.0.16

This release is primarily about optmising parts of the number formatting pipeline through a combination of code optimization and additional compile-time calculations.

The comparison below shows that for an integer formatted with the standard format (default) this version is reduced from 42 µs/op to 10 µs/op or about 70% performnce improvement.  However, its worth remembering that this is more than 2 orders of magnitude slower than simply calling `Integer.to_string/1`.

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