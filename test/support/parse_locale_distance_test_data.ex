defmodule Cldr.Locale.Distance.TestData do
  @path "test/support/data/locale_distance_test_data.txt"

  def parse do
    @path
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.with_index(1)
    |> Enum.map(&format_test/1)
    |> Enum.reject(&is_nil/1)
  end

  def test(n) do
    parse()
    |> Enum.find(&(&1.index == n))
  end

  defp format_test({"", _index}), do: nil
  defp format_test({"#" <> _rest, _index}), do: nil
  defp format_test({"@" <> _rest, _index}), do: nil

  # supported ; desired ; dist(s,d) ; dist(d,x)
  defp format_test({test, index}) do
    test_data =
      test
      |> String.split([";", "#"])
      |> Enum.take(3)
      |> Enum.map(&String.trim/1)

    [:index, :supported, :desired, :distance]
    |> Enum.zip([index | test_data])
    |> Map.new()
  end
end