defmodule Cldr.Timezone do
  @moduledoc """
  Functions to map between the CLDR short timezone code and the
  IANA timezone names.

  The Unicode language identifier [extension U](https://unicode.org/reports/tr35/#u_Extension)
  allows the specification of the timezone requested for the provided locale. This short timezone
  codes never change even if the IANA names change over time. Therefore these short codes are
  always consistent between CLDR releases.

  """

  @timezones_file "cldr/timezones.json"
  @timezones Path.join(:code.priv_dir(:ex_cldr), @timezones_file)
  |> File.read! |> Cldr.Config.json_library.decode!

  def timezones do
    @timezones
  end

  def get(short_zone, default \\ nil) do
    Map.get(timezones(), short_zone, default)
  end

  def fetch(short_zone) do
    Map.fetch(timezones(), short_zone)
  end

  def validate_timezone(short_zone) do
    case fetch(short_zone) do
      {:ok, [first_zone | _others]} ->
        {:ok, first_zone}
      :error ->
        {:ok, {:error, short_zone}}
    end
  end

end