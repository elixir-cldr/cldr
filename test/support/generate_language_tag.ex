defmodule GenerateLanguageTag do
  require ExUnitProperties

  @alpha [?a..?z, ?A..?Z]

  @known_territories Cldr.Config.known_territories |> Enum.map(&Atom.to_string/1)

  def valid_language_tag do
    ExUnitProperties.gen all  \
      language <- StreamData.string(@alpha, min_length: 2, max_length: 3),
      script   <- StreamData.one_of([StreamData.string(@alpha, length: 4),
                                     StreamData.constant(nil)]),
      region   <- StreamData.member_of(@known_territories)
    do
      [language, script, region]
      |> Enum.reject(&is_nil/1)
      |> Enum.join("-")
    end
  end

end