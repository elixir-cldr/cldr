defmodule Cldr.Plug.AcceptLanguage.Test do
  use ExUnit.Case
  use Plug.Test

  import ExUnit.CaptureLog
  import Plug.Conn, only: [put_req_header: 3]

  test "that the locale is set if the accept-language header is a valid locale name" do
    opts = Cldr.Plug.AcceptLanguage.init

    conn =
      :get
      |> conn("/")
      |> put_req_header("accept-language", "en")
      |> Cldr.Plug.AcceptLanguage.call(opts)

    assert conn.private[:cldr_locale] ==
        %Cldr.LanguageTag{
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
          territory: "US",
          transform: %{},
          variant: nil
        }
  end

  test "that the locale is not set if the accept-language header is an invalid locale name" do
    opts = Cldr.Plug.AcceptLanguage.init

    capture_log fn ->
      conn =
      :get
        |> conn("/")
        |> put_req_header("accept-language", "not_valid_locale_name")
        |> Cldr.Plug.AcceptLanguage.call(opts)

      assert conn.private[:cldr_locale] == nil
    end
  end

  test "that the locale is not set if the accept-language header does not exists" do
    opts = Cldr.Plug.AcceptLanguage.init

    capture_log fn ->
      conn =
      :get
        |> conn("/")
        |> Cldr.Plug.AcceptLanguage.call(opts)

      assert conn.private[:cldr_locale] == nil
    end
  end

end