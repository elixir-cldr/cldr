# TODO for Cldr 2.20.0

See TR35 https://unicode.org/reports/tr35/tr35-general.html#locale_display_name_algorithm

* [x] Reformat locale display name languages (in normalization) to cater for:
  * _alt_variant
  * _alt_short

* [ ] Check inheritance chain for locales. In CLDR39, "nb" inherits from "no". Probably applies only to RBNF where we should be looking up parent locales if no data is found (and root as the falback).

* [ ] Add parentLocales.json to the package. Should be used for RBNF locale lookup.