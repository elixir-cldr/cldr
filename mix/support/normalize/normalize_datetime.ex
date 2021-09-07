# credo:disable-for-this-file
defmodule Cldr.Normalize.DateTime do
  @moduledoc false

  def normalize(content, locale) do
    content
    |> normalize_dates(locale)
  end

  def normalize_dates(content, _locale) do
    dates =
      content
      |> get_in(["dates"])
      |> Map.delete("fields")
      |> Cldr.Map.rename_keys("_numbers", "number_system")
      |> Cldr.Map.rename_keys("_value", "format")
      |> normalize_date_formats
      |> compile_substitution_formats

    Map.put(content, "dates", dates)
  end

  defp compile_substitution_formats(dates) do
    Enum.map(dates, fn
      {"date_time_formats" = k, v} ->
        {k, v}

      {k, v} when is_binary(v) ->
        binary =
          if Regex.match?(~r/\{0\}/, v) do
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

  defp normalize_date_formats(dates) do
    dates
    |> Cldr.Map.deep_map(fn
      {"number_system" = k, v} ->
        v =
          v
          |> String.split(";")
          |> Enum.map(&split_number_system/1)
          |> Map.new()
       {k, v}

      {k, v} ->
        {k, v}
    end)
  end

  defp split_number_system(system) do
    case String.split(system, "=") do
      [system] -> {"all", String.trim(system)}
      [format_code, system] -> {String.trim(format_code), String.trim(system)}
    end
  end
end
