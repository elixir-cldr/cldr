# List Localization

`Cldr` interprets the CLDR rules for list formatting is a locale-specific way.  The list is recursed over and the list elements are passed to `Kernel.to_string/1` therefore the list elements can be anything that can be understood by `Kernel.to_string/1`.

`Cldr` includes list formatting, see `Cldr.List` and `Cldr.List.to_string/2`.

## Public API

The primary api for list formatting is `Cldr.List.to_string/2`.  It provides the ability to format lists in a standard way for configured locales. For example:

```elixir
iex> Cldr.List.to_string(["a", "b", "c"], locale: "en")
{:ok, "a, b, and c"}

iex> Cldr.List.to_string(["a", "b", "c"], locale: "en", format: :unit_narrow)
{:ok, "a b c"}

iex> Cldr.List.to_string(["a", "b", "c"], locale: "fr")
{:ok, "a, b et c"}

iex> Cldr.List.to_string([1,2,3,4,5,6])
{:ok, "1, 2, 3, 4, 5, and 6"}

iex> Cldr.List.to_string(["a"])
{:ok, "a"}

iex> Cldr.List.to_string([1,2])
{:ok, "1 and 2"}
```

`Cldr.List.to_string/2` takes a Keyword list of options where the valid options are:

* `:format` where the format is any of the list pattern styles returned by `Cldr.List.list_pattern_styles_for/1`

* `:locale` where the locale is any of the locales returned by `Cldr.known_locales/0`.  The default locale is `Cldr.default_locale/0`.

## List Formats

List formats are referred to by a pattern style the standardises the way to refernce different formats in a locale.  See `Cldr.List.list_pattern_styles_for/1`.  For example:

```elixir
iex> Cldr.List.list__pattern_styles_for "en"
[:standard, :standard_short, :unit, :unit_narrow, :unit_short]

iex> Cldr.List.list_pattern_styles_for "ru"
[:standard, :standard_short, :unit, :unit_narrow, :unit_short]

iex> Cldr.List.list_pattern_styles_for "th"
[:standard, :standard_short, :unit, :unit_narrow, :unit_short]
```

## Formatting styles

The five list common formatting styles for a locale are:

* `:standard`

* `:standard_short`

* `:unit`

* `:unit_narrow`

* `:unit_short`

This list is not fixed or definitive, other styles may be present for a locale.

The definitions of these styles can be explored through `Cldr.List.list_patterns_for "locale"`. For example:

```elixir
iex> Cldr.List.list_patterns_for "fr"
%{standard: %{"2": "{0} et {1}", end: "{0} et {1}", middle: "{0}, {1}",
    start: "{0}, {1}"},
  standard_short: %{"2": "{0} et {1}", end: "{0} et {1}", middle: "{0}, {1}",
    start: "{0}, {1}"},
  unit: %{"2": "{0} et {1}", end: "{0} et {1}", middle: "{0}, {1}",
    start: "{0}, {1}"},
  unit_narrow: %{"2": "{0} {1}", end: "{0} {1}", middle: "{0} {1}",
    start: "{0} {1}"},
  unit_short: %{"2": "{0} et {1}", end: "{0} et {1}", middle: "{0}, {1}",
    start: "{0}, {1}"}}
```
