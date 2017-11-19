# Changelog for Cldr v1.0.0-rc.1

This is the changelog for Cldr v1.0.0-rc.1 released on November __th, 2017.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

This version signals API stability and the first release candidate.

### Enhancements

* Removed obsolete guides since they are now merged into the readme files of each dependent package

# Changelog for Cldr v1.0.0-rc.0

This is the changelog for Cldr v1.0.0-rc.0 released on November 18th, 2017.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

This version signals API stability and the first release candidate.

### Enhancements

* Adds two `Plug`s:

  * `Cldr.Plug.AcceptLanguage` will parse an `accept-language` header and resolve the best matched configured `Cldr` locale. The result is stored in `conn.private[:cldr_locale]` which is also returned by `Cldr.Plug.AcceptLanguage.get_cldr_locale/1`.

  * `Cldr.Plug.SetLocale` which will identify a requested locale in the request parameters or `accept-language` header and will set both/either `Cldr` and `Gettext` locales. The result is also stored in `conn.private[:cldr_locale]` and is returned by `Cldr.Plug.SetLocale.get_cldr_locale/1`.

* `%LanguageTag{}` includes a new field `:gettext_locale_name` which will be matched if possible to a configured `Gettext` locale to aid cross-library collaboration.

* Refactored the functions in `Cldr.Map`

