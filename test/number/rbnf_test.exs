defmodule Rbnf.Test do
  use ExUnit.Case

  test "rbnf spellout" do
    assert Cldr.Number.to_string(25_340, format: :spellout) ==
     "twenty-five thousand three hundred forty"
  end

  test "rbnf spellout ordinal verbose" do
    assert Cldr.Number.to_string(123456, format: :spellout_ordinal_verbose) ==
      "one hundred and twenty-three thousand, four hundred and fifty-sixth"
  end

  test "rbnf ordinal" do
    assert Cldr.Number.to_string(123456, format: :ordinal) == "123,456th"
    assert Cldr.Number.to_string(123456, format: :ordinal, locale: "fr") == "123 456e"
  end

  test "rbnf improper fraction" do
    assert Cldr.Rbnf.Spellout.spellout_cardinal_verbose(123.456, "en") == "one hundred and twenty-three point four five six"
    assert Cldr.Rbnf.Spellout.spellout_cardinal_verbose(-123.456, "en") == "minus one hundred and twenty-three point four five six"
    assert Cldr.Rbnf.Spellout.spellout_cardinal_verbose(-0.456, "en") == "minus zero point four five six"
    assert Cldr.Rbnf.Spellout.spellout_cardinal_verbose(0.456, "en") == "zero point four five six"
    assert Cldr.Rbnf.Spellout.spellout_cardinal(0.456, "en") == "zero point four five six"
    assert Cldr.Rbnf.Spellout.spellout_cardinal(0, "en") == "zero"
    assert Cldr.Rbnf.Spellout.spellout_ordinal(0, "en") == "zeroth"
    assert Cldr.Rbnf.Spellout.spellout_ordinal(0.0, "en") == "0"
    assert Cldr.Rbnf.Spellout.spellout_ordinal(0.1, "en") == "0.1"
  end

  @en "./test/support/rbnf/en/rbnf_test.json"
  |> File.read!
  |> Poison.decode!

  @locale "en"

  Enum.each Map.keys(@en), fn rule_group ->
    module = "Elixir.Cldr.Rbnf.#{rule_group}"
    |> String.replace("Rules", "")
    |> String.to_atom

    Enum.each @en[rule_group], fn {rule_set, tests} ->
      Enum.each tests, fn {test_data, test_result} ->
        function = rule_set
        |> String.replace("-","_")
        |> String.to_atom

        name = "#{module}.#{function}(#{inspect test_data}, #{inspect @locale}) == #{inspect test_result}"
        |> String.replace("−", "-")

        test name do
          assert apply(unquote(module), unquote(function), [String.to_integer(unquote(test_data)), unquote(@locale)])
          == unquote(test_result)
        end
      end
    end
  end
end