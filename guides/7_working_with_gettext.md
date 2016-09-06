# Working with Gettext

`Cldr` wants to be a good neighbour to `Gettext` without introducing any dependencies either way.  There are three integration points:

* `Gettext` can be used as a source of configuration information, both to define what locales are configured and to define what is the default locale.  This is described in the [configuration guide](2_config.html)

* `Cldr.Gettext.Plural` provides a plurals module that can be configured in `Gettext`.  Note this module is only compiled and available if `Gettext` is configured in your project `deps`. See `Cldr.Gettext.Plural`.

* `Cldr.Plug.Locale` which is a plug intended to fully parse the HTTP `accept-language` header to derive locale settings.  This is intended to ease integration for `Phoenix` apps.  **The plug is not development complete!**