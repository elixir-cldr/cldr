# Changelog for Cldr v1.2.0

This is the changelog for Cldr v1.2.0 released on January 9th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

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

