defmodule CldrAcceptLanguageTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  @numeric ?0..?9
  @alpha [?a..?z, ?A..?Z]

  property "check that we can parse accept-language headers" do
    check all  language <- StreamData.string(@alpha, min_length: 2, max_length: 3),
               script <- StreamData.one_of([StreamData.string(@alpha, length: 4), StreamData.constant(nil)]),
               region <- StreamData.one_of([StreamData.string(@alpha, length: 2), StreamData.string(@numeric, length: 3)]),
               max_runs: 3_000
    do
      language_tag = [language, script, region]
      |> Enum.reject(&is_nil/1)
      |> Enum.join("-")

      assert {:ok, _} = Cldr.AcceptLanguage.parse(language_tag)
    end
  end

end