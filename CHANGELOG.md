## Changelog for Cldr v0.0.2 September 12, 2016

### Enhancements

* Unbundled the CLDR repository data from hex package.  Locales are now downloaded at compile time if a configured locale is not already installed in the application.

### Bug fixes

* Fixes scientific formatting error whereby a forced "+" sign on the exponent was not displayed.  Closes #3.

## Changelog for Cldr v.0.0.1 September 6, 2016

* Initial release.