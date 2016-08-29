# Configuring Cldr

**Configuration**

`Cldr` tries to be a good neighbour to `Gettext` and will use `Gettext`'s locale configuration if that is available.  In some cases its also useful to configure locales indpendently of `Gettext` and `Cldr` provides for this.  A typical configuration file would look like the following which will use whatever locales are configured in `Gettext` as well as the locales `"fr", "en", "bs", "si", "ak", "th"` whether or not they are configured in `Gettext`.

     config :cldr,
      default_locale: "en",
      locales: ["fr", "en", "bs", "si", "ak", "th"],
      gettext: Cldr.Gettext

Its also perfectly ok to use `Cldr` without `Gettext`:

     config :cldr,
      default_locale: "en",
      locales: ["fr", "en", "bs", "si", "ak", "th"]

All locales (currently 511) can be configured by specifying `:all` in the `locales:` key.

     config :cldr,
      default_locale: "en",
      locales: :all

Note that this is rarely the right production strategy: compilation takes minutes for a start.  But it is useful for testing 'Cldr' itself.

***Default locale***

The default locale can be specified, and it is not specified then the default locale becomes `en`
