defmodule Cldr.Rbnf.Config.Test do
  use ExUnit.Case, async: true

  test "every numeric RBNF rule has an integer radix and divisor" do
    json = Cldr.Config.json_library()

    bad =
      for path <- Path.wildcard(Path.join(Cldr.Config.cldr_data_dir(), "locales/*.json")),
          rbnf = Map.get(json.decode!(File.read!(path)), "rbnf", %{}),
          {_group, rule_sets} <- rbnf,
          {name, %{"rules" => rules}} <- rule_sets,
          %{"base_value" => base_value} = rule when is_integer(base_value) <- rules,
          !(is_integer(rule["radix"]) and is_integer(rule["divisor"])) do
        {Path.basename(path, ".json"), name, base_value, rule["radix"]}
      end

    assert bad == []
  end
end
