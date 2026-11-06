# TODO

Known defects and parked work in `ex_cldr`. The library is in maintenance mode (see `STATUS.md`): defects users report are fixed and released, while defects found in review are recorded here and deferred, because development time goes to Localize. An item is revived when someone reports it.

## Deferred

* [ ] **`Cldr.requested_locale_names/1` always raises** — it calls `backend.requested_locale_names/0`, which no backend has defined since v2.0, so every call raises `UndefinedFunctionError` (on Elixir 1.20 after a warning about the call having no parentheses). Found in review of PR #275 on 2026-11-07, not reported.

* [ ] **Record the CLDR version in generated locale files** — when a backend finds a locale file from an earlier CLDR version, download the current one, so locale files left behind by an `ex_cldr` upgrade are replaced. Functional work, parked by maintenance mode.

* [ ] **CLDR-aware shim for `ex_phone_number`** — make phone number parsing and printing easy to integrate with a backend. Functional work, parked by maintenance mode; Localize has `localize_phonenumber`.

## Done

* [x] **`:default_currency_format` backend option** — `:currency`, `:accounting` or `nil`, used by `ex_cldr_numbers` 2.30.0 onwards. 2023-03-07, v2.35.0.
