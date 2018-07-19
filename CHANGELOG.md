# Changelog for Cldr v1.6.4

This is the changelog for Cldr v1.6.4 released on July 20th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Bug Fixes

* Removes `src/*.erl` files from the package to ensure that they are generated on the correct erlang version

# Changelog for Cldr v1.6.3

This is the changelog for Cldr v1.6.3 released on July 19th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Bug Fixes

* Fixes `Cldr.Compiler` to support Elixir 1.7.  Closes #69.

# Changelog for Cldr v1.6.2

This is the changelog for Cldr v1.6.1 released on June 20th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Bug Fixes

* Cldr data files are always located in `Cldr.Config.cldr_data_dir/0`; some functions were incorrectly using `Cldr.Config.client_data_dir/0` which should only be used to located user configured data like locales.

# Changelog for Cldr v1.6.1

This is the changelog for Cldr v1.6.1 released on June 8th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Bug Fixes

* Use `Logger.bare_log/3` instead of the logger macros when installing locales.  This is because the installation occurs at compile time and its possible that the log level configured is resolved in Distillery at a later stage.  Thanks to @erikreedstrom.  Closes #62.

# Changelog for Cldr v1.6.0

This is the changelog for Cldr v1.6.0 released on May 18th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Enhancements

* Add support to retrieve the requested locale from a cookie in `Cldr.Plug.SetLocale`.  Thanks to @danschultzer.

### Bug Fixes

* Fix detection of invalid currency code error when parsing language tags.  Thanks to @danschultzer.

# Changelog for Cldr v1.5.2

This is the changelog for Cldr v1.5.2 released on April 9th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Enhancements

* ISO4217 private use currency codes are now properly supported.  These are currency codes that are three upper case alphabetic ASCII characters with the first character being "X".

# Changelog for Cldr v1.5.1

This is the changelog for Cldr v1.5.1 released on April 1st, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Enhancements

* Replace all fixed references to the app name `:ex_cldr` and replace with a function `Cldr.Config.app_name/0` instead.  This function will also be used amongst dependencies that use the same configuration block like `ex_cldr_numbers` (and others).

# Changelog for Cldr v1.5.0

This is the changelog for Cldr v1.5.0 released on March 29th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Enhancements

