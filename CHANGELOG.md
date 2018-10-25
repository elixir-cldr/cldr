# Changelog for Cldr v2.0.0

This is the changelog for Cldr v2.0.0 released on ______, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Purpose

Version 2.0 of Cldr is focused on re-architecting the module structure to more closely follow the model set by Phoenix, Gettext and others that also rely on generating a public API at compile time.  In Cldr version 1.x, the compile functions were all hosted within the ex_cldr package itself which has created several challenges:

* Only one configuration
* Dependency compilation order couldn't be determined
* Code in the ex_cldr _build directory would be modified when the configuration change

### Breaking Changes

* Configuration
* Public API
* Remove sigil
* Plugs need to have a config key :cldr to specify the backend



