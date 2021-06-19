defmodule GenerateLanguageTag do
  require ExUnitProperties

  @known_territories Cldr.Validity.all_valid(:territories)
  @known_scripts Cldr.Validity.all_valid(:scripts)
  @known_languages Cldr.Validity.all_valid(:languages)

  def valid_language_tag do
    ExUnitProperties.gen all(
                           language <-
                             StreamData.member_of(@known_languages),
                           script <-
                             StreamData.one_of([
                               StreamData.member_of(@known_scripts),
                               StreamData.constant(nil)
                             ]),
                           region <-
                             StreamData.one_of([
                               StreamData.member_of(@known_territories),
                               StreamData.constant(nil)
                             ])
                         ) do
      [language, script, region]
      |> Enum.reject(&is_nil/1)
      |> Enum.join("-")
    end
  end
end
