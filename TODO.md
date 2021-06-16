# TODO

* [ ] Resolve how to have a CLDR-based pluraliser module for Gettext. Currently this has a circular compile-time dependency because when the gettext module is compiled it expects the plurals module to exist. At the same time, ex_cldr expects the gettext backend to exist so it can find out what locales are available. This could be resolved if compiling the PO files was a final step in the compilation process but this seems unlikely to be possible.

* [ ] Ensure all language tags have a canonical form that is BCP-47. Mostly they are but we need to:
   * Replace the special language identifier "root" with the BCP 47 primary language tag "und"
   * Add an initial "und" primary language subtag if the first subtag is a script.
   * prefix any legacy language tags (marked as “Type: grandfathered” in BCP 47) with "und-x-"
   * prefix with "und-", so that there is always a base language subtag

* [ ] Implement validity data through `Cldr.Locale.{Territory, Language, Script, Variant, Subdivision}` and use it in `Cldr.Locale.canonical_language_tag/1` Use the data in priv/validity to generate json equivalents. Ensure the data files are packaged in the release as well.

* [X] Support the territory UK as a synonum for GB

* [X] Normalizing variant names should be lower case per TR35

* [X] variant and language substitutions don't respect the `und-` implied language prefix in canonicalization

* [X] remove `und` language from language tags (should be nil) including for pre-generated language tags (important for alias resolution)

* [X] `Cldr.Locale.normalize_locale_name/1` and `Cldr.to_string/1` have too much duplication between then.



