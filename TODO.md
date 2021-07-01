# TODO

* [ ] Resolve how to have a CLDR-based pluraliser module for Gettext. Currently this has a circular compile-time dependency because when the gettext module is compiled it expects the plurals module to exist. At the same time, ex_cldr expects the gettext backend to exist so it can find out what locales are available. This could be resolved if compiling the PO files was a final step in the compilation process but this seems unlikely to be possible.

* [X] canonical_locale_name should combine extensions (sorted by key)

* [X] parse and validate 't' extension (and add to_string)

* [X] add Cldr.validate_script/1

* [X] scripts can be an atom (now that they are validated)

* [X] Use validity data in `Cldr.Locale.canonical_language_tag/1`

* [X] Implement validity data through `Cldr.Locale.{Territory, Language, Script, Variant, Subdivision}`

* [X] Support the territory UK as a synonym for GB

* [X] Normalizing variant names should be lower case per TR35

* [X] variant and language substitutions must respect the `und-` implied language prefix in canonicalization

* [X] remove `und` language from language tags (should be nil) including for pre-generated language tags (important for alias resolution)

* [X] `Cldr.Locale.normalize_locale_name/1` and `Cldr.to_string/1` have too much duplication between then.

* [X] Ensure all language tags have a canonical form that is BCP-47. Mostly they are but we need to:
   * [X] Replace the special language identifier "root" with the BCP 47 primary language tag "und"

* locale display names data normalization needs adjusting
  * [X] territories need to be normalized (upcased and atomized)
  * [X] scripts and territories have some alt forms that need to be structured
