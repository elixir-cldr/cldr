defmodule Cldr.Locale.Distance.Test do
  use ExUnit.Case, async: true

  @maybe_incorrect_test_result []

  for test <- Cldr.Locale.Distance.TestData.parse(),
      test.index not in @maybe_incorrect_test_result do

    test "##{test.index} Distance desired #{inspect(test.desired)} to supported #{inspect(test.supported)}" do
      assert unquote(String.to_integer(test.distance)) =
        Cldr.Locale.Match.match_distance(unquote(test.desired), unquote(test.supported))
    end
  end
end