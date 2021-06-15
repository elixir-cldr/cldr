# TODO

* [ ] Some region subtags are valid that aren't today supported: https://unicode-org.github.io/cldr/ldml/tr35.html#unicode_region_subtag_validity

* [ ] Resolve how to have a CLDR-based pluraliser module for Gettext. Currently this has a circular compile-time dependency because when the gettext module is compiled it expects the plurals module to exist. At the same time, ex_cldr expects the gettext backend to exist so it can find out what locales are available. This could be resolved if compiling the PO files was a final step in the compilation process but this seems unlikely to be possible.

* [X] Support the territory UK as a synonum for GB

* [X] Normalizing variant names should be lower case per TR35

* [X] variant and language substitutions don't respect the `und-` implied language prefix in canonicalization

* [X] remove `und` language from language tags (should be nil) including for pre-generated language tags (important for alias resolution)

* [X] `Cldr.Locale.normalize_locale_name/1` and `Cldr.to_string/1` have too much duplication between then.



