# TODO for CLDR version 43 (April 2023)

* [ ] Add a CLDR version to the generated locale files. Then when configuring a backend, if a locale is detected but its of an earlier version, force download the new version. This will overcome the issue some consumers have whereby the old locales are not removed when `ex_cldr` is updated (and reproducing this has not been possible)

* [ ] Implement a CLDR-locale-aware shim for [ex_phone_number](https://hex.pm/packages/ex_phone_number) to make it easy to integrate phone number parsing and printing

* [X] Add configuration option `:default_currency_format` to be either `:currency`, `:accounting` or `nil`. This is used by `ex_cldr_number` version 2.30.0 onwards.