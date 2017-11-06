# Roadmap

`Cldr` aims to reach api stability by the end of 2017.  In order to reach that milestone the following are planned:

- [ ] Implement a new abnf parser generator for language tags.
- [ ] Update guides and move the relevant sections to the dependent packages (numbers, date_times, lists, units, ...)
- [ ] Review all `@doc` to ensure they and the examples are consistent in describing functions and arguments.
- [ ] Check consistency of the usage of key data items like `locale`, `currency`, `number system`, `territory`

### Parser generator for language tags

Based upon the exiting work in [this repo](https://github.com/vanstee/abnf) the parser generator will be faster than the current
parser/interpreter mechanism.  The code under development is at  [this repo](https://github.com/kipcole9/abnf).  For completion
the code requires:

* Better error handline
* Ability to include state and a way to invoke functions to update it

### Update guides

* Split the guides out into the dependent packages but keep the links in `Cldr` to keep a single reference work.

* Check that for the key formatters (numbers and dates/times) that the format description documents are clear and easy to understand

### Consistency of data items / Canonical data formats

Certain data items used frequently in `Cldr` and their usage should be in a normalised for so that a client library can rely upon such formats. The following is the definitive definition of how key data elements are represented:

* `locale_name` locale name is the `String.t` representation of a locale. It is the data type of the locale as defined in CLDR such as "en-US", "fr", "zh-Hant" as examples.

* `langauge` is the langauge part of a `locale_name` or `Locale`.  It is always a `String.t` and no attempt is ever made to convert it to an `atom`.

* A `locale` is the struct `Cldr.LanguageTag` that is returned by `Cldr.Locale.canonical_language_tag/1`.  This function takes a `locale_name` and returns a `Cldr.LanguageTag` struct.  This is the primary form of a `Cldr.Locale`

* A `currency` is represented by an upper-cased atom of a [ISO4217](https://www.iso.org/iso-4217-currency-codes.html) 3-character currency codes.  A currency code can be converted from acceptable forms (ie a String.t) by invoking `Cldr.validate_currency/1`.  Known currencies can be returned by `Cldr.known_currencies/0`

* A `territory` is represented by an upper-cased atom of a [UN M.49](https://en.wikipedia.org/wiki/UN_M.49) territory code

* A `number system` is interpreted as either a `String.t` in which case it is a number system as returned by `Cldr.known_number_systems/0` or as an `atom()` in which case it is intereted as a number system type. A number system type is designed to standardise the usage of number systems that are defined within a `Locale`. For example, each `Locale` defines a number system type `:default`.  If the number system is an `atom()` then it is resolved to an actual number system within the context of a `Locale`.

* A `calendar_name` is represented as a lower-cased `atom()`



