defmodule CldrLocaleParserTest do
  use ExUnit.Case
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
    test "That #{inspect(code)} parses without error" do
      assert {:ok, _} = Parser.parse(unquote(code))
    end
  end

  test "That invalid locale string returns error" do
    assert {:error, _error} = Parser.parse("-invalid")
  end

  test "That invalid language code is handled" do
    assert {:ok, language_tag} = Parser.parse("aaaaa")
    assert is_nil(language_tag.cldr_locale_name)
    assert language_tag.language == "aaaaa"
  end

  test "That nonexistent language code is handled" do
    assert {:ok, language_tag} = Parser.parse("zz")
    assert is_nil(language_tag.cldr_locale_name)
    assert language_tag.language == "zz"
  end

  test "That invalid territory code is handled" do
    assert {:ok, language_tag} = Parser.parse("en-AAAA")
    assert language_tag.language == "en"
    assert is_nil(language_tag.territory)
  end

  test "That nonexistent territory code is handled" do
    assert {:ok, language_tag} = Parser.parse("en-AA")
    assert language_tag.language == "en"
    assert language_tag.territory == "AA"
  end

  test "That invalid currency code is handled" do
    assert {:ok, language_tag} = Parser.parse("en-US-u-cu-AAAAAA")
    assert language_tag.language == "en"
    assert language_tag.territory == "US"
    assert is_nil(language_tag.locale.currency)
  end

  test "That nonexistent currency code is handled" do
    assert {:ok, language_tag} = Parser.parse("en-US-u-cu-AAA")
    assert language_tag.language == "en"
    assert language_tag.territory == "US"
    assert is_nil(language_tag.locale.currency)
  end
end
