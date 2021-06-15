require TestBackend.Cldr

defmodule MyRouter do
  use Plug.Router

  plug(:put_secret_key_base)

  plug(Plug.Session, store: :cookie, key: "_key", signing_salt: "X")

  plug(:match)

  plug(Cldr.Plug.SetLocale,
    apps: [:cldr, :gettext],
    from: [:path, :query],
    gettext: TestGettext.Gettext,
    cldr: TestBackend.Cldr
  )

  plug(Cldr.Plug.PutSession)

  plug(:dispatch)

  get "/hello/:locale" do
    send_resp(conn, 200, "world")
  end

  def put_secret_key_base(conn, _) do
    put_in(conn.secret_key_base, String.duplicate("X", 64))
  end
end
