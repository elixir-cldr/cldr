defmodule Cldr.Config.NumberSymbolTest do
  use ExUnit.Case, async: true

  @config TestBackend.Cldr.__cldr__(:config)

  test "sv's latn symbols leave out the alternative time separator \".\"" do
    {:ok, symbols} = Cldr.Config.number_symbols_for(:sv, :latn, @config)

    assert %Cldr.Number.Symbol{time_separator: ":", decimal: %{standard: ","}} = symbols
  end

  test "a number symbol that CLDR adds and Cldr.Number.Symbol does not know raises" do
    assert_raise KeyError, ~r/key :digit_marker not found/, fn ->
      Cldr.Config.number_symbol!(%{decimal: %{standard: "."}, digit_marker: "#"})
    end
  end

  test "the number symbols of every locale build a Cldr.Number.Symbol" do
    @config
    |> Cldr.Locale.Loader.known_locale_names()
    |> Task.async_stream(&Cldr.Config.number_symbols_for!(&1, @config), timeout: :infinity)
    |> Enum.each(fn {:ok, symbols} -> assert is_list(symbols) end)
  end
end
