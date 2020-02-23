defmodule Cldr.Normalize.Territories do
  @moduledoc false

  alias Cldr.Locale

  def normalize(content) do
    content
    |> normalize_territory_info
  end

  def normalize_territory_info(content) do
    content
    |> Cldr.Map.remove_leading_underscores()
    |> Cldr.Map.underscore_keys()
    |> Cldr.Map.integerize_values()
    |> Cldr.Map.floatize_values()
    |> Enum.map(&normalize_territory_code/1)
    |> Enum.map(&normalize_language_codes/1)
    |> Enum.into(%{})
    |> add_currency_for_territories
    |> add_measurement_system
  end

  @key "language_population"
  def normalize_language_codes({k, v}) do
    if language_population = Map.get(v, @key) do
      language_population =
        language_population
        |> Enum.map(fn {k1, v1} -> {Locale.normalize_locale_name(k1), v1} end)
        |> Enum.into(%{})

      {k, Map.put(v, @key, language_population)}
    else
      {k, v}
    end
  end

  def add_currency_for_territories(territories) do
    currencies = Cldr.Normalize.Currency.get_currency_data()["region"]

    territories
    |> Enum.map(fn {territory, map} ->
      {territory, Map.put(map, "currency", Map.get(currencies, territory))}
    end)
    |> Enum.into(%{})
  end

  def add_measurement_system(territories) do
    systems = get_measurement_data()

    territories
    |> Enum.map(fn {territory, map} ->
      territory = String.to_atom(territory)

      measurement_system =
        %{}
        |> Map.put(
          :default,
          (get_in(systems, [:measurement_system, territory]) ||
             get_in(systems, [:measurement_system, :"001"]))
          |> Cldr.Consolidate.canonicalize_measurement_system()
        )
        |> Map.put(
          :paper_size,
          (get_in(systems, [:paper_size, territory]) || get_in(systems, [:paper_size, :"001"]))
          |> Cldr.Consolidate.canonicalize_measurement_system()
        )
        |> Map.put(
          :temperature,
          (get_in(systems, [:measurement_system_category_temperature, territory]) ||
             get_in(systems, [:measurement_system, territory]) ||
             get_in(systems, [:measurement_system, :"001"]))
          |> Cldr.Consolidate.canonicalize_measurement_system()
        )

      {territory, Map.put(map, :measurement_system, measurement_system)}
    end)
    |> Map.new()
  end

  @measurement_path Path.join(Cldr.Config.download_data_dir(), [
                      "cldr-core",
                      "/supplemental",
                      "/measurementData.json"
                    ])

  def get_measurement_data do
    @measurement_path
    |> File.read!()
    |> Jason.decode!()
    |> get_in(["supplemental", "measurementData"])
    |> Enum.map(fn {k, v} -> {Cldr.String.to_underscore(Cldr.String.underscore(k)), v} end)
    |> Enum.into(%{})
    |> Cldr.Map.atomize_keys()
  end

  defp normalize_territory_code({code, rest}) do
    {normalize_territory_code(code), rest}
  end

  defp normalize_territory_code(code) do
    String.upcase(code)
  end
end
