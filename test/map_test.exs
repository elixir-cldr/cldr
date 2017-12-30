defmodule Support.Map.Test do
  use ExUnit.Case

  test "that map keys are underscored" do
    assert Cldr.Map.underscore_keys(%{"thisKey" => "value"}) == %{"this_key" => "value"}
  end

  test "that map keys are atomised" do
    assert Cldr.Map.atomize_keys(%{"thisKey" => "value"}) == %{thisKey: "value"}
  end

  test "that nested map keys are atomised" do
    test_map = %{
      "key" => %{
        "nested" => "value"
      }
    }

    test_result = %{
      key: %{
        nested: "value"
      }
    }

    assert Cldr.Map.atomize_keys(test_map) == test_result
  end
end
