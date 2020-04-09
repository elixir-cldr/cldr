defmodule Cldr.Plug.AcceptLanguage.Test do
  use ExUnit.Case, async: true
  use Plug.Test

  import ExUnit.CaptureLog
  import Plug.Conn, only: [put_req_header: 3]

  test "that the locale is set if the accept-language header is a valid locale name" do
    opts = Cldr.Plug.AcceptLanguage.init(cldr_backend: TestBackend.Cldr)

    conn =
      :get
      |> conn("/")
      |> put_req_header("accept-language", "en")
      |> Cldr.Plug.AcceptLanguage.call(opts)

    assert conn.private[:cldr_locale] ==
             %Cldr.LanguageTag{
               backend: TestBackend.Cldr,
               canonical_locale_name: "en-Latn-US",
               cldr_locale_name: "en",
               extensions: %{},
               gettext_locale_name: "en",
               language: "en",
               locale: %{},
               private_use: [],
               rbnf_locale_name: "en",
               requested_locale_name: "en",
               script: "Latn",
               territory: :US,
               transform: %{},
               language_variant: nil
             }
  end

  test "that the gettext locale is a set when an ancestor is available" do
    opts = Cldr.Plug.AcceptLanguage.init(cldr_backend: TestBackend.Cldr)

    conn =
      :get
      |> conn("/")
      |> put_req_header("accept-language", "en-AU")
      |> Cldr.Plug.AcceptLanguage.call(opts)

    assert conn.private[:cldr_locale].gettext_locale_name == "en"
  end

  test "that the gettext locale is a set" do
    opts = Cldr.Plug.AcceptLanguage.init(cldr_backend: TestBackend.Cldr)

    conn =
      :get
      |> conn("/")
      |> put_req_header("accept-language", "en-GB")
      |> Cldr.Plug.AcceptLanguage.call(opts)

    assert conn.private[:cldr_locale].gettext_locale_name == "en_GB"
  end

  test "that the default locale is used if no backend is configured" do
    assert Cldr.Plug.AcceptLanguage.init([]) == Cldr.default_backend()
  end

  test "that the locale is not set if the accept-language header is an invalid locale name" do
    opts = Cldr.Plug.AcceptLanguage.init(cldr_backend: TestBackend.Cldr)

    capture_log(fn ->
      conn =
        :get
        |> conn("/")
        |> put_req_header("accept-language", "not_valid_locale_name")
        |> Cldr.Plug.AcceptLanguage.call(opts)

      assert conn.private[:cldr_locale] == nil
    end)
  end

  test "that the locale is not set if the accept-language header does not exists" do
    opts = Cldr.Plug.AcceptLanguage.init(cldr_backend: TestBackend.Cldr)

    capture_log(fn ->
      conn =
        :get
        |> conn("/")
        |> Cldr.Plug.AcceptLanguage.call(opts)

      assert conn.private[:cldr_locale] == nil
    end)
  end
end
