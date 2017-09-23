defmodule GenerateLanguageTag do
  require ExUnitProperties

  @numeric ?0..?9
  @alpha [?a..?z, ?A..?Z]

  def valid_language_tag do
    ExUnitProperties.gen all  \
      language <- StreamData.string(@alpha, min_length: 2, max_length: 3),
      script   <- StreamData.one_of([StreamData.string(@alpha, length: 4),
                                     StreamData.constant(nil)]),
      region   <- StreamData.one_of([StreamData.string(@alpha, length: 2),
                                     StreamData.string(@numeric, length: 3),
                                     StreamData.constant(nil)])
    do
      [language, script, region]
      |> Enum.reject(&is_nil/1)
      |> Enum.join("-")
    end
  end

end