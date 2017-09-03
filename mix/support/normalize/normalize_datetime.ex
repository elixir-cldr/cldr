# credo:disable-for-this-file
defmodule Cldr.Normalize.DateTime do
  @moduledoc """
  Takes the date part of the locale map and transforms the formats into a more easily
  processable structure that is then stored in map managed by `Cldr.Locale`
  """

  def normalize(content, locale) do
    content
    |> normalize_dates(locale)
  end

  def normalize_dates(content, _locale) do
    dates = content
    |> get_in(["dates"])
    |> Map.delete("fields")
    |> Cldr.Map.rename_key("_numbers", "number_system")
    |> Cldr.Map.rename_key("_value", "format")
    |> compile_substitution_formats

    Map.put(content, "dates", dates)
  end

  # @compile_keys ["gmt_format", "gmt_zero_format", "fallback_format",
  #                "region_format_type_standard", "region_format_type_daylight",
  #                "region_format"]
  # def compile_substitutions(content) do
  #   for key <- @compile_keys do
  #     IO.inspect Map.keys(content)
  #     IO.inspect get_in(content, ["time_zone_names"])
  #     format =
  #       content
  #       |> get_in(["time_zone_names", key])
  #       |> Cldr.Substitution.parse
  #     put_in(content, ["time_zone_names", key], format)
  #   end
  # end

  defp compile_substitution_formats(dates) do
    Enum.map(dates, fn
      {k, v} when is_binary(v) ->
        binary = if Regex.match?(~r/\{0\}/, v) do
          Cldr.Substitution.parse(v)
        else
          v
        end
        {k, binary}

      {k, v} when is_map(v) ->
        {k, Enum.into(compile_substitution_formats(v), %{})}

      {k, v} ->
        {k, v}
    end)
    |> Enum.into(%{})
  end
end