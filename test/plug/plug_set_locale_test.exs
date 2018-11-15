defmodule Cldr.Plug.SetLocale.Test do
  use ExUnit.Case
  use Plug.Test

  import Plug.Conn,
    only: [
      put_req_header: 3,
      put_session: 3,
      fetch_session: 2,
      put_resp_cookie: 3,
      fetch_cookies: 1
    ]

  test "init returns the default options" do
    opts = Cldr.Plug.SetLocale.init(cldr: TestBackend.Cldr)

    assert opts == [
             session_key: "cldr_locale",
             default: %Cldr.LanguageTag{
               canonical_locale_name: "en-Latn-001",
               cldr_locale_name: "en-001",
               language_subtags: [],
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
               language_variant: nil
             },
             cldr: TestBackend.Cldr,
             param: "locale",
             from: [:session, :accept_language],
             apps: [cldr: :all]
           ]
  end

  test "bad parameters raise exceptions" do
    assert_raise ArgumentError, fn ->
      Cldr.Plug.SetLocale.init(from: :nothing, cldr: TestBackend.Cldr)
    end

    assert_raise ArgumentError, fn ->
      Cldr.Plug.SetLocale.init(from: :nothing, cldr: TestBackend.Cldr)
    end

    assert_raise ArgumentError, fn ->
      Cldr.Plug.SetLocale.init(from: [:nothing], cldr: TestBackend.Cldr)
    end

    assert_raise ArgumentError, fn ->
      Cldr.Plug.SetLocale.init(apps: :nothing, cldr: TestBackend.Cldr)
    end

    assert_raise ArgumentError, fn ->
      Cldr.Plug.SetLocale.init(apps: [:nothing], cldr: TestBackend.Cldr)
    end

    assert_raise ArgumentError, fn ->
      Cldr.Plug.SetLocale.init(param: [:nothing], cldr: TestBackend.Cldr)
    end

    assert_raise ArgumentError, fn ->
      Cldr.Plug.SetLocale.init(apps: :gettext, cldr: TestBackend.Cldr)
    end

    assert_raise ArgumentError, fn ->
      Cldr.Plug.SetLocale.init(gettext: BlatherBalls, cldr: TestBackend.Cldr)
    end

    assert_raise Cldr.UnknownLocaleError, fn ->
      Cldr.Plug.SetLocale.init(default: :nothing, cldr: TestBackend.Cldr)
    end
  end

  test "set the locale from a query param" do
    opts = Cldr.Plug.SetLocale.init(from: :query, cldr: TestBackend.Cldr)

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
               language_variant: nil
             }

    assert Cldr.get_locale() == conn.private[:cldr_locale]
  end

  test "set the locale from the session" do
    opts = Cldr.Plug.SetLocale.init(from: :session, cldr: TestBackend.Cldr)
    session_opts = Plug.Session.init(store: :cookie, key: "_key", signing_salt: "X")

    conn =
      :get
      |> conn("/?locale=fr")
      |> Plug.Session.call(session_opts)
      |> fetch_session("cldr_locale")
      |> put_session("cldr_locale", Cldr.Locale.new("ru", opts[:cldr]))
      |> Cldr.Plug.SetLocale.call(opts)

    assert conn.private[:cldr_locale] ==
             %Cldr.LanguageTag{
               extensions: %{},
               gettext_locale_name: nil,
               locale: %{},
               private_use: [],
               transform: %{},
               language_variant: nil,
               canonical_locale_name: "ru-Cyrl-RU",
               cldr_locale_name: "ru",
               language: "ru",
               rbnf_locale_name: "ru",
               requested_locale_name: "ru",
               script: "Cyrl",
               territory: "RU"
             }

    assert Cldr.get_locale() == conn.private[:cldr_locale]
  end

  test "set the locale from a body param" do
    opts = Cldr.Plug.SetLocale.init(from: :body, cldr: TestBackend.Cldr)
    parser_opts = Plug.Parsers.init(parsers: [:json], json_decoder: Jason)
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
               language_variant: nil,
               canonical_locale_name: "zh-Hant-TW",
               cldr_locale_name: "zh-Hant",
               language: "zh",
               rbnf_locale_name: "zh-Hant",
               requested_locale_name: "zh-Hant",
               script: "Hant",
               territory: "TW"
             }

    assert Cldr.get_locale() == conn.private[:cldr_locale]
  end

  test "set the locale from a cookie param" do
    opts = Cldr.Plug.SetLocale.init(from: :cookie, cldr: TestBackend.Cldr)

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
               language_variant: nil,
               canonical_locale_name: "zh-Hant-TW",
               cldr_locale_name: "zh-Hant",
               language: "zh",
               rbnf_locale_name: "zh-Hant",
               requested_locale_name: "zh-Hant",
               script: "Hant",
               territory: "TW"
             }

    assert Cldr.get_locale() == conn.private[:cldr_locale]
  end

  test "locale is set according to the configured priority" do
    opts = Cldr.Plug.SetLocale.init(from: [:accept_language, :query], cldr: TestBackend.Cldr)

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
               language_variant: nil
             }

    assert Cldr.get_locale() == conn.private[:cldr_locale]
  end

  test "gettext locale is set" do
    opts = Cldr.Plug.SetLocale.init(
      from: [:query],
      cldr: TestBackend.Cldr,
      gettext: TestGettext.Gettext,
      apps: :gettext
    )

    conn =
      :get
      |> conn("/?locale=es")
      |> Cldr.Plug.SetLocale.call(opts)

    assert conn.private[:cldr_locale] ==
      %Cldr.LanguageTag{
        extensions: %{},
        gettext_locale_name: "es",
        language_subtags: [],
        language_variant: nil,
        locale: %{},
        private_use: [],
        script: "Latn",
        transform: %{},
        canonical_locale_name: "es-Latn-ES",
        cldr_locale_name: "es",
        language: "es",
        rbnf_locale_name: "es",
        requested_locale_name: "es",
        territory: "ES"
      }

    assert Gettext.get_locale(TestGettext.Gettext) == "es"
  end

  test "another gettext example" do
    opts = Cldr.Plug.SetLocale.init(
      apps: [:cldr, :gettext],
      from: [:query, :path, :cookie, :accept_language],
      cldr: TestBackend.Cldr,
      param: "locale",
      gettext: TestGettext.Gettext
    )

    :get
    |> conn("/?locale=es")
    |> Cldr.Plug.SetLocale.call(opts)

    assert Gettext.get_locale(TestGettext.Gettext) == "es"
  end
end
