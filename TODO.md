# TODO

See TR35 https://unicode.org/reports/tr35/tr35-general.html#locale_display_name_algorithm

* [ ] Support the territory UK as a synonum for GB

* [ ] Some region subtags are valid that aren't today supported: https://unicode-org.github.io/cldr/ldml/tr35.html#unicode_region_subtag_validity

* [ ] Normalizing variant names should be lower case per TR35

* [x] Reformat locale display name languages (in normalization) to cater for:
  * _alt_variant
  * _alt_short

* [x] Check inheritance chain for locales. In CLDR39, "nb" inherits from "no". Probably applies only to RBNF where we should be looking up parent locales if no data is found (and root as the falback).

* [x] Add parentLocales.json to the package. Should be used for RBNF locale lookup.