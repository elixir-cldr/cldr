defmodule Cldr.Normalize.LanguageMatching do
  def normalize(content) do
    content
    |> get_in(["supplemental", "languageMatching"])
    |> Cldr.Map.underscore_keys()
    |> Cldr.Map.rename_keys("_desired", "desired")
    |> Cldr.Map.rename_keys("_distance", "distance")
    |> Cldr.Map.rename_keys("_supported", "supported")
    |> Cldr.Map.rename_keys("_value", "value")
    |> Cldr.Map.rename_keys("_locales", "locales")
    |> Cldr.Map.rename_keys("_oneway", "one_way")
    |> Cldr.Map.deep_map(fn {"value", v} ->
      {"value", String.split(v, "+")} end,
      filter: "match_variables", only: "value")
    |> parse_language_matches()
    |> expand_match_variables()
    |> Cldr.Map.atomize_keys()
    |> Map.fetch!(:written_new)
  end

  defp parse_language_matches(matching) do
    language_match =
      matching
      |> get_in(["written_new", "language_match"])
      |> Enum.map(&parse_match/1)

    put_in(matching, ["written_new", "language_match"], language_match)
  end

  def parse_match(match) do
    supported = parse_match_skeleton(match["supported"])
    desired = parse_match_skeleton(match["desired"])

    match
    |> Map.put("supported", supported)
    |> Map.put("desired", desired)
  end

  def parse_match_skeleton(skeleton) do
    case String.split(skeleton, "-") do
      [language] ->
        [language]
      [language, script] ->
        [language, String.to_atom(script)]
      [language, script, territory] ->
        [language, String.to_atom(script), parse_territory(territory)]
    end
    |> case do
      ["*", script, territory] -> [:*, script, territory]
      other -> other
    end
  end

  def parse_territory("$!" <> match_variable) do
    [:not_in, String.to_atom("$" <> match_variable)]
  end

  def parse_territory("$" <> match_variable) do
    [:in, String.to_atom("$" <> match_variable)]
  end

  def parse_territory(territory) do
    String.to_atom(territory)
  end

  def expand_match_variables(matching) do
    variables =
      matching
      |> get_in(["written_new", "match_variables"])
      |> Enum.map(&expand_variable/1)
      |> Map.new()

    put_in(matching, ["written_new", "match_variables"], variables)
  end

  def expand_variable({"$en_us", value}) do
    expand_variable({"$enUS", value})
  end

  def expand_variable({variable, %{"value" => value}}) do
    expanded =
      Enum.map(value, fn territory ->
        territory
        |> String.to_atom()
        |> expand_territory()
      end)
      |> List.flatten()

    {variable, expanded}
  end

  def expand_territory(territory) do
    if contained = Map.get(Cldr.Config.territory_containers(), territory) do
      [territory | Enum.map(contained, &expand_territory/1)]
    else
      territory
    end
  end
end