* Updated to use CLDR version 33 data released by the [Unicode Consortium](http://cldr.unicode.org) on March 28th 2018.  This data release adds no new locales.  The release notes for CLDR are at http://cldr.unicode.org/index/downloads/cldr-33

# Changelog for Cldr v1.4.5

### Bug Fixes

* Fixed `Cldr.Math.power/2` for Decimal numbers with a coefficient of 10 and an exponent <> 1.  Thanks to @camonz

* Correct typos in README.  Thanks to @zacca

* Fixed `Cldr.Map.deep_merge/2/3` to skip structs since their keys are atoms and they don't support Enumerable

* Fixed the the mix task generation of language tags for all locales

* Fixed exception when cldr compiler is trying to removing old module Beam files

* Removed .erl generated files from the repo (they will be created at compile time)

# Changelog for Cldr v1.4.4

### Enhancements

* Cldr.Config functions that deal with directory and file paths now return results generated at runtime rather than at compile time

* An exception is raised at compile time if the `:cldr` compiler is configured but it is not the last compiler in the list returned by `Mix.Project.config[:compilers]`

* Renamed `language_tags` to `language_tags.ebin` to better reflect that its a file containing erlang binary terms

# Changelog for Cldr v1.4.3

### Enhancements

* When a locale configuration change is detected a coloured diff of the locale configuration is printed.

* When the `:cldr` compiler runs, call `Mix.Project.build_structure/0` for each `Cldr` dependency to ensure the `priv` directory is copied to the build directory.

# Changelog for Cldr v1.4.2

### Bug Fixes

* Remove the hard-coded reference to the `Poison` library in `Cldr.Rbnf.Config` and replace it with the canonical `Cldr.Config.json_library/0`

### Enhancements

* Improve the error message raised at compile time if no valid json library has been detected

# Changelog for Cldr v1.4.1

As reported by @marceldegraaf there has been a regression in the performance of `Cldr.DateTime.to_string/2`.  The use case he reported involved calls with `locale: "nl"`; ie using a binary `:locale`.

In all cases, locale resolution is passed through `Cldr.validate_locale/1`.  In prior releases of `Cldr` this would require parsing the locale name which is a relatively expensive operation.

Therefore the major focus on this small release is to pre-parse all configured locale names into their corresponding language tag.  As a result performance is largely the same whether locale is specified as a binary or as a language tag.

## Enhancements

* Precompiles all known locale names into a language tag which are then used to generate locale specific versions of `Cldr.validate_locale/1` when the parameter is a binary.

* Adds a mix task (available in github, not in the hex package) to generate the language tags for all available locales to support the performance optimization of locale to langauge tag lookup which is used in `Cldr.validate_locale/1` in many places in `Cldr`.

* Automatically detects the presence of `Jason` and `Poison` and configures the default `:json_library` appropriately.

# Changelog for Cldr v1.4.0

## Enhancements

* Updates CLDR data to version 32.0.1

* The primary focus on this release to automate the process of recompiling those parts of Cldr that are sensitive to configuration change.  This release:

  * Adds a `compiler.cldr` as a Mix compiler.  This provides the functions that identify a locale configuration change and then recompile the relevant modules of Cldr.  Basically it looks in all dependencies for any module that calls functions in `Cldr.Config`  Therefore it is expected to work for Cldr and any package that depends on Cldr.

  * To enable this functionality, the `compiler.cldr` mix task needs to be added in `mix.exs` as the last compiler in the list.  For example

```
  def project do
    [
      app: :app_name,
      ...
      compilers: Mix.compilers ++ [:cldr],
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end
```

  * With this enhancement it will be no longer necessary to force recompile Cldr or packages that depend on it since they will be compiled whenever a locale configuration change is detected.

* The [Jason](https://hex.pm/packages/jason) json library is added to the dependency list as an optional dependency.

* Adds `:iso_digits` to the currency data maintained in CLDR.  Cldr currency data does not always align with the ISO definition of a currency - notably for digits (subunit) definitions.  For example, the Colombian Peso has an official subunit of the _pesavo_.  One hundred _pesavos_ equals one _peso_.  There are no notes/cash/coins for the _centavo_ but it is an offical part of the currency and it's important to be maintained for financial transactions.

* Adds a `Mix` task to download the ISO currency data that is used during locale consolidation to include ISO currency digits (subunits) in the currency definition.  This is used downstream in the `ex_money` package.

## Bug Fixes

* Don't raise an exception if a Gettext backend is defined but it has no configuration for `:default_locale`.  Fixes #38.  Thanks to @schultzer.

* Fix incorrect boolean expression, replace with `&&` when determining if `Gettext` is configured.

* Remove unused var warnings when compiing on Elixir 1.7.0 master branch.  Fixes #40. Thanks to @michalmuskala.

* Fix README `config.exs` examples to use the correct config key `:ex_cldr`.  Fixes #41.  Thanks to @phtrivier.

* Fix detecting a Gettext locale configuration by adding the `:cldr` compiler.  Fixes #31.  Thanks to @BrummbQ.

* Ensure that the default locale is also expanded. If no default locale is configured, the package  default "en-001" is defined.  This locale should also be expanded to include "en" since plural rules are often defined on the language rather than the territory-specific locale.

# Changelog for Cldr v1.3.2

This is the changelog for Cldr v1.3.2 released on January 20th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Bug Fixes

* Correctly retrieve the default locale from a configured Gettext backend module.  Fixes #32.

# Changelog for Cldr v1.3.1

### Bug Fixes

* Correctly use `conn.path_params` not the incorrect `conn.url_params` in `Cldr.Plug.SetLocale` and add plug router tests. Fixes #33.

* Correctly set the default locale using the Gettext default locale if the Cldr default locale isn't set but Gettext is.

# Changelog for Cldr v1.3.0

### Enhancements

* Add `Cldr.Digits.number_of_digits/1` that returns the number of digits (precision) of a float, integer or Decimal.  The primary intent is to support better detection of precision errors after parsing a float string.  A double precision 64-bit float (which is what Erlang/Elixir use) can safely support 15 digits.  According to [Wikipedia](https://en.wikipedia.org/wiki/IEEE_754#Character_representation) a decimal floating point number should round-trip convert to string representation and back for 16 digits without rounding (and 17 using "round to even").  Some examples:

```
iex> Cldr.Digits.number_of_digits(1234)
4

iex> Cldr.Digits.number_of_digits(Decimal.new("123456789"))
9

iex> Cldr.Digits.number_of_digits(1234.456)
7

iex> Cldr.Digits.number_of_digits(1234.56789098765)
15

iex> Cldr.Digits.number_of_digits '12345'
5
```

# Changelog for Cldr v1.2.0

### Bug Fixes

* The changelog refers to the configuration key `json_library` but the readme and the code refer to `json_lib`.  Standardise on `json_library`.  Thanks to @lostkobrakai.

### Enhancements

* Fix the spec for `Cldr.known_currencies/0`.  Thanks to @lostkobrakai.

# Changelog for Cldr v1.1.0

## Enhancements

* When configuring a locale name of the form "language-Script" or "language-Variant" the base "language" is also configured since plural rules will fall back to the base language if the locale name does not contain plural rules.

* When expanding wildcard locale names a more informative exception and error is produced if the regex for the locale names is invalid

* When a locale doesn't have any plural rules the error tuple `{:error, {Cldr.UnknownPluralRules, message}}` is returned instead of the current behaviour which raises an exception.

* The json library is now configurable.  This permits the use of the new json library [jason](https://hex.pm/packages/jason) or any other library that provides `decode!/1` and `encode!/1`.  The library is configured in `config.exs` as follows:

```
config :ex_cldr,
  json_library: Jason # The default is Poison
```

