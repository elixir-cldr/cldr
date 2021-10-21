# TODO

* [ ] Resolve how to have a CLDR-based pluraliser module for Gettext. Currently this has a circular compile-time dependency because when the gettext module is compiled it expects the plurals module to exist. At the same time, ex_cldr expects the gettext backend to exist so it can find out what locales are available. This could be resolved if compiling the PO files was a final step in the compilation process but this seems unlikely to be possible.

* [ ] Fix the two parent locale tests (for when the locale has a variant). Possible that the inspect protocol implementation isn't the right cldr_locale_name when constructing the parent locale.
