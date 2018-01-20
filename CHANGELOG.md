# Changelog for Cldr v1.3.2

This is the changelog for Cldr v1.3.0 released on January 20th, 2018.  For older changelogs please consult the release tag on [GitHub](https://github.com/kipcole9/cldr/tags)

### Bug Fixes

* Correctly retrieve the default locale from a configured Gettext backend module.  Fixes #32.

# Changelog for Cldr v1.3.1

### Bug Fixes

* Correctly use `conn.path_params` not the incorrect `conn.url_params` in `Cldr.Plug.SetLocale` and add plug router tests. Fixes #33.

* Correctly set the default locale using the Gettext default locale if the Cldr default locale isn't set but Gettext is.

# Changelog for Cldr v1.3.0

### Enhancements

* Add `Cldr.Digits.number_of_digits/1` that returns the number of digits (precision) of a float, integer or Decimal.  The primary intent is to support better detection of precision errors after parsing a float string.  A double precision 64-bit float (which is what Erlang/Elixir use) can safely support 15 digits.  According to [Wikipedia](https://en.wikipedia.org/wiki/IEEE_754#Character_representation) a decimal floating point number should round-trip convert to string representation and back for 16 digits without rounding (and 17 using "round to even").  Some examples:

```
iex> Cldr.Digits.number_of_digits(1234)
4

iex> Cldr.Digits.number_of_digits(Decimal.new("123456789"))
9

iex> Cldr.Digits.number_of_digits(1234.456)
7

iex> Cldr.Digits.number_of_digits(1234.56789098765)
15

iex> Cldr.Digits.number_of_digits '12345'
5
```

# Changelog for Cldr v1.2.0

### Bug Fixes

* The changelog refers to the configuration key `json_library` but the readme and the code refer to `json_lib`.  Standardise on `json_library`.  Thanks to @lostkobrakai.

### Enhancements

* Fix the spec for `Cldr.known_currencies/0`.  Thanks to @lostkobrakai.

# Changelog for Cldr v1.1.0

## Enhancements

* When configuring a locale name of the form "language-Script" or "language-Variant" the base "language" is also configured since plural rules will fall back to the base language if the locale name does not contain plural rules.

* When expanding wildcard locale names a more informative exception and error is produced if the regex for the locale names is invalid

* When a locale doesn't have any plural rules the error tuple `{:error, {Cldr.UnknownPluralRules, message}}` is returned instead of the current behaviour which raises an exception.

* The json library is now configurable.  This permits the use of the new json library [jason](https://hex.pm/packages/jason) or any other library that provides `decode!/1` and `encode!/1`.  The library is configured in `config.exs` as follows:

```
config :ex_cldr,
  json_library: Jason # The default is Poison
```

