defmodule Cldr.Locale.Match.Test do
  use ExUnit.Case, async: true

  @ignore_tests [331]
  @dont_match_und []

  for test <- Cldr.Locale.Match.TestData.parse(),
      test.index not in @ignore_tests ++ @dont_match_und do

    supported =
      inspect(test.supported)

    supported =
      if String.length(supported) > 97 do
        elem(String.split_at(inspect(test.supported), 97), 0) <> "..."
      else
        supported
      end

    test "##{test.index} Match desired #{inspect(test.desired)} to supported #{supported}" do
      assert {:ok, unquote(test.expected), _} =
        Cldr.Locale.Match.best_match(unquote(test.desired), supported: unquote(test.supported), threshold: unquote(test.threshold))
    end
  end
end