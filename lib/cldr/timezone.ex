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
  alias Cldr.Locale

  @type short_zone :: String.t()

  @type timezone :: %{
          aliases: [String.t(), ...],
          preferred: nil | short_zone(),
          territory: Locale.territory_code()
        }
  @unknown_zone "Etc/Unknown"

  @timezones Cldr.Config.timezones()

  @timezones_by_territory @timezones
                          |> Enum.group_by(
                            fn {_k, v} -> v.territory end,
                            fn {k, v} -> Map.put(v, :short_zone, k) end
                          )
                          |> Enum.map(fn
                            {nil, _} ->
                              nil

                            {k, v} ->
                              case Cldr.validate_territory(k) do
                                {:ok, territory} -> {territory, Elixir.List.flatten(v)}
                              end
                          end)
                          |> Enum.reject(&is_nil/1)
                          |> Map.new()

  @territories_by_timezone @timezones_by_territory
                           |> Enum.map(fn {territory, zones} ->
                             Enum.map(zones, fn zone ->
                               Enum.map(zone.aliases, fn aliass -> {aliass, territory} end)
                             end)
                           end)
                           |> List.flatten()
                           |> Enum.reject(fn {_zone, territory} -> territory == :UT end)
                           |> Map.new()

  @doc """
  Returns a mapping of CLDR short zone codes to
  IANA timezone names.

  """
  @spec timezones() :: %{(zone_name :: String.t()) => timezone()}
  def timezones do
    @timezones
  end

  @doc false
  @deprecated "Use timezones_by_territory/0 instead"
  def timezones_for_territory do
    timezones_by_territory()
  end

  @spec timezones_by_territory() ::
          unquote(Cldr.Type.timezones_by_territory(@timezones_by_territory))

  @doc """
  Returns a mapping of territories to
  their known IANA timezone names.

  """
  @dialyzer {:nowarn_function, timezones_by_territory: 0}
  def timezones_by_territory do
    @timezones_by_territory
  end

  @doc """
  Returns a mapping of time zone IDs to
  their known territory.

  A time zone can only belong to one
  territory in CLDR.

  """
  def territories_by_timezone do
    @territories_by_timezone
  end

  @doc false
  def timezones_for_territory(territory) do
    timezones_by_territory()
    |> Map.fetch(territory)
  end

  @doc """
  Returns a list of IANA time zone names for
  a given CLDR short zone code, or `nil`.

  The first time zone name in the list is
  the canonical time zone name.

  ### Examples

      iex> Cldr.Timezone.get_short_zone("ausyd")
      %{
        preferred: nil,
        aliases: ["Australia/Sydney", "Australia/ACT", "Australia/Canberra", "Australia/NSW"],
        territory: :AU
      }

      iex> Cldr.Timezone.get_short_zone("nope")
      nil

  """
  @spec get_short_zone(String.t(), String.t() | nil) :: map() | nil
  def get_short_zone(short_zone, default \\ nil) do
    Map.get(timezones(), short_zone, default)
  end

  @doc false
  @deprecated "Use get_short_zone/1 instead"
  def get(short_zone) do
    get_short_zone(short_zone)
  end

  @doc """
  Returns a `{:ok, list}` where list is a
  list of IANA timezone names for
  a given CLDR short zone code. If no such
  short code exists then `:error` is returned.

  ### Example

      iex> Cldr.Timezone.fetch_short_zone("ausyd")
      {
        :ok,
        %{
          preferred: nil,
          aliases: ["Australia/Sydney", "Australia/ACT", "Australia/Canberra", "Australia/NSW"],
          territory: :AU
        }
      }

      iex> Cldr.Timezone.fetch_short_zone("nope")
      :error

  """
  @spec fetch_short_zone(String.t()) :: {:ok, map()} | :error
  def fetch_short_zone(short_zone) do
    Map.fetch(timezones(), short_zone)
  end

  @doc false
  @deprecated "Use fetch_short_zone/1 instead"
  def fetch(short_zone) do
    fetch_short_zone(short_zone)
  end

  @doc false
  @deprecated "Use validate_short_zone/1 instead"
  def validate_timezone(short_zone) do
    validate_short_zone(short_zone)
  end

  @doc false
  @spec validate_short_zone(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def validate_short_zone(short_zone) do
    case fetch(short_zone) do
      {:ok, %{aliases: [first_zone | _others]}} ->
        {:ok, first_zone}

      :error ->
        {:error, @unknown_zone}
    end
  end
end
