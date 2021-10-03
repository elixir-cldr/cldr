defmodule Cldr.Plug.SetSession.Test do
  use ExUnit.Case, async: true
  use Plug.Test

  import Plug.Conn, only: [get_session: 2]

  test "that the session is set" do
    conn = conn(:get, "/hello/es", %{this: "thing"})
    conn = MyRouter.call(conn, MyRouter.init([]))

    assert get_session(conn, Cldr.Plug.SetLocale.session_key()) == "es"
  end

  test "that the session is set for complex locale (not a cldr locale name)" do
    locale = "es-u-ca-coptic"

    conn = conn(:get, "/hello/#{locale}", %{this: "thing"})
    conn = MyRouter.call(conn, MyRouter.init([]))

    assert get_session(conn, Cldr.Plug.SetLocale.session_key()) == locale
  end
end
