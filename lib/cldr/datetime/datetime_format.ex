defmodule Cldr.DateTime.Format do

  def date_format_list do
    Cldr.known_locales()
    |> Enum.map(fn locale -> get_locale_date_formats(locale) end)
    |> List.flatten
    |> Enum.uniq
  end

  def get_locale_date_formats(locale) do
    Enum.map Cldr.get_locale(locale).dates.calendars, fn {_calendar, content} ->
      Map.values(content.date_formats)
    end
  end

end