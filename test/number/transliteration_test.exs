defmodule Transliteration.Test do
  use ExUnit.Case
  import ExUnit.CaptureLog

  test "that a dynamic transliteration generates a log message" do
    assert capture_log(fn ->
      Cldr.Number.Transliterate.transliterate_digits "٠١٢٣٤٥٦٧٨٩", :arab, :java
    end) =~ "Transliteration from number system :arab to :java"
  end
end