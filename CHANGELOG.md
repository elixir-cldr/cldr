# Changelog for Cldr v1.1.0

This is the changelog for Cldr v1.1.0 released on December 30th, 2017.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

## Enhancements

* When configuring a locale name of the form "language-Script" or "language-Variant" the base "language" is also configured since plural rules will fall back to the base language if the locale name does not contain plural rules.

* When expanding wildcard locale names a more informative exception and error is produced if the regex for the locale names is invalid

* When a locale doesn't have any plural rules the error tuple `{:error, {Cldr.UnknownPluralRules, message}}` is returned instead of the current behaviour which raises and exception.

* The json library is now configurable.  This permits the use of the new json library [jason](https://hex.pm/packages/jason) or any other library that provides `decode!/1` and `encode!/1`.  The library is configured in `config.exs` as follows:

```
config :ex_cldr,
  json_library: Jason # The default is Poison
```

