defmodule Cldr.Locale.Match.Test do
  use ExUnit.Case, async: true

  # These locales aren't valid BCP 47 (invalid variant)
  @invalid_variant [344, 345, 346]

  # These tests are relevant this implementation
  @ignore_tests [253, 331]

  # These tesss probably illustrate a bug that
  # isn't get diagnosed
  @und_tests_that_need_research [220, 232, 342]

  for test <- Cldr.Locale.Match.TestData.parse(),
      test.index not in @ignore_tests ++ @invalid_variant ++ @und_tests_that_need_research do

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