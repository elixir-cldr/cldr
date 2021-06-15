defmodule Cldr.Timezone do
  @moduledoc """
  Functions to map between the CLDR short time zone code and the
  IANA timezone names.

  The Unicode [locale](https://unicode.org/reports/tr35/#Locale)
  [extension U](https://unicode.org/reports/tr35/#u_Extension)
  allows the specification of the time zone requested for the provided locale.

  This short timezone codes never change even if the IANA names change
  over time. Therefore these short codes are always stable between CLDR
  releases.

  """

  @timezones_file "cldr/timezones.json"
  @timezones Path.join(:code.priv_dir(Cldr.Config.app_name()), @timezones_file)
             |> File.read!()
             |> Cldr.Config.json_library().decode!
             |> Enum.reject(fn {_k, v} -> v == [""] end)
             |> Map.new()

  @timezones_for_territory @timezones
                           |> Enum.group_by(fn {k, _v} -> String.slice(k, 0, 2) end, fn {_k, v} ->
                             v
                           end)
                           |> Enum.map(fn {k, v} ->
                             case Cldr.validate_territory(k) do
                               {:ok, territory} -> {territory, List.flatten(v)}
                               {:error, _} -> nil
                             end
                           end)
                           |> Enum.reject(&is_nil/1)
                           |> Map.new()

  @doc """
  Returns a mapping of CLDR short zone codes to
  IANA timezone names.

  """
  @spec timezones() :: map()
  def timezones do
    @timezones
  end

  @doc """
  Returns a mapping of territories to
  their known IANA timezone names.

  """
  @spec timezones_for_territory() :: map()
  def timezones_for_territory do
    @timezones_for_territory
  end

  @doc """
  Returns a list of IANA time zone names for
  a given CLDR short zone code, or `nil`

  ### Examples

      iex> Cldr.Timezone.fetch("ausyd")
      ["Australia/Sydney", "Australia/ACT", "Australia/Canberra", "Australia/NSW"]}

      iex> Cldr.Timezone.fetch("nope")
      nil

  """
  @spec get(String.t(), String.t() | nil) :: [String.t()] | nil
  def get(short_zone, default \\ nil) do
    Map.get(timezones(), short_zone, default)
  end

  @doc """
  Returns a `:{:ok, list}` where list is a
  list of IANA timezone names for
  a given CLDR short zone code. If no such
  short code exists then `:error` is returned.

  ### Example

      iex> Cldr.Timezone.fetch("ausyd")
      {:ok,
       ["Australia/Sydney", "Australia/ACT", "Australia/Canberra", "Australia/NSW"]}

      iex> Cldr.Timezone.fetch("nope")
      :error

  """
  @spec fetch(String.t()) :: {:ok, [String.t()]} | :error
  def fetch(short_zone) do
    Map.fetch(timezones(), short_zone)
  end

  @doc false
  @spec validate_timezone(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def validate_timezone(short_zone) do
    case fetch(short_zone) do
      {:ok, [first_zone | _others]} ->
        {:ok, first_zone}

      :error ->
        {:error, short_zone}
    end
  end

  @doc false
  def timezones_for_territory(territory) do
    timezones_for_territory()
    |> Map.fetch(territory)
  end
end
