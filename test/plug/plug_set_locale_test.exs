defmodule Cldr.Plug.SetLocale.Test do
  use ExUnit.Case
  use Plug.Test

  import Plug.Conn, only: [put_req_header: 3, put_session: 3, fetch_session: 2, put_resp_cookie: 3, fetch_cookies: 1]

  test "init returns the default options" do
    opts = Cldr.Plug.SetLocale.init()

    assert opts == [
             session_key: "cldr_locale",
             default: %Cldr.LanguageTag{
               canonical_locale_name: "en-Latn-001",
               cldr_locale_name: "en-001",
               extensions: %{},
               gettext_locale_name: nil,
               language: "en",
               locale: %{},
               private_use: [],
               rbnf_locale_name: "en",
               requested_locale_name: "en-001",
               script: "Latn",
               territory: "001",
               transform: %{},
               variant: nil
             },
             param: "locale",
             from: [:session, :accept_language],
             apps: [:cldr]
           ]
  end

  test "bad parameters raise exceptions" do
    assert_raise ArgumentError, fn -> Cldr.Plug.SetLocale.init(from: :nothing) end
    assert_raise ArgumentError, fn -> Cldr.Plug.SetLocale.init(from: [:nothing]) end
    assert_raise ArgumentError, fn -> Cldr.Plug.SetLocale.init(apps: :nothing) end
    assert_raise ArgumentError, fn -> Cldr.Plug.SetLocale.init(apps: [:nothing]) end
    assert_raise ArgumentError, fn -> Cldr.Plug.SetLocale.init(param: [:nothing]) end
    assert_raise ArgumentError, fn -> Cldr.Plug.SetLocale.init(apps: :gettext) end
    assert_raise ArgumentError, fn -> Cldr.Plug.SetLocale.init(gettext: BlatherBalls) end
    assert_raise Cldr.UnknownLocaleError, fn -> Cldr.Plug.SetLocale.init(default: :nothing) end
  end

  test "set the locale from a query param" do
    opts = Cldr.Plug.SetLocale.init(from: :query)

    conn =
      :get
      |> conn("/?locale=fr")
      |> Cldr.Plug.SetLocale.call(opts)

    assert conn.private[:cldr_locale] ==
             %Cldr.LanguageTag{
               canonical_locale_name: "fr-Latn-FR",
               cldr_locale_name: "fr",
               extensions: %{},
               gettext_locale_name: nil,
               language: "fr",
               locale: %{},
               private_use: [],
               rbnf_locale_name: "fr",
               requested_locale_name: "fr",
               script: "Latn",
               territory: "FR",
               transform: %{},
               variant: nil
             }

    assert Cldr.get_current_locale() == conn.private[:cldr_locale]
  end

  test "set the locale from the session" do
    opts = Cldr.Plug.SetLocale.init(from: :session)
    session_opts = Plug.Session.init(store: :cookie, key: "_key", signing_salt: "X")

    conn =
      :get
      |> conn("/?locale=fr")
      |> Plug.Session.call(session_opts)
      |> fetch_session("cldr_locale")
      |> put_session("cldr_locale", Cldr.Locale.new("ru"))
      |> Cldr.Plug.SetLocale.call(opts)

    assert conn.private[:cldr_locale] ==
             %Cldr.LanguageTag{
               extensions: %{},
               gettext_locale_name: nil,
               locale: %{},
               private_use: [],
               transform: %{},
               variant: nil,
               canonical_locale_name: "ru-Cyrl-RU",
               cldr_locale_name: "ru",
               language: "ru",
               rbnf_locale_name: "ru",
               requested_locale_name: "ru",
               script: "Cyrl",
               territory: "RU"
             }

    assert Cldr.get_current_locale() == conn.private[:cldr_locale]
  end

  test "set the locale from a body param" do
    opts = Cldr.Plug.SetLocale.init(from: :body)
    parser_opts = Plug.Parsers.init(parsers: [:json], json_decoder: Poison)
    json = %{locale: "zh-Hant"}

    conn =
      :get
      |> conn("/?locale=fr", json)
      |> Plug.Parsers.call(parser_opts)
      |> Cldr.Plug.SetLocale.call(opts)

    assert conn.private[:cldr_locale] ==
             %Cldr.LanguageTag{
               extensions: %{},
               gettext_locale_name: nil,
               locale: %{},
               private_use: [],
               transform: %{},
               variant: nil,
               canonical_locale_name: "zh-Hant-TW",
               cldr_locale_name: "zh-Hant",
               language: "zh",
               rbnf_locale_name: "zh-Hant",
               requested_locale_name: "zh-Hant",
               script: "Hant",
               territory: "TW"
             }

    assert Cldr.get_current_locale() == conn.private[:cldr_locale]
  end

  test "set the locale from a cookie param" do
    opts = Cldr.Plug.SetLocale.init(from: :cookie)

    conn =
      :get
      |> conn("/?locale=fr")
      |> fetch_cookies()
      |> put_resp_cookie("locale", "zh-Hant")
      |> Cldr.Plug.SetLocale.call(opts)

    assert conn.private[:cldr_locale] ==
             %Cldr.LanguageTag{
               extensions: %{},
               gettext_locale_name: nil,
               locale: %{},
               private_use: [],
               transform: %{},
               variant: nil,
               canonical_locale_name: "zh-Hant-TW",
               cldr_locale_name: "zh-Hant",
               language: "zh",
               rbnf_locale_name: "zh-Hant",
               requested_locale_name: "zh-Hant",
               script: "Hant",
               territory: "TW"
             }

    assert Cldr.get_current_locale() == conn.private[:cldr_locale]
  end

  test "locale is set according to the configured priority" do
    opts = Cldr.Plug.SetLocale.init(from: [:accept_language, :query])

    conn =
      :get
      |> conn("/?locale=fr")
      |> put_req_header("accept-language", "pl")
      |> Cldr.Plug.SetLocale.call(opts)

    assert conn.private[:cldr_locale] ==
             %Cldr.LanguageTag{
               canonical_locale_name: "pl-Latn-PL",
               cldr_locale_name: "pl",
               extensions: %{},
               gettext_locale_name: nil,
               language: "pl",
               locale: %{},
               private_use: [],
               rbnf_locale_name: "pl",
               requested_locale_name: "pl",
               script: "Latn",
               territory: "PL",
               transform: %{},
               variant: nil
             }

    assert Cldr.get_current_locale() == conn.private[:cldr_locale]
  end
end
