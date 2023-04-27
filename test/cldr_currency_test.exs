defmodule Cldr.CurrencyTest do
  use ExUnit.Case, async: true

  test "Currencies default symbol is the same as the code" do
    assert "THB" == Cldr.Config.currencies_for!(:en, TestBackend.Cldr) |> Map.get(:THB) |> Map.get(:symbol)
    assert "COP" == Cldr.Config.currencies_for!(:en, TestBackend.Cldr) |> Map.get(:COP) |> Map.get(:symbol)
  end
end