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

  @doc """
  Returns a mapping of CLDR short zone codes to
  IANA timezone names.

  """
  @spec timezones() :: map()
  def timezones do
    @timezones
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
end
