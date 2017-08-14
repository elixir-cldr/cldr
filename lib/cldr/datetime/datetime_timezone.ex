defmodule Cldr.DateTime.Timezone do

  # Timezone offset is in seconds
  def time_from_zone_offset(%{utc_offset: utc_offset, std_offset: std_offset}) do
    offset = utc_offset + std_offset

    hours = div(offset, 3600)
    minutes = div((offset - (hours * 3600)), 60)
    seconds = offset - (hours * 3600) - (minutes * 60)
    {hours, minutes, seconds}
  end
end

