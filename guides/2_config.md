# Configuring Cldr

`Cldr` attempts to maximise runtime performance at the expense of additional compile time.  Where possible `Cldr` will create functions to encapsulate data at compile time.  To perform these optimizations for all 511 locales known to Cldr wouldn't be an effective use of your time or your computers.  So `Cldr` requires that you configure the locales you want to use. You can do this in your `mix.exs` by specifying the locales you want to configure or by telling `Cldr` about a `Gettext` module you may already have configured - in which case `Cldr` will configure whatever locales you have configured in `Gettext`.

Here's an example configuration that uses all of the available configuration keys.

     config :cldr,
       default_locale: "en",
       locales: ["fr", "en", "bs", "si", "ak", "th"],
       gettext: MyApp.Gettext,
       data_dir: "./priv/cldr",
       precompile_number_formats: ["¤¤#,##0.##"]

## Configuration Keys

The configuration keys available for `Cldr` are:

 * `default_locale` specifies the default locale to be used if none has been set by `Cldr.put_locale/2` and none has been set in a configured `Gettext` module.  The default locale in case no other locale has been set is `"en"`.  Default locale calculated by:

     * If set by the `:default_locale` key, then this is the priority
     * If no `:default_locale` key, the a configured `Gettext` default locale is chosen
     * If no `:default_locale` key is specified and no `Gettext` module is configured, or is configured but has not default set, then the default locale will be `"en"`

 * `locales`: Defines what locales will be configured in `Cldr`.  Only these locales will be available and an exception `Cldr.UnknownLocaleError` will be raised if there is an attempt to use an unknown locale.  This is the same behaviour as `Gettext`.  Locales are configured as a list of binaries (strings).  For convenince it is possible to use wildcard matching of locales which is particulalry helpful when there are many regional variances of a single language locale.  For example, there are over 100 regional variants of the "en" locale in CLDR.  A wildcard locale is detected by the presence of `.`, `[`, `*` and `+` in the locale string.  This locale is then matched using the pattern as a `regex` to match against all available locales.  For example:

        config :cldr,
          default_locale: "en",
          locales: ["en-*", "fr"]

   will configure all locales that start with `en-` and the locale `fr`.

   There is one additional setting which is `:all` which will configure all 514 locales.  **This is highly discouraged** since it will take many minutes to compile your project and will consume more memory than you really want.  This setting is there to aid in running the test suite.  Really, don't use this setting.

 * `gettext`: configures `Cldr` to use a `Gettext` module as a source of defining what locales you want to configure.  Since `Gettext` uses locales with an '\_' in them and `Cldr` uses a '-', `Cldr` will transliterate locale names from `Gettext` into the `Cldr` canonical form.

 * `data_dir`: indicates where downloaded locale files will be stored.  The default is `:code.priv_dir(:ex_cldr)`.

 * `precompiler_number_formats`: provides a means to have user-defined format strings precompiled at application compile time.  This has a performance benefit since precompiled formats execute approximately twice as fast as formats that are not precompiled.
