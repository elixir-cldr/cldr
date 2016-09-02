defmodule Cldr.Plug.Test do
  # use MyApi.ConnCase
 #
 #  alias MyApi.{Repo, User, Session}
 #
 #  setup %{conn: conn} do
 #    user = create_user(%{name: "john"})
 #    session = create_session(user)
 #
 #    conn = conn
 #    |> put_req_header("accept", "application/json")
 #    |> put_req_header("authorization", "Bearer " <> session.token)
 #    {:ok, conn: conn}
 #  end
 #
 #  def create_user(%{name: name}) do
 #    User.changeset(%User{}, %{email: "#{name}@gmail.com"})
 #    |> Repo.insert!
 #  end
 #
 #  def create_session(user) do
 #    Session.create_changeset(%Session{user_id: user.id}, %{})
 #    |> Repo.insert!
 #  end
 #
 #  test "returns 401 error when user is not authenticated" do
 #    conn = get build_conn, "/api/secrets"
 #    assert json_response(conn, 401)["error"] != %{}
 #  end
 #
 #  test "renders secret resource when user is authenticated", %{conn: conn} do
 #    conn = get conn, secret_path(conn, :index)
 #    assert json_response(conn, 200)["message"] != %{}
 #  end
end