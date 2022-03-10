defmodule Cldr.Plug.SetLocale.Test do
  use ExUnit.Case, async: true
  use Plug.Test

  import ExUnit.CaptureIO

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
               backend: TestBackend.Cldr,
               canonical_locale_name: "en-001",
               cldr_locale_name: :"en-001",
               extensions: %{},
               gettext_locale_name: "en",
               language: "en",
               language_subtags: [],
               language_variants: [],
               locale: %{},
               private_use: [],
               rbnf_locale_name: :en,
               requested_locale_name: "en-001",
               script: :Latn,
               territory: :"001",
               transform: %{}
             },
             cldr: TestBackend.Cldr,
             param: "locale",
             from: [:session, :accept_language, :query, :path],
             apps: [cldr: :global]
           ]
  end

  test "init sets the gettext locale if not is defined, and its in :apps and cldr has one" do
    opts = Cldr.Plug.SetLocale.init(apps: [:cldr, :gettext], cldr: TestBackend.Cldr)

    assert opts == [
             session_key: "cldr_locale",
             default: %Cldr.LanguageTag{
               backend: TestBackend.Cldr,
               canonical_locale_name: "en-001",
               cldr_locale_name: :"en-001",
               extensions: %{},
               gettext_locale_name: "en",
               language: "en",
               language_subtags: [],
               language_variants: [],
               locale: %{},
               private_use: [],
               rbnf_locale_name: :en,
               requested_locale_name: "en-001",
               script: :Latn,
               territory: :"001",
               transform: %{}
             },
             gettext: TestGettext.Gettext,
             cldr: TestBackend.Cldr,
             param: "locale",
             from: [:session, :accept_language, :query, :path],
             apps: [cldr: :global, gettext: :global]
           ]
  end

  # On older versions of elixir, the capture_io call raises
  # an exception.
  test "session key deprecation is emitted" do
    try do
      assert capture_io(:stderr, fn ->
               Cldr.Plug.SetLocale.init(session_key: "key", cldr: WithNoGettextBackend.Cldr)
             end) =~
               "The :session_key option is deprecated and will be removed in a future release"
    rescue
      RuntimeError ->
        true
    end
  end

  test "init does not set the gettext locale if not defined, and its in :apps and cldr does not have one" do
    opts = Cldr.Plug.SetLocale.init(apps: [:cldr, :gettext], cldr: WithNoGettextBackend.Cldr)

    assert opts == [
             session_key: "cldr_locale",
             default: %Cldr.LanguageTag{
               backend: WithNoGettextBackend.Cldr,
               canonical_locale_name: "en-001",
               cldr_locale_name: :"en-001",
               extensions: %{},
               gettext_locale_name: nil,
               language: "en",
               language_subtags: [],
               language_variants: [],
               locale: %{},
               private_use: [],
               rbnf_locale_name: :en,
               requested_locale_name: "en-001",
               script: :Latn,
               territory: :"001",
               transform: %{}
             },
             cldr: WithNoGettextBackend.Cldr,
             param: "locale",
             from: [:session, :accept_language, :query, :path],
             apps: [cldr: :global, gettext: :global]
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
      Cldr.Plug.SetLocale.init(gettext: BlatherBalls, cldr: TestBackend.Cldr)
    end

    assert_raise Cldr.InvalidLanguageError, fn ->
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
               backend: TestBackend.Cldr,
               canonical_locale_name: "fr",
               cldr_locale_name: :fr,
               extensions: %{},
               gettext_locale_name: nil,
               language: "fr",
               locale: %{},
               private_use: [],
               rbnf_locale_name: :fr,
               requested_locale_name: "fr",
               script: :Latn,
               territory: :FR,
               transform: %{},
               language_variants: []
             }

    assert Cldr.get_locale() == conn.private[:cldr_locale]
  end

  test "set the locale from the host" do
    opts = Cldr.Plug.SetLocale.init(from: :host, cldr: TestBackend.Cldr)

    conn =
      :get
      |> conn("/")
      |> Map.put(:host, "www.site.fr")
      |> Cldr.Plug.SetLocale.call(opts)

    assert conn.private[:cldr_locale] ==
             %Cldr.LanguageTag{
               backend: TestBackend.Cldr,
               canonical_locale_name: "fr-FR",
               cldr_locale_name: :fr,
               extensions: %{},
               gettext_locale_name: nil,
               language: "fr",
               locale: %{},
               private_use: [],
               rbnf_locale_name: :fr,
               requested_locale_name: "fr-FR",
               script: :Latn,
               territory: :FR,
               transform: %{},
               language_variants: []
             }

    assert Cldr.get_locale() == conn.private[:cldr_locale]
  end

  test "set the locale from the session" do
    opts = Cldr.Plug.SetLocale.init(from: :session, cldr: TestBackend.Cldr)
    session_opts = Plug.Session.init(store: :cookie, key: "_key", signing_salt: "X")

    conn =
      :get
      |> conn("/")
      |> Plug.Session.call(session_opts)
      |> fetch_session("cldr_locale")
      |> put_session("cldr_locale", Cldr.Locale.new!("ru", opts[:cldr]))
      |> Cldr.Plug.SetLocale.call(opts)

    assert conn.private[:cldr_locale] ==
             %Cldr.LanguageTag{
               backend: TestBackend.Cldr,
               extensions: %{},
               gettext_locale_name: nil,
               locale: %{},
               private_use: [],
               transform: %{},
               language_variants: [],
               canonical_locale_name: "ru",
               cldr_locale_name: :ru,
               language: "ru",
               rbnf_locale_name: :ru,
               requested_locale_name: "ru",
               script: :Cyrl,
               territory: :RU
             }

    assert Cldr.get_locale() == conn.private[:cldr_locale]
  end

  test "set the locale from the session using a locale name" do
    opts = Cldr.Plug.SetLocale.init(from: :session, cldr: TestBackend.Cldr)
    session_opts = Plug.Session.init(store: :cookie, key: "_key", signing_salt: "X")

    conn =
      :get
      |> conn("/")
      |> Plug.Session.call(session_opts)
      |> fetch_session("cldr_locale")
      |> put_session("cldr_locale", "ru")
      |> Cldr.Plug.SetLocale.call(opts)

    assert conn.private[:cldr_locale] ==
             %Cldr.LanguageTag{
               backend: TestBackend.Cldr,
               extensions: %{},
               gettext_locale_name: nil,
               locale: %{},
               private_use: [],
               transform: %{},
               language_variants: [],
               canonical_locale_name: "ru",
               cldr_locale_name: :ru,
               language: "ru",
               rbnf_locale_name: :ru,
               requested_locale_name: "ru",
               script: :Cyrl,
               territory: :RU
             }

    assert Cldr.get_locale() == conn.private[:cldr_locale]
  end

  test "set the locale from a body param" do
    opts = Cldr.Plug.SetLocale.init(from: :body, cldr: TestBackend.Cldr)
    parser_opts = Plug.Parsers.init(parsers: [:json], json_decoder: Jason)
    json = %{locale: "zh-Hant"}

    conn =
      :put
      |> conn("/?locale=fr", json)
      |> Plug.Parsers.call(parser_opts)
      |> Cldr.Plug.SetLocale.call(opts)

    assert conn.private[:cldr_locale] ==
             %Cldr.LanguageTag{
               backend: TestBackend.Cldr,
               extensions: %{},
               gettext_locale_name: nil,
               locale: %{},
               private_use: [],
               transform: %{},
               language_variants: [],
               canonical_locale_name: "zh-Hant",
               cldr_locale_name: :"zh-Hant",
               language: "zh",
               rbnf_locale_name: :"zh-Hant",
               requested_locale_name: "zh-Hant",
               script: :Hant,
               territory: :TW
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
               backend: TestBackend.Cldr,
               extensions: %{},
               gettext_locale_name: nil,
               locale: %{},
               private_use: [],
               transform: %{},
               language_variants: [],
               canonical_locale_name: "zh-Hant",
               cldr_locale_name: :"zh-Hant",
               language: "zh",
               rbnf_locale_name: :"zh-Hant",
               requested_locale_name: "zh-Hant",
               script: :Hant,
               territory: :TW
             }

    assert Cldr.get_locale() == conn.private[:cldr_locale]
  end

  test "that a gettext locale is set as an ancestor if it exists" do
    opts =
      Cldr.Plug.SetLocale.init(
        apps: [cldr: MyApp.Cldr, gettext: MyApp.Gettext],
        from: [:accept_language],
        param: "locale",
        default: "en-GB"
      )

    conn =
      :get
      |> conn("/")
      |> put_req_header("accept-language", "en-AU")
      |> Cldr.Plug.SetLocale.call(opts)

    assert conn.private[:cldr_locale].gettext_locale_name == "en"
  end

  test "that a gettext locale is set on the global gettext context" do
    opts =
      Cldr.Plug.SetLocale.init(
        apps: [cldr: MyApp.Cldr, gettext: :all],
        from: [:accept_language],
        param: "locale",
        default: "en-GB"
      )

    conn =
      :get
      |> conn("/")
      |> put_req_header("accept-language", "es")
      |> Cldr.Plug.SetLocale.call(opts)

    assert conn.private[:cldr_locale].gettext_locale_name == "es"
    assert Gettext.get_locale() == "es"
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
               backend: TestBackend.Cldr,
               canonical_locale_name: "pl",
               cldr_locale_name: :pl,
               extensions: %{},
               gettext_locale_name: nil,
               language: "pl",
               locale: %{},
               private_use: [],
               rbnf_locale_name: :pl,
               requested_locale_name: "pl",
               script: :Latn,
               territory: :PL,
               transform: %{},
               language_variants: []
             }

    assert Cldr.get_locale() == conn.private[:cldr_locale]
  end

  test "gettext locale is set" do
    opts =
      Cldr.Plug.SetLocale.init(
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
               backend: TestBackend.Cldr,
               extensions: %{},
               gettext_locale_name: "es",
               language_subtags: [],
               language_variants: [],
               locale: %{},
               private_use: [],
               script: :Latn,
               transform: %{},
               canonical_locale_name: "es",
               cldr_locale_name: :es,
               language: "es",
               rbnf_locale_name: :es,
               requested_locale_name: "es",
               territory: :ES
             }

    assert Gettext.get_locale(TestGettext.Gettext) == "es"
  end

  test "another gettext example" do
    opts =
      Cldr.Plug.SetLocale.init(
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

  test "config with no gettext" do
    opts =
      Cldr.Plug.SetLocale.init(
        apps: [:cldr, :gettext],
        from: [:query, :path, :cookie, :accept_language],
        cldr: TestBackend.Cldr,
        param: "locale"
      )

    :get
    |> conn("/?locale=es")
    |> Cldr.Plug.SetLocale.call(opts)

    assert Gettext.get_locale(TestGettext.Gettext) == "es"
  end

  test "locale detection from path params with parser plug" do
    conn = conn(:get, "/hello/es", %{this: "thing"})
    conn = MyRouter.call(conn, MyRouter.init([]))

    assert conn.private[:cldr_locale] ==
             %Cldr.LanguageTag{
               backend: TestBackend.Cldr,
               extensions: %{},
               gettext_locale_name: "es",
               language_subtags: [],
               language_variants: [],
               locale: %{},
               private_use: [],
               script: :Latn,
               transform: %{},
               canonical_locale_name: "es",
               cldr_locale_name: :es,
               language: "es",
               rbnf_locale_name: :es,
               requested_locale_name: "es",
               territory: :ES
             }

    assert Gettext.get_locale(TestGettext.Gettext) == "es"
  end
end
