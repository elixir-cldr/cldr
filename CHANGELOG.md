# Changelog for Cldr v1.1.0

This is the changelog for Cldr v1.1.0 released on December 22nd, 2017.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

## Enhancements

* When configuring a locale name of the form "language-Script" or "language-Variant" the base "language" is also configured since plural rules will fall back to the base language if the locale name does not contain plural rules.

* When expanding wildcard locale names a more informative exception and error is produced if the regex for the locale names is invalid
