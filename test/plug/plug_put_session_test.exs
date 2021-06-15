defmodule Cldr.Plug.SetSession.Test do
  use ExUnit.Case, async: true
  use Plug.Test

  import Plug.Conn, only: [get_session: 2]

  test "that the session is set" do
    conn = conn(:get, "/hello/es", %{this: "thing"})
    conn = MyRouter.call(conn, MyRouter.init([]))

    assert get_session(conn, Cldr.Plug.SetLocale.session_key()) == "es"
  end
end
