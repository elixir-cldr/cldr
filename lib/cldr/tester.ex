defmodule Cldr.Tester do
  def for_locale(locale) do
    json_data_file = "./test/support/rbnf/#{locale}/rbnf_test.json"
    file_data = File.read(json_data_file)

    case file_data do
      {:error, _} ->
        :no_such_locale_test_file
      {:ok, json_string} ->
        json_data = json_string
        |> Poison.decode!

        if (rbnf_data = Cldr.Locale.get_locale(locale)[:rbnf]) != %{} do
          Enum.each Map.keys(json_data), fn rule_group ->
            if rbnf_data[String.to_atom(rule_group)] do
              module = "Elixir.Cldr.Rbnf.#{rule_group}"
              |> String.replace("Rules", "")
              |> String.to_atom

              Enum.each json_data[rule_group], fn {rule_set, tests} ->
                function = rule_set
                |> String.replace("-","_")
                |> String.to_atom

                Enum.each tests, fn {test_data, test_result} ->
                  res = apply(module, function, [String.to_integer(test_data), locale])
                  if res != test_result do
                    IO.puts "#{module}.#{function}(#{test_data}, #{inspect(locale)})"
                    IO.puts "  Expected: #{inspect test_result}"
                    IO.puts "  Got:      #{inspect res}"
                  end
                end
              end
            end
          end
        end
    end
  end
end