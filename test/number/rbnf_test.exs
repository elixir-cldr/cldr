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

  test "roman numerals" do
    assert Cldr.Number.to_string(1, format: :roman) == "I"
    assert Cldr.Number.to_string(2, format: :roman) == "II"
    assert Cldr.Number.to_string(3, format: :roman) == "III"
    assert Cldr.Number.to_string(4, format: :roman) == "IV"
    assert Cldr.Number.to_string(5, format: :roman) == "V"
    assert Cldr.Number.to_string(6, format: :roman) == "VI"
    assert Cldr.Number.to_string(7, format: :roman) == "VII"
    assert Cldr.Number.to_string(8, format: :roman) == "VIII"
    assert Cldr.Number.to_string(9, format: :roman) == "IX"
    assert Cldr.Number.to_string(10, format: :roman) == "X"
    assert Cldr.Number.to_string(11, format: :roman) == "XI"
    assert Cldr.Number.to_string(20, format: :roman) == "XX"
    assert Cldr.Number.to_string(50, format: :roman) == "L"
    assert Cldr.Number.to_string(90, format: :roman) == "XC"
    assert Cldr.Number.to_string(100, format: :roman) == "C"
    assert Cldr.Number.to_string(1000, format: :roman) == "M"
    assert Cldr.Number.to_string(123, format: :roman) == "CXXIII"
  end


  # Come back later an investigate why we get different results
  locales = Cldr.known_locales()
  |> List.delete("ru")
  |> List.delete("be")
  |> List.delete("es")
  |> List.delete("zh")
  |> List.delete("vi")
  |> List.delete("ko")
  |> List.delete("it")
  |> List.delete("ms")
  |> List.delete("ja")
  |> List.delete("pl")
  |> List.delete("he")
  |> List.delete("zh-Hant")
  |> List.delete("af")
  |> List.delete("hr")

  for locale <- locales do
    json_data_file = "./test/support/rbnf/#{locale}/rbnf_test.json"
    file_data = File.read(json_data_file)

    case file_data do
      {:error, _} ->
        :no_such_locale_test_file
      {:ok, json_string} ->
        json_data = json_string
        |> Poison.decode!

        if Cldr.Locale.get_locale(locale)[:rbnf] != %{} do
          if (rbnf_data = Cldr.Locale.get_locale(locale)[:rbnf]) != %{} do
            Enum.each Map.keys(json_data), fn rule_group ->
              if rbnf_data[String.to_existing_atom(rule_group)] do
                module = "Elixir.Cldr.Rbnf.#{rule_group}"
                |> String.replace("Rules", "")
                |> String.to_atom

                Enum.each json_data[rule_group], fn {rule_set, tests} ->
                  function = rule_set
                  |> String.replace("-","_")
                  |> String.to_atom

                  name = "#{module}.#{function} for locale #{inspect locale}"
                  |> String.replace("−", "-")
                  |> Cldr.Number.String.clean

                  test name do
                    Enum.each unquote(Macro.escape(tests)), fn {test_data, test_result} ->
                      assert apply(unquote(module), unquote(function), [String.to_integer(test_data), unquote(locale)])
                      == test_result
                    end
                  end
                end
              end
            end
          end
        end
    end
  end
end