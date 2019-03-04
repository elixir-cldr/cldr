# Changelog for Cldr v2.3.0

This is the changelog for Cldr v2.3.0 released on March 4th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

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

This is the changelog for Cldr v2.2.7 released on February 23rd, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

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

This is the changelog for Cldr v2.2.6 released on February 23rd, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Enhancements

* Adds `Cldr.Config.territory_currency_data/0` that maps a territory code (like "US") to a list of currencies reflecting the historic and current usage of currencies in that territory.

# Changelog for Cldr v2.2.5

This is the changelog for Cldr v2.2.5 released on February 18th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Bug Fixes

* Remove most dialyzer errors

* Fix documentation syntax errors

* Fix regex for parsing currency names into currency strings

# Changelog for Cldr v2.2.4

This is the changelog for Cldr v2.2.4 released on February 10th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Bug Fixes

* Ensure the global default locale (currently "en-001") is always configured

### Enhancements

* Log a warning if a CLDR provider module could not be found

# Changelog for Cldr v2.2.3

This is the changelog for Cldr v2.2.3 released on February 9th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Bug Fixes

* Fix parsing of currency names that have date ranges or annotations within them like "US dollar (next day)" and "Afghan afghani (1927–2002)"

# Changelog for Cldr v2.2.2

This is the changelog for Cldr v2.2.2 released on February 9th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Enhancements

* add `Cldr.Config.currencies_for/2` to return a map of the currency definition for a locale

# Changelog for Cldr v2.2.1

This is the changelog for Cldr v2.2.1 released on January 30th, 2019.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Bug Fixes

* Correctly add the `gettext` locale to the language tag returned by `<backend>.default_locale` and `Cldr.default_locale/2`.  Thanks to @erikreedstrom.  Closes #106.

### Enhancements

* Added a section on migrating from `Cldr` 1.x to 2.x.

# Changelog for Cldr v2.2.0

This is the changelog for Cldr v2.2.0 released on December 23nd, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Enhancements

* Bump `nimble_parsec` to version 0.5 which has some breaking changes from 0.4 that affects the language tag parser.

* Use `IO.warn/1` for compiler warnings related to global configuration and Cldr providers configuration for a backend.

# Changelog for Cldr v2.1.0

This is the changelog for Cldr v2.1.0 released on December 1st, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Bug Fixes

* Don't issue a bogus global config deprecation warning.

### Enhancements

* Revises the Cldr provider strategy - again. Rather than try to auto-discover available provider modules and configuring them automatically they are now configured under the `:provider` key.  The [readme](/readme#providers) contains further information on configuring providers. For example:

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

This is the changelog for Cldr v2.0.4 released on November 26th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Bug fixes

* Dependency plugin check was using `Mix.Project.in_project/3` which actually changes directory which during compilation is a bad thing (since compilation is in parallel and within a single Unix process).  The plugin dependency list is now static.  Thanks to @robotvert. Closes #93.

# Changelog for Cldr v2.0.3

This is the changelog for Cldr v2.0.3 released on November 25th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Bug fixes

* Check for a `json` library existence as early as possible in the compile cycle since it is required during compilation of `Cldr`.

# Changelog for Cldr v2.0.2

This is the changelog for Cldr v2.0.2 released on November 24th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Enhancements

* Move minimal Decimal version to 1.5

### Bug fixes

* `Cldr.Substitution.substitute/2` now conforms to its documentation and substitutes a list of terms into a list format

# Changelog for Cldr v2.0.1

This is the changelog for Cldr v2.0.1 released on November 22, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Bug fixes

* Fixes a bug whereby a backend configured with locales, but no default locale (and no global configuration), would crash during compilation

# Changelog for Cldr v2.0.0

This is the changelog for Cldr v2.0.0 released on November 22, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

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

For further information on configuration, consult the [readme](/ex_cldr/readme).

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

