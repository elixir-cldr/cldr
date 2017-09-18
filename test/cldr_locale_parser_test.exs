defmodule CldrLocaleParserTest do
  use ExUnit.Case, async: true
  alias Cldr.LanguageTag.Parser

  doctest Cldr.LanguageTag.Parser

  @language_codes [
    # "und-Cyrl-t-und-latn-m0-ungegn-2007",
    "en-US-x-twain",
    # "und-Hebr-t-und-latn-m0-ungegn-1972",
    "zh-Hant-TW",
    "en",
    "en-US",
    "en-us",
    "en_us",
    "es-419",
    "zh-Hans",
    "de_DE_u_co_phonebk",
    "de-DE-u-co-phonebk",
    "root_u_cu_usd",
    "und-u-cu-usd",
    "en_US_u_tz_uslax_va_posix",
    "th_TH_u_ca_gregory_nu_thai",
    "zh_Hant_TW_u_co_big5han"
  ]

  for code <- @language_codes do
    test "That #{inspect code} parses without error" do
      assert {:ok, _} = Parser.parse(unquote(code))
    end
  end
end
