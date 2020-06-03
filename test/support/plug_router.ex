defmodule MyRouter do
  use Plug.Router

  plug :match

  plug Cldr.Plug.SetLocale,
    apps: [:cldr, :gettext],
    from: [:path, :query],
    gettext: TestGettext.Gettext,
    cldr: TestBackend.Cldr

  plug :dispatch

  get "/hello/:locale" do
    send_resp(conn, 200, "world")
  end
end