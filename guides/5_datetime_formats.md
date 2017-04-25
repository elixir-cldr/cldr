# Date and DateTime Localization

As of version 0.2.0, formatting of relative dates and date times is supported with the `Cldr.Date.Relative` module.  The public API is `Cldr.Date.Relative.to_string/2`.

Note that date and datetime formatting is not currently support - only relative date and datetime formatting.

## Public API

The primary API for formatting relative dates and datetimes is `Cldr.Date.Relative.to_string/2`.  Some examples:

      iex> Cldr.Date.Relative.to_string(-1)
      "1 second ago"

      iex> Cldr.Date.Relative.to_string(1)
      "in 1 second"

      iex> Cldr.Date.Relative.to_string(1, unit: :day)
      "tomorrow"

      iex> Cldr.Date.Relative.to_string(1, unit: :day, locale: "fr")
      "demain"

      iex> Cldr.Date.Relative.to_string(1, unit: :day, format: :narrow)
      "tomorrow"

      iex> Cldr.Date.Relative.to_string(1234, unit: :year)
      "in 1,234 years"

      iex> Cldr.Date.Relative.to_string(1234, unit: :year, locale: "fr")
      "dans 1 234 ans"

      iex> Cldr.Date.Relative.to_string(31)
      "in 31 seconds"

      iex> Cldr.Date.Relative.to_string(~D[2017-04-29], relative_to: ~D[2017-04-26])
      "in 3 days"

      iex> Cldr.Date.Relative.to_string(310, format: :short, locale: "fr")
      "dans 5 min"

      iex> Cldr.Date.Relative.to_string(310, format: :narrow, locale: "fr")
      "+5 min"

      iex> Cldr.Date.Relative.to_string 2, unit: :wed, format: :short
      "in 2 Wed."

      iex> Cldr.Date.Relative.to_string 1, unit: :wed, format: :short
      "next Wed."

      iex> Cldr.Date.Relative.to_string -1, unit: :wed, format: :short
      "last Wed."

      iex> Cldr.Date.Relative.to_string -1, unit: :wed
      "last Wednesday"

      iex> Cldr.Date.Relative.to_string -1, unit: :quarter
      "last quarter"

      iex> Cldr.Date.Relative.to_string -1, unit: :mon, locale: "fr"
      "lundi dernier"

      iex> Cldr.Date.Relative.to_string(~D[2017-04-29], unit: :ziggeraut)
      {:error,
       "Unknown time unit :ziggeraut.  Valid time units are [:day, :hour, :minute, :month, :second, :week, :year, :mon, :tue, :wed, :thu, :fri, :sat, :sun, :quarter]"}


