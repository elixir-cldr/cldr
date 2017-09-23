defmodule CldrLanguageTagTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  property "check that we can parse language tags" do
    check all \
      language_tag <- GenerateLanguageTag.valid_language_tag,
      max_runs: 3_000
    do
      assert {:ok, _} = Cldr.AcceptLanguage.parse(language_tag)
    end
  end

end