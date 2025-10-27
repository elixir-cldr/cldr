defmodule Cldr.Locale.Match.TestData do
  @path "test/support/data/locale_matching_test_data.txt"

  def parse do
    @path
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.with_index(1)
    |> Enum.map(&format_test(&1, Cldr.Locale.Match.default_threshold()))
    |> Enum.reject(&is_nil/1)
  end

  def test(n) do
    parse()
    |> Enum.find(&(&1.index == n))
  end

  defp format_test({"", _index}, _threshold), do: nil
  defp format_test({"#" <> _rest, _index}, _threshold), do: nil
  defp format_test({"@" <> _rest, _index}, _threshold), do: nil

  # supported ; desired ; expected
  defp format_test({test, index}, threshold) do
    [supported, desired, expected] =
      test
      |> String.split([";", "#"])
      |> Enum.take(3)
      |> Enum.map(&String.trim/1)

    supported = String.split(supported, ", ")

    {threshold, supported} =
      case Integer.parse(hd(supported)) do
        {threshold, ""} ->
          {threshold, tl(supported)}

        :error ->
          {threshold, supported}
      end

    desired = String.split(desired, ", ")

    [:index, :threshold, :supported, :desired, :expected]
    |> Enum.zip([index, threshold, supported, desired, expected])
    |> Map.new()
  end
end