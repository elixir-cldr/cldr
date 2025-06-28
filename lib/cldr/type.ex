defmodule Cldr.Type do
  @moduledoc false

  alias Cldr.Timezone

  # Convert a map to a typespec
  def number_systems() do
    systems_ast =
      Cldr.Config.number_systems()
      |> Enum.map(fn
        {system, %{digits: _digits, type: :numeric}} ->
          {system,
           {:%{}, [],
            [
              digits: string_t(),
              type: :numeric
            ]}}

        {system, %{rules: _rules, type: :algorithmic}} ->
          {system,
           {:%{}, [],
            [
              rules: string_t(),
              type: :algorithmic
            ]}}
      end)

    {:%{}, [], systems_ast}
  end

  def territory_containment(containment) do
    containment_ast =
      Enum.map(containment, fn {territory, contained} ->
        {territory, [from_list(contained), {:..., [], Elixir}]}
      end)

    {:%{}, [], containment_ast}
  end

  def subdivision_containment() do
    quote do
      %{
        (subdivision_code :: Cldr.Locale.subdivision_code()) =>
          contained_within :: [Cldr.Locale.territory_code() | Cldr.Locale.subdivision_code(), ...]
      }
    end
  end

  def timezones_by_territory(territory_timezones) do
    timezone_ast =
      Enum.map(territory_timezones, fn {territory, _timezones} ->
        {territory, territory_list()}
      end)

    {:%{}, [], timezone_ast}
  end

  def aliases(aliases) do
    alias_ast =
      Enum.map(aliases, fn
        {:language, _languages} ->
          {:language, language_list()}

        {:region, _regions} ->
          {:region, region_list()}

        {:zone, _zones} ->
          {:zone, zone_list()}

        {:variant, _variants} ->
          {:variant, variant_list()}

        {:script, _scripts} ->
          {:script, script_list()}

        {:subdivision, _subdivisions} ->
          {:subdivision, subdivision_list()}
      end)

    {:%{}, [], alias_ast}
  end

  defp string_t() do
    {{:., [], [{:__aliases__, [alias: false], [:String]}, :t]}, [], []}
  end

  defp territory_list do
    quote do
      [Timezone.timezone(), ...]
    end
  end

  defp subdivision_list do
    quote do
      %{
        (subdivision_alias :: String.t()) =>
          subdivision ::
            Cldr.Locale.territory_code()
            | Cldr.Locale.subdivision_code()
            | [Cldr.Locale.subdivision_code(), ...]
      }
    end
  end

  defp zone_list() do
    quote do
      %{(zone_alias :: String.t()) => String.t() | %{(city :: String.t()) => zone :: String.t()}}
    end
  end

  defp region_list() do
    quote do
      %{(region_alias :: String.t()) => region :: String.t()}
    end
  end

  defp variant_list() do
    quote do
      %{(variant_alias :: String.t()) => variant :: String.t()}
    end
  end

  defp language_list() do
    quote do
      %{(language :: String.t()) => language_tag :: Cldr.LanguageTag.t()}
    end
  end

  defp script_list() do
    quote do
      %{(script_alias :: String.t()) => script :: String.t()}
    end
  end

  def from_list(list) do
    Enum.reduce(list, fn x, acc -> {:|, [], [x, acc]} end)
  end
end
