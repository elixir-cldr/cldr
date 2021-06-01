# TODO

See TR35 https://unicode.org/reports/tr35/tr35-general.html#locale_display_name_algorithm

* [ ] Support the territory UK as a synonum for GB

* [ ] Some region subtags are valid that aren't today supported: https://unicode-org.github.io/cldr/ldml/tr35.html#unicode_region_subtag_validity

* [X] Normalizing variant names should be lower case per TR35

* [ ] variant and language substitutions don't respect the `und-` implied language prefix in canonicalization

* [ ] remove `und` language from langauge tags (should be nil) including for pre-generated language tags (important for alias resolution)

* [ ] `Cldr.Locale.normalize_locale_name/1` and `Cldr.to_string/1` have too much duplication between then.