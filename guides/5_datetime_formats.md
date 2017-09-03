# Date, Time and DateTime Localization and Formatting

## Introduction & Getting Started

`ex_cldr_dates_times` is an addon library application for [ex_cldr](https://hex.pm/packages/ex_cldr) that provides localisation and formatting for dates, times and date_times.

The primary api is `Cldr.Date.to_string/2`, `Cldr.Time.to_string/2`, `Cldr.DateTime.to_string/2` and `Cldr.DateTime.Relative.to_string`.  The following examples demonstrate:

```elixir
iex> Cldr.Date.to_string Date.utc_today()
{:ok, "Aug 18, 2017"}

iex> Cldr.Time.to_string Time.utc_now
{:ok, "11:38:55 AM"}

iex> Cldr.DateTime.to_string DateTime.utc_now
{:ok, "Aug 18, 2017, 11:39:08 AM"}

iex> Cldr.DateTime.Relative.to_string(1, unit: :day, format: :narrow)
{:ok, "tomorrow"}
```

For help in `iex`:

```elixir
iex> h Cldr.Date.to_string
iex> h Cldr.Time.to_string
iex> h Cldr.DateTime.to_string
iex> h Cldr.DateTime.Relative.to_string
```

## Date, Time and DateTime Localization Formatting

Dates, Times and DateTimes can be formatting using:

* The format types defined for each locale.  These format types provide cross-locale standardisation and therefore should be preferred where possible.  The format types, implemented for `Cldr.Date.to_string/2`, `Cldr.Time.to_string/2`,`Cldr.DateTime.to_string/2` are `:short`, `:medium`, `:long`  and `:full`.   The default is `:medium`. For example:

```elixir
iex> Cldr.DateTime.to_string DateTime.utc_now, format: :short
{:ok, "9/3/17, 11:25 PM"}
iex> Cldr.DateTime.to_string DateTime.utc_now, format: :long
{:ok, "September 3, 2017 at 11:25:41 PM UTC"}
iex> Cldr.DateTime.to_string DateTime.utc_now, format: :medium
{:ok, "Sep 3, 2017, 11:25:46 PM"}
iex> Cldr.DateTime.to_string DateTime.utc_now, format: :long, locale: "fr"
{:ok, "3 septembre 2017 à 23:25:55 UTC"}
```

* A user specified format string.  A format string uses one or more formatting symbols to define what date and time elements should be places in the format.  A simple example to format the time into hours and minutes:

```elixir
iex> Cldr.DateTime.to_string DateTime.utc_now, format: "hh:MM"
{:ok, "11:09"}
```

* For `DateTime`s there is also a set of predefined format name.  These format names are returned by `Cldr.DateTime.date_time_available_formats/1`.  The set of common format names across all locales configured in `ex_cldr` can be returned by `Cldr.DateTime.Format.common_date_time_format_names`.  These format names can be used with the `:format` paramater to `Cldr.DateTime.to_string/2` module only.

```elixir
iex> Cldr.DateTime.Format.date_time_available_formats
%{mmmm_w_count_one: "'week' W 'of' MMMM", gy_mmm: "MMM y G", md: "M/d",
  mmm_md: "MMMM d", e_hms: "E HH:mm:ss", ed: "d E", y_mmm: "MMM y",
  e_hm: "E HH:mm", mmm_ed: "E, MMM d", y_mmm_ed: "E, MMM d, y",
  gy_mm_md: "MMM d, y G", mmm: "LLL", y_md: "M/d/y", gy: "y G",
  hms: "h:mm:ss a", hm: "h:mm a", y_mmmm: "MMMM y", m: "L",
  gy_mmm_ed: "E, MMM d, y G", y_qqq: "QQQ y", e: "ccc", y_qqqq: "QQQQ y",
  hmsv: "h:mm:ss a v", mmmm_w_count_other: "'week' W 'of' MMMM",
  ehm: "E h:mm a", y_m_ed: "E, M/d/y", h: "h a", hmv: "h:mm a v",
  yw_count_other: "'week' w 'of' y", mm_md: "MMM d", y_m: "M/y", m_ed: "E, M/d",
  ms: "mm:ss", d: "d", y_mm_md: "MMM d, y", yw_count_one: "'week' w 'of' y",
  y: "y", ehms: "E h:mm:ss a"}

iex> Cldr.DateTime.Format.common_date_time_format_names
[:gy_mmm, :md, :mmm_md, :e_hms, :ed, :y_mmm, :e_hm, :mmm_ed, :y_mmm_ed,
 :gy_mm_md, :mmm, :y_md, :gy, :hms, :hm, :y_mmmm, :m, :gy_mmm_ed, :y_qqq, :e,
 :y_qqqq, :hmsv, :mmmm_w_count_other, :ehm, :y_m_ed, :h, :hmv, :yw_count_other,
 :mm_md, :y_m, :m_ed, :ms, :d, :y_mm_md, :y, :ehms]

iex> Cldr.DateTime.to_string DateTime.utc_now, format: :gy_mmm_ed
{:ok, "Sun, Sep 3, 2017 AD"}
```

## Format strings

  The [CLDR standard](http://unicode.org/reports/tr35/tr35-dates.html#Date_Field_Symbol_Table)
  defines a wide range of format symbols.  Most - but not
  all - of these symbols are supported in `Cldr`.  The supported
  symbols are described below.

  | Element                | Symbol     | Example         | Cldr Format                        |
  | :--------------------  | :--------  | :-------------- | :--------------------------------- |
  | Era                    | G, GG, GGG | "AD"            | Abbreviated                        |
  |                        | GGGG       | "Anno Domini"   | Wide                               |
  |                        | GGGGG      | "A"             | Narrow                             |
  | Year                   | y          | 7               | Minimum necessary digits           |
  |                        | yy         | "17"            | Least significant 2 digits         |
  |                        | yyy        | "017", "2017"   | Padded to at least 3 digits        |
  |                        | yyyy       | "2017"          | Padded to at least 4 digits        |
  |                        | yyyyy      | "02017"         | Padded to at least 5 digits        |
  | ISOWeek Year           | Y          | 7               | Minimum necessary digits           |
  |                        | YY         | "17"            | Least significant 2 digits         |
  |                        | YYY        | "017", "2017"   | Padded to at least 3 digits        |
  |                        | YYYY       | "2017"          | Padded to at least 4 digits        |
  |                        | YYYYY      | "02017"         | Padded to at least 5 digits        |
  | Related Gregorian Year | r, rr, rr+ | 2017            | Minimum necessary digits           |
  | Cyclic Year            | U, UU, UUU | "甲子"           | Abbreviated                        |
  |                        | UUUU       | "甲子" (for now) | Wide                               |
  |                        | UUUUU      | "甲子" (for now) | Narrow                             |
  | Extended Year          | u+         | 4601            | Minimim necessary digits           |
  | Quarter                | Q          | 2               | Single digit                       |
  |                        | QQ         | "02"            | Two digits                         |
  |                        | QQQ        | "Q2"            | Abbreviated                        |
  |                        | QQQQ       | "2nd quarter"   | Wide                               |
  |                        | QQQQQ      | "2"             | Narrow                             |
  | Standalone Quarter     | q          | 2               | Single digit                       |
  |                        | qq         | "02"            | Two digits                         |
  |                        | qqq        | "Q2"            | Abbreviated                        |
  |                        | qqqq       | "2nd quarter"   | Wide                               |
  |                        | qqqqq      | "2"             | Narrow                             |
  | Month                  | M          | 9               | Single digit                       |
  |                        | MM         | "09"            | Two digits                         |
  |                        | MMM        | "Sep"           | Abbreviated                        |
  |                        | MMMM       | "September"     | Wide                               |
  |                        | MMMMM      | "S"             | Narrow                             |
  | Standalone Month       | L          | 9               | Single digit                       |
  |                        | LL         | "09"            | Two digits                         |
  |                        | LLL        | "Sep"           | Abbreviated                        |
  |                        | LLLL       | "September"     | Wide                               |
  |                        | LLLLL      | "S"             | Narrow                             |
  | Week of Year           | w          | 2, 22           | Single digit                       |
  |                        | ww         | 02, 22          | Two digits, zero padded            |
  | Week of Month          | W          | 2               | Single digit                       |
  | Day of Year            | D          | 3, 33, 333      | Minimum necessary digits           |
  |                        | DD         | 03, 33, 333     | Minimum of 2 digits, zero padded   |
  |                        | DDD        | 003, 033, 333   | Minimum of 3 digits, zero padded   |
  | Day of Month           | d          | 2, 22           | Minimum necessary digits           |
  |                        | dd         | 02, 22          | Two digits, zero padded            |
  | Day of Week            | E, EE, EEE | "Tue"           | Abbreviated                        |
  |                        | EEEE       | "Tuesday"       | Wide                               |
  |                        | EEEEE      | "T"             | Narrow                             |
  |                        | EEEEEE     | "Tu"            | Short                              |
  |                        | e          | 2               | Single digit                       |
  |                        | ee         | "02"            | Two digits                         |
  |                        | eee        | "Tue"           | Abbreviated                        |
  |                        | eeee       | "Tuesday"       | Wide                               |
  |                        | eeeee      | "T"             | Narrow                             |
  |                        | eeeeee     | "Tu"            | Short                              |
  | Standalone Day of Week | c, cc      | 2               | Single digit                       |
  |                        | ccc        | "Tue"           | Abbreviated                        |
  |                        | cccc       | "Tuesday"       | Wide                               |
  |                        | ccccc      | "T"             | Narrow                             |
  |                        | cccccc     | "Tu"            | Short                              |
  | AM or PM               | a, aa, aaa | "am."           | Abbreviated                        |
  |                        | aaaa       | "am."           | Wide                               |
  |                        | aaaaa      | "am"            | Narrow                             |
  | Noon, Mid, AM, PM      | b, bb, bbb | "mid."          | Abbreviated                        |
  |                        | bbbb       | "midnight"      | Wide                               |
  |                        | bbbbb      | "md"            | Narrow                             |
  | Flexible time period   | B, BB, BBB | "at night"      | Abbreviated                        |
  |                        | BBBB       | "at night"      | Wide                               |
  |                        | BBBBB      | "at night"      | Narrow                             |
  | Hour                   | h, K, H, k |                 | See the table below                |
  | Minute                 | m          | 3, 10           | Minimim digits of minutes          |
  |                        | mm         | "03", "12"      | Two digits, zero padded            |
  | Second                 | s          | 3, 48           | Minimim digits of seconds          |
  |                        | ss         | "03", "48"      | Two digits, zero padded            |
  | Fractional Seconds     | S          | 3, 48           | Minimim digits of fractional seconds |
  |                        | SS         | "03", "48"      | Two digits, zero padded            |
  | Millseconds            | A+         | 4000, 63241     | Minimim digits of milliseconds since midnight |
  | Generic non-location TZ | v         | "Etc/UTC"       | `:time_zone` key, unlocalised      |
  |                         | vvvv      | "unk"           | Generic timezone name.  Currently returns only "unk" |
  | Specific non-location TZ | z..zzz   | "UTC"           | `:zone_abbr` key, unlocalised      |
  |                         | zzzz      | "GMT"           | Delegates to `zone_gmt/4`          |
  | Timezone ID             | V         | "unk"           | `:zone_abbr` key, unlocalised      |
  |                         | VV        | "Etc/UTC        | Delegates to `zone_gmt/4`          |
  |                         | VVV       | "Unknown City"  | Exemplar city.  Not supported.     |
  |                         | VVVV      | "GMT"           | Delegates to `zone_gmt/4           |
  | ISO8601 Format          | Z..ZZZ    | "+0100"         | ISO8601 Basic Format with hours and minutes |
  |                         | ZZZZ      | "+01:00"        | Delegates to `zone_gmt/4           |
  |                         | ZZZZZ     | "+01:00:10"     | ISO8601 Extended format with optional seconds |
  | ISO8601 plus Z          | X         | "+01"           | ISO8601 Basic Format with hours and optional minutes or "Z" |
  |                         | XX        | "+0100"         | ISO8601 Basic Format with hours and minutes or "Z"          |
  |                         | XXX       | "+0100"         | ISO8601 Basic Format with hours and minutes, optional seconds or "Z" |
  |                         | XXXX      | "+010059"       | ISO8601 Basic Format with hours and minutes, optional seconds or "Z" |
  |                         | XXXXX     | "+01:00:10"     | ISO8601 Extended Format with hours and minutes, optional seconds or "Z" |
  | ISO8601 minus Z         | x         | "+0100"         | ISO8601 Basic Format with hours and optional minutes |
  |                         | xx        | "-0800"         | ISO8601 Basic Format with hours and minutes          |
  |                         | xxx       | "+01:00"        | ISO8601 Extended Format with hours and minutes       |
  |                         | xxxx      | "+010059"       | ISO8601 Basic Format with hours and minutes, optional seconds     |
  |                         | xxxxx     | "+01:00:10"     | ISO8601 Extended Format with hours and minutes, optional seconds  |
  | GMT Format              | O         | "+0100"         | Short localised GMT format        |
  |                         | OOOO      | "+010059"       | Long localised GMT format         |

## Formatting symbols for hour of day

  The hour of day can be formatted differently depending whether
  a 12- or 24-hour day is being represented and depending on the
  way in which midnight and noon are represented.  The following
  table illustrates the differences:

  | Symbol  | Midn.	|	Morning	| Noon |	Afternoon	| Midn. |
  | :----:  | :---: | :-----: | :--: | :--------: | :---: |
  |   h	    |  12	  | 1...11	|  12	 |   1...11   |  12   |
  |   K	    |   0	  | 1...11	|   0	 |   1...11   |   0   |
  |   H	    |   0	  | 1...11	|  12	 |  13...23   |   0   |
  |   k	    |  24	  | 1...11	|  12	 |  13...23   |  24   |

## Relative Date, Time and DateTime Localization Formatting

The primary API for formatting relative dates and datetimes is `Cldr.Date.Relative.to_string/2`.  Some examples:

```elixir
      iex> Cldr.Date.Relative.to_string(-1)
      {:ok, "1 second ago"}

      iex> Cldr.Date.Relative.to_string(1)
      {:ok, "in 1 second"}

      iex> Cldr.Date.Relative.to_string(1, unit: :day)
      {:ok, "tomorrow"}

      iex> Cldr.Date.Relative.to_string(1, unit: :day, locale: "fr")
      {:ok, "demain"}

      iex> Cldr.DateTime.Relative.to_string(1, unit: :day, format: :narrow)
      {:ok, "tomorrow"}

      iex> Cldr.Date.Relative.to_string(1234, unit: :year)
      {:ok, "in 1,234 years"}

      iex> Cldr.Date.Relative.to_string(1234, unit: :year, locale: "fr")
      {:ok, "dans 1 234 ans"}

      iex> Cldr.Date.Relative.to_string(31)
      {:ok, "in 31 seconds"}

      iex> Cldr.Date.Relative.to_string(~D[2017-04-29], relative_to: ~D[2017-04-26])
      {:ok, "in 3 days"}

      iex> Cldr.Date.Relative.to_string(310, format: :short, locale: "fr")
      {:ok, "dans 5 min"}

      iex> Cldr.Date.Relative.to_string(310, format: :narrow, locale: "fr")
      {:ok, "+5 min"}

      iex> Cldr.Date.Relative.to_string 2, unit: :wed, format: :short
      {:ok, "in 2 Wed."}

      iex> Cldr.Date.Relative.to_string 1, unit: :wed, format: :short
      {:ok, "next Wed."}

      iex> Cldr.Date.Relative.to_string -1, unit: :wed, format: :short
      {:ok, "last Wed."}

      iex> Cldr.Date.Relative.to_string -1, unit: :wed
      {:ok, "last Wednesday"}

      iex> Cldr.Date.Relative.to_string -1, unit: :quarter
      {:ok, "last quarter"}

      iex> Cldr.Date.Relative.to_string -1, unit: :mon, locale: "fr"
      {:ok, "lundi dernier"}

      iex> Cldr.Date.Relative.to_string(~D[2017-04-29], unit: :ziggeraut)
      {:error, {Cldr.UnknownTimeUnit,
       "Unknown time unit :ziggeraut.  Valid time units are [:day, :hour, :minute, :month, :second, :week, :year, :mon, :tue, :wed, :thu, :fri, :sat, :sun, :quarter]"}}
```

