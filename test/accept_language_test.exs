defmodule Cldr.AcceptLanguageTest do
  use ExUnit.Case, async: true

  doctest Cldr.AcceptLanguage

  test "Confirm that order is unchanged for tags with the same quality" do
    tags = [{1.0, "en-us"}, {1.0, "en"}, {1.0, "es-es"}, {1.0, "es"}]

    assert Cldr.AcceptLanguage.sort_by_quality(tags) == tags
  end

  test "Confirm that order is unchanged for tags with the same quality part deux" do
    before_tags = [{1.0, "en-us"}, {1.0, "en"}, {2.0, "fr"}, {1.0, "es-es"}, {1.0, "es"}]
    after_tags = [{2.0, "fr"}, {1.0, "en-us"}, {1.0, "en"}, {1.0, "es-es"}, {1.0, "es"}]
    assert Cldr.AcceptLanguage.sort_by_quality(before_tags) == after_tags
  end
end
