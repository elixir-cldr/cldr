# Changelog

## Cldr v2.34.0

This is the changelog for Cldr v2.34.0 released on October 19th, 2022.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

** Note that `ex_cldr` version 2.33.0 and later are supported on Elixir 1.11 and later only.**

### Enhancements

* Encapsulates [CLDR 42](https://cldr.unicode.org/index/downloads/cldr-42) data. Unless otherwise noted, all the changes are reflected in `ex_cldr` libraries and functions.

## Cldr v2.33.2

This is the changelog for Cldr v2.33.2 released on August 28th, 2022.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

** Note that `ex_cldr` version 2.33.0 and later are supported on Elixir 1.11 and later only.**

### Bug Fixes

* Fixes a bug in `Cldr.LanguageTag.Sigil.sigil_l/2`. With the changes in metadata structure for Elixir 14 a pattern match was failing. The pattern is now fixed and is backwards compatible with earlier Elixir versions.

## Cldr v2.33.1

This is the changelog for Cldr v2.33.1 released on August 20th, 2022.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

** Note that `ex_cldr` version 2.33.0 and later are supported on Elixir 1.11 and later only.**

### Enhancements

* Now delegates locale installation to `Cldr.Http.get/2` in the [cldr_utils](https://hex.pm/packages/cldr_utils) library so that we can centralise request handling and provide an "unsafe TLS" option for downloading to support resolution of [#184](https://github.com/elixir-cldr/cldr/issues/184).

## Cldr v2.33.0

This is the changelog for Cldr v2.33.0 released on July 31st, 2022.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

** Note that `ex_cldr` version 2.33.0 and later are supported on Elixir 1.11 and later only.**

### Enhancements

* Removes warnings for Elixir 1.14.  As a result `ex_cldr` now supported Elixir 1.11 and later only (support for Elixir 1.10 has been discontinued).

* Allow either `ratio 2.x` or `ratio 3.x` depdendencies to be configured. This library is only used during the development of `ex_cldr` and is not normally used by library consumers. However [ex_cldr_units](https://hex.pm/packages/ex_cldr_units) does use `ratio` so this flexibility helps downstream maintenance, especially when `ratio` is updated to avoid Elixir 1.14 deprecation warnings.

## Cldr v2.32.1

This is the changelog for Cldr v2.32.1 released on July 26th, 2022.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Don't use `IO.warn/2` when compiling a backend and a known Gettext locale can't be matched to a Cldr locale.  `IO.warn/2` will cause errors if the compilation setting `warnings_as_errors: true` is set.  Instead, these messages will be output as a "note" that does not trigger warnings. In addition the error message has been improved to make clear that although the Gettext locale has no Cldr equivalent, it will still be matched at runtime.  See the conversation at https://elixirforum.com/t/bridging-locale-name-differences-between-ex-cldr-gettext. Thanks to @lenards for the report.

## Cldr v2.32.0

This is the changelog for Cldr v2.32.0 released on July 23rd, 2022.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Fix `Cldr.with_locale/{2, 3}` to source the current locale from the backend of the supplied new locale.  This reduces the chances of an exception resulting from a non-existent default backend and a default locale that is not set.

### Enhancements

* Add `with_locale/2` to Cldr backend modules. This ultimately delegates to `Cldr.with_locale/{2, 3}`

## Cldr v2.31.0

This is the changelog for Cldr v2.31.0 released on July 6th, 2022.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Adds `Cldr.Locale.script_from_locale/{1, 2}` and `Cldr.default_script/0`.

## Cldr v2.30.0

This is the changelog for Cldr v2.30.0 released on June 5th, 2022.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Adds a backend module for `AcceptLanguage` which defines `MyApp.Cldr.AcceptLanguage.parse/1` and `MyApp.Cldr.AcceptLanguage.best_match/1`

## Cldr v2.29.0

This is the changelog for Cldr v2.29.0 released on May 10th, 2022.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Migration

* The plugs `Cldr.Plug.SetLocale`, `Cldr.Plug.AcceptLanguage` and `Cldr.Plug.PutSession` have been extracted to their own library, [ex_cldr_plugs](https://hex.pm/packages/ex_cldr_plugs). Therefore adding `{:ex_cldr_plugs, "~> 1.0"}` to the `deps` of any application using these plugs is required.

### Bug Fixes

* Fixes resolving the RBNF locale name for locales that inherit the RBNF locale from a parent. This is true for at least the "nb" locale which in previous releases had its own RBNF locale data but now inherits from "no". Thanks to @juanperi for the report. Closes [#175](https://github.com/elixir-cldr/cldr/issues/175).

## Cldr v2.28.0

This is the changelog for Cldr v2.28.0 released on April 6th, 2022.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Update [CLDR](https://cldr.unicode.org) to [release 41](https://cldr.unicode.org/index/downloads/cldr-41). This is minor CLDR release adding `en-MV`, `hi-Latn` and `ks-Deva` locales and continuing data improvements on unit grammar. Changes to locales in this release can be found on the [locale change](https://unicode-org.github.io/cldr-staging/charts/41/delta/index.html) page.

## Cldr v2.27.1

This is the changelog for Cldr v2.27.1 released on March 8th, 2022.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Don't depend on CLDR production data being available at compile time in the hex package (since it won't be available at all!). Eggregious error inserted in release 2.27.0. Thanks to @dkln for the report. Closes #170.

## Cldr v2.27.0

This is the changelog for Cldr v2.27.0 released on March 8th, 2022.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Remove spurious `Cldr.Trans` module. The new [ex_cldr_trans](https://hex.pm/packages/ex_cldr_trans) provides this capability.

### Enhancements

* Add `:host` to the list of places that `Cldr.Plug.SetLocale` can look for to derive a locale for a request.

* Add `Cldr.Locale.fallback_locale_names!/1` to return the locale fallback chain or raise an execption.

* Add `Cldr.with_locale/2` to execute a function with the process locale set to a given locale. The current locale is put back in place after the function executes.

* Add `Cldr.Locale.is_locale_name/1` guard.  This is an area that needs some cleanup since we have
  * `Cldr.is_locale_name/1` that permits atoms and strings since it is used to guard functions that might use `Cldr.validate_locale/2`. Therefore this is most useful for functions that take user input.
  * `Cldr.Locale.is_locale_name/1` that permits only atom locale names since this the canonical form.

## Cldr v2.26.3

This is the changelog for Cldr v2.26.3 released on February 24th, 2022.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Fix spec of `Cldr.put_locale/2`. Thanks to @alappe for the report. Closes #167.

## Cldr v2.26.2

This is the changelog for Cldr v2.26.2 released on February 22nd, 2022.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Fix `Cldr.Locale.canonical_language_tag/3` for cases when the `:add_likely_subtags` is `false` and the locale name is `known`.

## Cldr v2.26.1

This is the changelog for Cldr v2.26.1 released on February 21st, 2022.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Fix `Cldr.locale_and_backend_from/2` for atom locales. Since this is a private API there should be no upstream issues with dependent libraries.

## Cldr v2.26.0

This is the changelog for Cldr v2.26.0 released on February 21st, 2022.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### LanguageTag structure changes

* `Cldr.LanguageTag.t` has been revised with the `:cldr_locale_name` and `:rbnf_locale_name` now being atoms rather than binaries.  This is unlikely to affect client code. The primary benefit, apart from a slightly improved memory space, is the easier integration planned with the [trans](https://hex.pm/packages/trans) library.

### Bug Fixes

* Fix setting the default backend with `Cldr.put_default_backend/1` which wasn't actually being set.

* Fix `Config.message_formats` to default to an empty map, not an empty list.

* Fix `Cldr.Locale.parents/1` to return an `{:ok, list}` tuple on success rather than a bare list.

* Fix `<backend>.Cldr.Number.{Cardinal, Ordinal, Spellout}.pluralize/3` for non-integer `Decimal` numbers.

### Enhancements

* Add `<backend>.Trans` module to support closer integration with the [trans](https://hex.pm/packages/trans) for database translations.

* Add `Cldr.Locale.fallback_locales/1` to return the list of recursively created parent locales, including the provided locale. This can be used to support resolving translations from a system that might be sparsely populated.

* Add `Cldr.Locale.fallback_locale_names/1` that returns the `:cldr_locale_name` component of the locales returned by `Cldr.Locale.fallback_locales/1`.

* Adds `Cldr.Locale.locale_from_territory/{1,2}` to derive a "best fit" locale for a given territory. Also adds `<backend>.Locale.locale_from_territory/1`.

* Adds `Cldr.Locale.locale_from_host/{2, 3}` to derive a "best fit" locale for a given host name. Also adds `<backend>.Locale.locale_from_host/2`.

* Adds `Cldr.Locale.territory_from_host/1` to return the territory for a given host name. Also adds `<backend>.Locale.territory_from_host/1`.

* Adds `Cldr.Locale.consider_as_tlds/0` to return a list of valid territory suffixes that are considered as generic TLDs instead.  See https://developers.google.com/search/docs/advanced/crawling/managing-multi-regional-sites.

* Adds `Cldr.Locale.languages_for_territories/0` to return a mapping of territories to that territory's most spoken language.

* Adds `Cldr.put_gettext_locale/1` that sets the `gettext` locale for a given `t:Cldr.LanguageTag`.

* Adds `Cldr.TestHelper` module in `test/suport` to provide testing helpers.  Initially provides `with_no_default_backend/1` function.

## Cldr v2.25.0

This is the changelog for Cldr v2.25.0 released on December 16th, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Fixes configuring locales when the default locale is in posix form (ie like `en_GB`) as apposed to BCP47 form (ie `en-GB`). In fixing this bug, forming the normalised list of configured locales is now also standarised. Thanks to @gazzer82 for the report. Closes #165.

### Enhancements

* Implement `Cldr.Gettext.Plural` allowing the creation of [gettext](https://hexdocs.pm/gettext) [plural forms](https://hexdocs.pm/gettext/Gettext.Plural.html#content) modules.

## Cldr v2.24.2

This is the changelog for Cldr v2.24.2 released on December 5th, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Obviate compiler warning for `Code.can_await_module_compilation?/0` on Elixir versions where the function does not exist. Thanks to @DaTrader for the report.

### Enhancements

* Apply `@external_resource` for each configured locale in backend modules.

## Cldr v2.24.1

This is the changelog for Cldr v2.24.1 released on November 1st, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Fix compilation performance regression when compiling `ex_cldr` on Elixir 1.13.  `ex_cldr` has relied upon a private API in Elixir to detect when compilation is in progress and to then cache locale files. This improves compilation performance when many locales are configured by up to 6x. However the private API has changed in Elixir 1.13 and there is now a public API as well (hooray!).  Thanks very much to @josevalim for the support as always, and for the PR that fixed the issue.

## Cldr v2.24.0

This is the changelog for Cldr v2.24.0 released on October 27th, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Updated to [CLDR 40](https://cldr.unicode.org/index/downloads/cldr-40) data. In addition, the canonical format of some data has changed; for example subdivisions are now atoms, not strings. This change is primarily of interest to authors writing libraries that use the raw underlying locale data.

### Bug Fixes

* Fixes an issue with the locale loader which was incorrectly atomizing date part keys in date/time formats and conversely incorrectly stringifying the number system in the same formats.

* `Cldr.validate_territory_subdivision/1` was case sensitive and didn't correctly handle atoms and binaries. Required to support `ex_cldr_territories` properly.

* Correctly atomize the keys for the locale display names "language" types.

* `Cldr.Plug.PutSession` now uses the locale key `:canonical_locale_name` to serialize to the session. Previously it was using `:cldr_locale_name` which does not include any of the extension information. Extension information encodes user preferences and is required to properly support localisation.

* `Cldr.known_territories/1` no longer includes reserved, deprecated, special use or private use territory codes.

### Deprecations

* Deprecated `Cldr.Config.known_locale_names/1` in favour of `Cldr.Locale.Loader.known_locale_names/1`.

* Deprecated `Cldr.Config.known_rbnf_locale_names/1` in favour of `Cldr.Locale.Loader.known_rbnf_locale_names/1`.

* Deprecated `Cldr.Config.get_locale/2` in favour of `Cldr.Locale.Loader.get_locale/2`.

* Deprecated the `:put_session?` option in `Cldr.Plug.SetLocale`.  Use the plug `Cldr.Plug.PutSession` instead.

## Cldr v2.24.0-rc.6

This is the changelog for Cldr v2.24.0-rc.6 released on October 25th, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

This is expected to be the last RC before final release on October 27th.

### Deprecations

* Deprecated `Cldr.Config.known_locale_names/1` in favour of `Cldr.Locale.Loader.known_locale_names/1`

* Deprecated `Cldr.Config.known_rbnf_locale_names/1` in favour of `Cldr.Locale.Loader.known_rbnf_locale_names/1`

## Cldr v2.24.0-rc.5

This is the changelog for Cldr v2.24.0-rc.5 released on October 23rd, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Deprecations

* Deprecated `Cldr.Config.get_locale/2` in favour of `Cldr.Locale.Loader.get_locale/2`.

## Cldr v2.24.0-rc.4

This is the changelog for Cldr v2.24.0-rc.4 released on October 21st, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Fixes an issue with the locale loader which was incorrectly atomizing date part keys in date/time formats and conversely incorrectly stringifying the number system in the same formats.

## Cldr v2.24.0-rc.3

This is the changelog for Cldr v2.24.0-rc.3 released on October 18th, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* `Cldr.validate_territory_subdivision/1` was case sensitive and didn't correctly handle atoms and binaries. Now fixed. Required to support `ex_cldr_territories` properly.

## Cldr v2.24.0-rc.2

This is the changelog for Cldr v2.24.0-rc.2 released on October 18th, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Correctly atomize the keys for the locale display names "language" types.

## Cldr v2.24.0-rc.1

This is the changelog for Cldr v2.24.0-rc.1 released on October 18th, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* This release updates the CLDR 40 data to the latest pre-release (it's likely the final release data).  In addition, the canonical format of some data has changed; for example subdivisions are now atoms, not strings.

## Cldr v2.24.0-rc.0

This is the changelog for Cldr v2.24.0-rc.0 released on October 3rd, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

There has been a significant amount of refactoring of the code that packages the locale files and the code that loads a locale. This has a very minor performance improvement at compile time but the major benefit is for maintainability.

### Bug Fixes

* `Cldr.Plug.PutSession` now uses the locale key `:canonical_locale_name` to serialize to the session. Previously it was using `:cldr_locale_name` which does not include any of the extension information. Extension information encodes user preferences and is required to properly support localisation.

* `Cldr.known_territories/1` no longer includes reserved, deprecated, special use or private use territory codes.

### Enhancements

* Updates to CLDR release 40

### Soft Deprecations

* Deprecated the `:put_session?` option in `Cldr.Plug.SetLocale`.  Use the plug `Cldr.Plug.PutSession` instead.

## Cldr v2.23.2

This is the changelog for Cldr v2.23.2 released on September 8th, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Remove `telemetry` as a dependency. It is not required by `ex_cldr`. Thanks for the report from @benregn. Closes #154.

* Integerize all the numeric keys in calendars, including the 60 days of the Chinese calendar cycle and the 239 Japanese eras.

* Change from `use Mix.Config` to `import Config` for configuration. This has been the standard since Elixir 1.9 and since only Elixir 1.10 is supported, the update can be made.

## Cldr v2.23.1

This is the changelog for Cldr v2.23.1 released on August 20th, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Fix doc errors. Thanks to @maennchen for the report. Doc errors in other `ex_cldr` packages are also updated.  Closes #149.

## Cldr v2.23.0

This is the changelog for Cldr v2.23.0 released on July 1st, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Corrects the formation of a canonical language tag. In previous releases, the script tag was always included as part of the canonical locale name. For example, `en-US` would become `en-Latn-US` because `Latn` is defined as a likely subtag of `en`. However [TR35](https://unicode-org.github.io/cldr/ldml/tr35.html#Contents) specifies that if the script is the only script specified for this language then it should be omitted from the canonical name. Fixing this conformance is also a prerequisite for generating local display names.

* Fixes `Cldr.Locale.normalize_locale_name/1` to correctly case all keys in lower case except script (capital case) and region (upper case). It will now also process arbitrary locale names.

* A language tag can have more than one variant and this was not correctly implemented. As a result, the `t:Cldr.LanguageTag` struct field `variant` is renamed `variants` and is now a list with a default of `[]` rather than `nil`.

* Fix a race condition which could return incorrect results for a backend `known_gettext_locale_names/0`

* `Cldr.validate_locale/2` will now return an error if the territory for a locale is unknown to CLDR. Note that `Cldr.Locale.new/1,2` checks only if the territory is valid - not if it is known to CLDR.

* Locale inheritance no longer includes the "root" locale.  In alignment with [BCP 47](https://unicode-org.github.io/cldr/ldml/tr35.html#Unicode_Locale_Identifier_BCP_47_to_CLDR), the "root" locale is now longer a valid locale. Parsing a locale name "root" is still valid but it will return the "und" language instead.  While parsing is still correct, it remains a locale that is not valid for use in `ex_cldr`. The "root" locale is used only for a limited set of rules-based number formats.

* Correct territory containment chain for the territory `US`.

* Correctly parses and validates the [-t- extension](https://unicode-org.github.io/cldr/ldml/tr35.html#t_Extension) of a language tag.

* Fixes inspecting a language tag that has a `-t-` extension and/or a private use (`-x-`) extension.

### Enhancements

* Add `Cldr.DisplayName` protocol definition to return a localised string representation of CLDR-based structs such as `t:Cldr.LanguageTag`, `t:Cldr.Unit` and `t:Cldr.Currency`

* `Cldr.Locale.new/1,2` now passes all ~1600 validation tests for parsing and forming the canonical locale name. This is a prerequisite to implementing the [Locale Display Algorithm](https://unicode-org.github.io/cldr/ldml/tr35-general.html#Display_Name_Elements) in [ex_cldr_locale_display](https://github.com/elixir-cldr/cldr_locale_display).

* `Cldr.locale_and_backend_from/1` now supports a `map` of options as the argument.

* `Cldr.validate_territory/1` now correctly substitutes for known aliases. For example `MyApp.Cldr.validate_locale("en-UK")` will correctly return `en-GB`.

* Implement the `String.Chars` protocol to support `Kernel.to_string/1` for `t:Cldr.LanguageTag` structs.

* Implement the `Inspect` protocol to support `inspect/2` for `t:Cldr.LanguageTag` structs.

* Add `Cldr.LanguageTag.sigil_l/2` to simplify creating `t:Cldr.LanguageTag` structs.

* Add `Cldr.validate_script/1` to normalize and validate a script code (which is now in atom format as its canonical form)

* Pre-compiled language tags (which are stored in `priv/cldr/language_tags.ebin`) are now cached during compilation resulting in a minor performance improvement in compile times.

* Pre-generate the rfc5646 parser which improves overall compile times.  As a result the `nimble_parsec` dependency is marked as `optional` since it is no long required by library consumers.

## Cldr v2.22.1

This is the changelog for Cldr v2.22.1 released on May 20th, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* `Cldr.Number.PluralRule.plural_type/2` correctly returns a plural type when no backend is provided, no default backend is configured and the locale is a `t:Cldr.LanguageTag`

* `Cldr.validate_locale/1` doesn't raise if there is no default backend configured and the locale is a `t:Cldr.LanguageTag`

## Cldr v2.22.0

This is the changelog for Cldr v2.22.0 released on May 20th, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Soft deprecation

* The plug `Cldr.Plug.SetSession` was introduced in `ex_cldr` version 2.21.0. However the convention in Phoenix and Plug is `put`, not `set`. The plug is renamed to `Cldr.Plug.PutSession`. `Cldr.Plug.SetSession` is still available but will emit a deprecation notice and will delegatge to `Cldr.Plug.PutSession.` Apologies to all for the sloppy release review process.

### Bug Fixes

* Fix typespec of Cldr.AcceptLanguage.best_match/2. Thanks to @adriankumpf.

### Enhancements

* Make log level for "no match" errors in `Cldr.Plug.AcceptLanguage` configurable.

## Cldr v2.21.0

This is the changelog for Cldr v2.21.0 released on May 17th, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Correctly pluralize numbers where the plural rule has an explicit case for the given number. When pluralizing numbers, plural rules will return a value such as `:one`, `:two`, `:few`, `:many` which is used as a key into a map of substitutions. However it is also possible to have substitutions based upon the explicit value of a number, rather than its plural type. Previously this last rule was not being applied but now is.  For the purposes of pluralization, `1.0` and `1` are considered the same - plural rules use the integer representation so a float is cast to an integer when they are both equal according to `==`.

* Correctly pluralize Decimal numbers (in addition to integer and float)

### Enhancements

* Add `--force-locale-download` option to `mix cldr.install.locales`.

* `Plug.SetLocale` default keys for locale discovery from an HTTP request are now expanded to be `[:session, :accept_language, :query, :path]`.

* The `:session_key` option to `Cldr.Plug.SetLocale` is deprecated. A well-known session key is required in order to support setting the locale from the session passed to `mount/3` for liveview applications. The session key is available as `Cldr.Plug.SetLocale.session_key/0`

* Adds `Cldr.Plug.SetSession` that will copy the cldr locale name from the `conn` and put it in the session. This simplifies the lifecycle of a typical HTTP request and ensures that the locale is readily available in liveviews as well.

## Cldr v2.20.0

This is the changelog for Cldr v2.20.0 released on April 8th, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Updates to [CLDR version 39](http://cldr.unicode.org/index/downloads/cldr-39) data.

* Add `Cldr.Locale.parent/1` to return the parent locale according. This is not exactly the same as the CLDR [locale inheritance rules](https://unicode.org/reports/tr35/#Locale_Inheritance)

* Add `Cldr.Locale.parents/2` to return a list of parents up to and including the `root` locale. It is a recursive use of `Cldr.Locale.parent/1`.

* Add locale display name data to the locale files. This data can be used to format a locale for UI usage.

* Add subdivision translations to the locale files. This data can be used to format subdivision names for UI usage. Thanks to @mskv. Closes #144.

* Add grammatical features to the repository. This data is used in [ex_cldr_units](https://github.com/elixir-cldr/cldr_units). See also `Cldr.Config.grammatical_features/0`.

* Add grammatical gender to the repository. This data is used in [ex_cldr_units](https://github.com/elixir-cldr/cldr_units). See also `Cldr.Config.grammatical_gender/0`.

* Make `Cldr.Locale.first_match/2` a public function. This function is useful for other CLDR-based libraries to help resolve the files of localised content in CLDR.

* Add `:add_fallback_locales` to the backend configuration. When `true`, the fallback locales of the configured backend locales is also added to the configuration. The default is `false` and therefore by default there is no change to behaviour from previous releases. Setting this option to `true` enables means that data that is stored in parent locales rather than child locales can be processed. This applies particularly to rules-based number formats and subdivision data. These data aren't stored in all locales - generally they are stored in the base language locale.

* Add `Cldr.Config.fallback_chain/1` which takes a locale name and returns a list of locales from which this locale inherits up to but not including the `root` locale.

* Add `Cldr.Config.fallback/1` which takes a locale name and returns the direct parent of the locale name.

* Rename alias key `subdivisionAlias` to `subdivision`

* Fix `Cldr.Substitution.substitute/2` when the template has no substitutions. Thanks to @jarrodmoldrich. Closes [ex_cldr_units #20](https://github.com/elixir-cldr/cldr_units/issues/20).

## Cldr v2.20.0-rc.3

This is the changelog for Cldr v2.20.0-rc.3 released on April 7th, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Fix `Cldr.Substitution.substitute/2` when the template has no substitutions. Thanks to @jarrodmoldrich. Closes [ex_cldr_units #20](https://github.com/elixir-cldr/cldr_units/issues/20).

## Cldr v2.20.0-rc.2

This is the changelog for Cldr v2.20.0-rc.2 released on March 22nd, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Add `:add_fallback_locales` to the backend configuration. When `true`, the fallback locales of the configured backend locales is also added to the configuration. The default is `false` and therefore by default there is no change to behaviour from previous releases. Setting this option to `true` enables means that data that is stored in parent locales rather than child locales can be processed. This applies particularly to rules-based number formats and subdivision data. These data aren't stored in all locales - generally they are stored in the base language locale.

* Add `Cldr.Config.fallback_chain/1` which takes a locale name and returns a list of locales from which this locale inherits up to but not including the `root` locale.

* Add `Cldr.Config.fallback/1` which takes a locale name and returns the direct parent of the locale name.

* Rename alias key `subdivisionAlias` to `subdivision`

## Cldr v2.20.0-rc.1

This is the changelog for Cldr v2.20.0-rc.1 released on March 22nd, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Make `Cldr.Locale.first_match/2` a public function. This function is useful for other CLDR-based libraries to help resolve the files of localised content in CLDR.

## Cldr v2.20.0-rc.0

This is the changelog for Cldr v2.20.0-rc.0 released on March 19th, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Updates to [CLDR version 39](http://cldr.unicode.org/index/downloads/cldr-39) data.

* Add `Cldr.Locale.parent/1` to return the parent locale according. This is not exactly the same as the CLDR [locale inheritance rules](https://unicode.org/reports/tr35/#Locale_Inheritance)

* Add `Cldr.Locale.parents/2` to return a list of parents up to and including the `root` locale. It is a recursive use of `Cldr.Locale.parent/1`.

* Add locale display name data to the locale files. This data can be used to format a locale for UI usage.

* Add subdivision translations to the locale files. This data can be used to format subdivision names for UI usage. Thanks to @mskv. Closes #144.

* Add grammatical features to the repository. This data is used in [ex_cldr_units](https://github.com/elixir-cldr/cldr_units). See also `Cldr.Config.grammatical_features/0`.

* Add grammatical gender to the repository. This data is used in [ex_cldr_units](https://github.com/elixir-cldr/cldr_units). See also `Cldr.Config.grammatical_gender/0`.

## Cldr v2.19.1

This is the changelog for Cldr v2.19.1 released on April 7th.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Fix `Cldr.Substitution.substitute/2` when the template has no substitutions. Thanks to @jarrodmoldrich. Closes [ex_cldr_units #20](https://github.com/elixir-cldr/cldr_units/issues/20).

## Cldr v2.19.0

This is the changelog for Cldr v2.19.0 released on February 6th, 2021.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Breaking change

* A parsed language tag would previously turn the `tz` parameter of the `u` extension into a timezone ID. For example, the language tag `en-AU-u-tz-ausyd` would decode `ausyd` into `Australia/Sydney`. From this release, parsing no longer decodes the `tz` parameter since doing so means that `to_string/1` does not work correctly.  Use `Cldr.Locale.timezone_from_locale/1` instead.

### Enhancements

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

## Cldr v2.18.2

This is the changelog for Cldr v2.18.2 released on November 9th, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Add `Cldr.Locale.territory_from_locale/1` for string language tags

## Cldr v2.18.1

This is the changelog for Cldr v2.18.1 released on November 7th, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Add `<backend>.Locale.territory_from_locale/1`

### Bug Fixes

* Fixes `Cldr.LanguageTag.to_string/1` when the `u` extenion is empty. Closes #140. Thanks to @Zurga.

## Cldr v2.18.0

This is the changelog for Cldr v2.18.0 released on November 1st, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Update to [CLDR 38](http://cldr.unicode.org/index/downloads/cldr-38)

* Removed the `mix cldr.compile` mix task (it was deprecated several releases ago)

* Removed the `mix cldr.download.core_data` mix task since the current development process does not require it.

* The script `ldml2json` now rebuilds to tools on each run and instead of hardcoded environment variables it uses existing ones if set and only applies defaults if required. This is applicable only to `ex_cldr` developers and maintainers.

* Warn on duplicate providers being configured for a backend and then ignore the duplicates.

* Omit stacktrace when warning about use of the global configuration

* Deprecate `Cldr.default_backend/0` in favour of `Cldr.default_backend!/0` which more clearly expresses that the function will raise if no default backend is configured.

* Changes the behaviour of `Cldr.put_locale/{1, 2}`. In previous releases the intent was that a process would store a locale for a given backend. Logically however, it is more appropriate to store a locale on a per-process basis, not per backend per process.  The backend is an important asset, but only insofaras it hosts locale-specific content.  Therefore in this release, `Cldr.put_locale/{1, 2}` always stores the locale on a per-process basis and there is only one locale, not one specialised per backend. This also simplifies `Cldr.get_locale/0` which now returns the process's locale or the default locale.

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

## Cldr v2.17.2

This is the changelog for Cldr v2.17.2 released on September 30th, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* When configuring a Cldr backend, warn then omit any Gettext locales configured that aren't actually available in CLDR. Thanks to @mikl. Closes #138.

## Cldr v2.17.1

This is the changelog for Cldr v2.17.1 released on September 26th, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Significantly improve the performance of `Cldr.default_locale/0`. In previously releases, the default locale was being parsed on each access. In this release it is parsed once and cached in the application environment. This improves performance by about 40x.  Thanks to @Phillipp who brought this to attention in [Elixir Forum](https://elixirforum.com/t/cldr-number-parser-parse-quite-slow/34572)

## Cldr v2.17.0

This is the changelog for Cldr v2.17.0 released on September 8th, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Support `Decimal` version `~> 1.6` and `~> 2.0`

### Bug Fixes

* Corrects `Cldr.Plug.SetLocale` testing for body parameters. Previous version of `Plug` would parse body parameters for an HTTP `get` verb which is not standard behaviour. The test now uses the HTTP `put` verb where body parameters are expected to be parsed.

* Corrects internal links to the readme.

## Cldr v2.16.2

This is the changelog for Cldr v2.16.2 released on August 29th, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Fix compiler warning for Elixir 1.11 when calling a remote function that is based upon a module name that is a variable.

## Cldr v2.16.1

This is the changelog for Cldr v2.16.1 released on June 7th, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Do not send `Connection: close` header when downloading locales.

* Do not convert `charlist` data from `:httpc` before saving it as a locale file. Fixes an issue whereby the saved locale file is shorter than expected due to an extraneous use of `:erlang.list_to_binary/1` which is not `UTF8` friendly. Thanks to @halostatue for the patience and persistence working this issue through on a weekend. Fixes #137.

## Cldr v2.16.1-rc.0

This is the changelog for Cldr v2.16.1-rc.0 released on June 7th, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Do not send `Connection: close` header when downloading locales.

* Do not convert `charlist` data from `:httpc` before saving it as a locale file. Probably fixes an issue whereby the saved locale file is shorter than expected.

## Cldr v2.16.0

This is the changelog for Cldr v2.16.0 released on June 6th, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Add configuration key `:force_locale_download` for backend and the global configuration. Locale data is `ex_cldr` version dependent. When a new version of `ex_cldr` is installed, no locales are installed and therefore locales are downloaded at compilation time as required. This ensures that the right version of the locale data is always associated with the right version of `ex_cldr`.

However:

* If locale data is being cached in CI/CD there is some possibility that there can be a version mismatch.  Since reproducible builds are important, using the `force_locale_download: true` in a backend or in global configuration adds additional certainty.  The default setting is `false` thereby retaining compatibility with existing behaviour. The configuration can also be made dependent on `mix` environment as shown in this example:

```elixir
defmodule MyApp.Cldr do
  use Cldr,
	  locales: ["en", "fr"],
		default_locale: "en",
		force_locale_download: Mix.env() == :prod

```

### Bug Fixes

* Validate configured locales in a backend case insensitively and with either BCP 47 or Poxix ("-" or "_") separators.

## Cldr v2.15.0

This is the changelog for Cldr v2.15.0 released on May 27th, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

Starting with `ex_cldr` the development process now requires the CLDR repository be cloned to the development machine; that the CLDR json data is generated on that machine and the shell variable `CLDR_PRODUCTION_DATA` must be set to the directory where the generated json data is stored.  For more information on the development process for `ex_cldr` consult `DEVELOPMENT.md`

This change is relevant only to the developers of `ex_cldr`. It is not applicable to users of the library.

### Enhancements

* Adds data to support lenient parsing of dates and numbers

## Cldr v2.14.1

This is the changelog for Cldr v2.14.1 released on May 15th, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Fix compilation order for backends configured in `Cldr.Plug.SetLocale`. Thanks to @syfgkjasdkn. Closes #135.

## Cldr v2.14.0

This is the changelog for Cldr v2.14.0 released on May 2nd, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

The primary purpose of this release is to support the new data for units that standardize
a means for conversion.  In addition, some data file names are changed to be more consistent in naming.

### Summary

* Updates the data source to [CLDR release 37](http://cldr.unicode.org/index/downloads/cldr-37).

* Require that a certificate trust store be configured in order to download locales. A system trust store will be automatically detected in many situations. In other cases configuring [castore](https://hex.pm/packages/castore) or [certifi](https://hex.pm/packages/certifi) will be automatically detected. A specific trust store can be configured under the `:cacertfile` key of the `:ex_cldr` configuration in `config.exs`. Note that on Windows either `castore`, `certifi` or a configured trust store will be required.

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

## Cldr v2.13.0

This is the changelog for Cldr v2.13.0 released on January 19th, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Removes the runtime dependency on `Jason` since the RFC5646 parser is now inlined. Closes #99

* Adds `Cldr.Timezone` to support timezone mapping for language tags using the `tz` key of the `u` extension to the [Unicode locale identifier](https://unicode.org/reports/tr35/#u_Extension)

* When parsing a locale with a `u` extension containing a `cf` (currency format) key, the key is transformed to the standard `:currency` or `:accounting` atoms rather than being left as strings.

## Cldr v2.12.1

This is the changelog for Cldr v2.12.1 released on January 14th, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Remove two lingering dialyzer errors-that-aren't-really-errors so its passes cleanly.

## Cldr v2.12.0

This is the changelog for Cldr v2.12.0 released on January 2nd, 2020.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Remove use of `Code.ensure_compiled?/1` since its deprecated in Elixir 1.10. A new function `Cldr.Config.ensure_compiled?/1` is introduced but marked as `@doc false`.

* Adds `mix cldr.download.plural_ranges` to automate the downloading, extracting and saving of `pluralRanges.xml` from CLDR.

* Update copyright dates in LICENSE.md

## Cldr v2.11.1

This is the changelog for Cldr v2.11.1 released on October 20th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Validate session-based locale in `Cldr.Plug.SetLocale`. Closes #131. Thanks for @Ray-Wang.

## Cldr v2.11.0

This is the changelog for Cldr v2.11.0 released on October 10th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Update to CLDR data version 36.0.0.

## Cldr v2.10.2

This is the changelog for Cldr v2.10.2 released on September 7th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Use `Keyword.get_lazy/3` when retrieving `Cldr.default_backend/0` to avoid exceptions when no default backend is configured.

* `Cldr.Number.PluralRule.plural_type/2` has become `Cldr.Number.PluralRule.plural_type/3` to better align with other functions that typically use `argument, backend, options` as their parameters. No user code change is expected as the function heads remain compatible.

## Cldr v2.10.1

This is the changelog for Cldr v2.10.1 released on August 25th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Fix error in the generation of unit preference data

## Cldr v2.10.0

This is the changelog for Cldr v2.10.0 released on August August 25th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Adds unit preference data. This data is used by [ex_cldr_units](https://hex.pm/packages/ex_cldr_units) version 2.6 and later to allow localization of units into the preferred units for a given locale or territory.

## Cldr v2.9.0

This is the changelog for Cldr v2.9.0 released on August August 24th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Includes the compound unit fields from units in the generated locale data.  This enables formatting of compound units, like the "per" form which is used when there is no predefined unit style. This functionality is enabled in [ex_cldr_units](https://hex.pm/packages/ex_cldr_units) version 2.6.

* Add `Cldr.quote/3` and `MyApp.Cldr.quote/2` that add locale-specific quotation marks around a string.  The locale data files are updated to include this information.

* Add `Cldr.ellipsis/3` and `MyApp.Cldr.ellipsis/2` that add locale-specific ellipsis' to a string. The locale data files are updated to include this information.

* Add `Cldr.Config.measurement_system/0` that returns a mapping between a territory and a measurement system (ie does a territory/country use the metric, US or UK system)

## Cldr v2.8.1

This is the changelog for Cldr v2.8.1 released on August 23rd, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Fix the `@spec` for `Cldr.Substitution.substitute/2`

## Cldr v2.8.0

This is the changelog for Cldr v2.8.0 released on August 21st, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Adds `Cldr.validate_plural_type/1` which will validate if a plural type is one those returned by `Cldr.Number.PluralRule.known_plural_types/0` which is also added.  These functions are added to support message formatting in the forthcoming `ex_cldr_messages` package.

* Adds `Cldr.Number.PluralRule.plural_type/2` which returns the plural type for a number.

* Adds `message_formats` backend configuration key.  This is used by [ex_cldr_messages](https://github.com/elixir-cldr/cldr_messages) to define custom formats for messages.

### Bug Fixes

* Add `@spec` to parser combinators to remove dialyzer warnings.  Ensure that you are using `nimble_parsec` version 0.5.1 or later if running dialyzer checks.

## Cldr v2.7.2

This is the changelog for Cldr v2.7.2 released on June 14th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Fixes a bug whereby a `Gettext` backend module may not be compiled at the time that the `Cldr` backend is being compiled. This can cause compilation errors and may cause the wrong assembly of configured locales. Closes #124.  Thanks very much to @erikreedstrom and @epilgrim.

* Fixes a bug whereby a `Cldr` backend may not be recognised during compilation of `Cldr.Plug.SetLocale`. Similar issue to #124. Thanks for @AdrianRibao for the report.

## Cldr v2.7.1

This is the changelog for Cldr v2.7.1 released on June 2nd, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Fix `Cldr.known_number_systems/0` by removing the call to `Config.known_number_systems/0` which decodes json on each call and use `Cldr.known_number_systems/0` which does not.

## Cldr v2.7.0

This is the changelog for Cldr v2.7.0 released on April 22nd, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Updates to CLDR version 35.1.0 which is primarily related to the change of Japanese era with the ascension of a new emperor on April 1st.

## Cldr v2.6.2

This is the changelog for Cldr v2.6.2 released on April 16th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Adds `Cldr.flag/1` that returns a binary unicode grapheme representing a flag for a given territory

* The parameters provided to `Cldr.Plug.SetLocale.init/1` are now conformed more precisely based upon the provided options. This ensures that the keys `:cldr` and `:gettext` are set from other options if they are not provided directly.

### Bug Fixes

* `Cldr.Plug.SetLocale.init/1` would raise an exception if no `:gettext` key was specified.  This is now corrected.

## Cldr v2.6.1

This is the changelog for Cldr v2.6.1 released on April 13th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Correctly resolves the `:data_dir` param for a backend module.  Thanks to @erikreedstrom for the report.  Closes #123.

* Raises if a backend module configures an `:otp_app` that is not known

## Cldr v2.6.0

This is the changelog for Cldr v2.6.0 released on March 28th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Updates to [CLDR version 35.0.0](http://cldr.unicode.org/index/downloads/cldr-35) released on March 27th 2019.

There is one unresolved issue in this implementation related to plural rules for the locale "kw" (Cornish).

The plural rule definition for `:other` in the repository is:
```
"pluralRule-count-other": " @integer 4~19, 100, 1000000, … @decimal 0.1~0.9, 1.1~1.7, 10.0, 100.0, 1000.0 100000.0 1000000.0, …",
```

However in rules testing, the values `1000.0`, `10000.0` and `100000.0` are resolving to category `:two` rather than `:other`. Until this is resolved, these data points are removed from the test data.

## Cldr v2.5.0

This is the changelog for Cldr v2.5.0 released on March 23rd, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Adds the global `:ex_cldr` configuration key `:default_backend`.

* Adds `Cldr.default_backend/0` which will return the configured default backend or will raise an exception if not is configured.

* Where appropriate, `Cldr.*` will now use `Cldr.default_backend()` as a default parameter.

## Cldr v2.4.3

This is the changelog for Cldr v2.4.3 released on March 20th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Fix `Cldr.validate_locale/1` @spec error and remove spurious `@dialyzer` directives

## Cldr v2.4.2

This is the changelog for Cldr v2.4.2 released on March 15th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Exclude `Cldr.Currency` from the list of known providers so that it won't be compiled twice when working with `ex_cldr_numbers`.

## Cldr v2.4.1

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
## Cldr v2.4.0

This is the changelog for Cldr v2.4.0 released on March 10th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Minor restructuring of the locale files.  Calendar map keys are harmonised to have the same names and meanings. This would not normally be user visible but a change in data format suggests a minor version bump to easy version management.

* Restructure the data returned by `Cldr.Config.week_info/0` to also encode week days as numbers in the range 1..7 where 1 is Monday.

## Cldr v2.3.2

This is the changelog for Cldr v2.3.2 released on March 8th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Does a better job of detecting a required JSON library and raising at compile time if no such library can be found.  In order of priority the search for a JSON library is:

    * the key `:json_library` under the application key `:ex_cldr`
    * a configured Phoenix `json_library`
    * a configured Ecto `json_library`
    * `Jason` if configured
    * `Poison` if configured

## Cldr v2.3.1

This is the changelog for Cldr v2.3.1 released on March 6th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Fix dialyzer errors.  In some cases, notably related to `nimble_parsec`, errors are generated that need to be fixed in a dependency.  These errors are added to the `.dialyzer_ignore_warnings` file for now.

## Cldr v2.3.0

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

## Cldr v2.2.7

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

## Cldr v2.2.6

This is the changelog for Cldr v2.2.6 released on February 23rd, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Adds `Cldr.Config.territory_currency_data/0` that maps a territory code (like "US") to a list of currencies reflecting the historic and current usage of currencies in that territory.

## Cldr v2.2.5

This is the changelog for Cldr v2.2.5 released on February 18th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Remove most dialyzer errors

* Fix documentation syntax errors

* Fix regex for parsing currency names into currency strings

## Cldr v2.2.4

This is the changelog for Cldr v2.2.4 released on February 10th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Ensure the global default locale (currently "en-001") is always configured

### Enhancements

* Log a warning if a CLDR provider module could not be found

## Cldr v2.2.3

This is the changelog for Cldr v2.2.3 released on February 9th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Fix parsing of currency names that have date ranges or annotations within them like "US dollar (next day)" and "Afghan afghani (1927–2002)"

## Cldr v2.2.2

This is the changelog for Cldr v2.2.2 released on February 9th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* add `Cldr.Config.currencies_for/2` to return a map of the currency definition for a locale

## Cldr v2.2.1

This is the changelog for Cldr v2.2.1 released on January 30th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug Fixes

* Correctly add the `gettext` locale to the language tag returned by `<backend>.default_locale` and `Cldr.default_locale/2`.  Thanks to @erikreedstrom.  Closes #106.

### Enhancements

* Added a section on migrating from `Cldr` 1.x to 2.x.

## Cldr v2.2.0

This is the changelog for Cldr v2.2.0 released on December 23nd, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Bump `nimble_parsec` to version 0.5 which has some breaking changes from 0.4 that affects the language tag parser.

* Use `IO.warn/1` for compiler warnings related to global configuration and Cldr providers configuration for a backend.

## Cldr v2.1.0

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

## Cldr v2.0.4

This is the changelog for Cldr v2.0.4 released on November 26th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug fixes

* Dependency plugin check was using `Mix.Project.in_project/3` which actually changes directory which during compilation is a bad thing (since compilation is in parallel and within a single Unix process).  The plugin dependency list is now static.  Thanks to @robotvert. Closes #93.

## Cldr v2.0.3

This is the changelog for Cldr v2.0.3 released on November 25th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug fixes

* Check for a `json` library existence as early as possible in the compile cycle since it is required during compilation of `Cldr`.

## Cldr v2.0.2

This is the changelog for Cldr v2.0.2 released on November 24th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Enhancements

* Move minimal Decimal version to 1.5

### Bug fixes

* `Cldr.Substitution.substitute/2` now conforms to its documentation and substitutes a list of terms into a list format

## Cldr v2.0.1

This is the changelog for Cldr v2.0.1 released on November 22, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/elixir-cldr/cldr/tags)

### Bug fixes

* Fixes a bug whereby a backend configured with locales, but no default locale (and no global configuration), would crash during compilation

## Cldr v2.0.0

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

