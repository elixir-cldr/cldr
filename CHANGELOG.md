## Changelog for Cldr v0.0.12 December 6, 2016

The last set of bugs have come from areas of the code which depends on different compilation environments:

* Whether `gen_stage` is installed (its used in the locale consolidation process only, and that process isn't relevant to anyone except a Cldr developer)

* Whether all locales are installed or not and hence whether a locale needs to be donwloaded.  Locales are installed at compile time and which locales depends on configuration.

Neither of these test case is easy to test with the standard `ExUnit` assertions for good reasons.  Following advice from José I'll look at what Phoenix does and craft a test harness prior to releasing version 0.1.0.

### Bug fixes

* Fixed compilation error when gen_stage is installed.

* Fixed some formatting issues in README.md

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