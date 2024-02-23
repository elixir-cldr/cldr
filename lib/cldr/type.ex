defmodule Cldr.Type do
  @moduledoc false

  # Convert a map to a typespec
  def number_systems() do
    systems_ast =
      Cldr.Config.number_systems()
      |> Enum.map(fn
        {system, %{digits: _digits, type: :numeric}} ->
          {system, {:%{}, [],
           [
             digits: string_t(),
             type: :numeric
           ]}}
        {system, %{rules: _rules, type: :algorithmic}} ->
          {system, {:%{}, [],
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

  defp string_t() do
    {{:., [], [{:__aliases__, [alias: false], [:String]}, :t]}, [], []}
  end

  def from_list(list) do
    Enum.reduce(list, fn x, acc -> {:|, [], [x, acc]} end)
  end

end