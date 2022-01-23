defmodule Cldr.TestApp.Router do
  use Plug.Router, async: true

  plug(:match)
  plug(Cldr.Plug.SetLocale, from: :path, cldr: TestBackend.Cldr)
  plug(:dispatch)

  get "/thing/:locale" do
    send_resp(conn, 200, "")
  end

  get "/thing/:locale/other" do
    send_resp(conn, 200, "")
  end
end

defmodule Cldr.Plug.Router.Test do
  use ExUnit.Case
  use Plug.Test

  test "set the locale from the path params" do
    opts = Cldr.TestApp.Router.init([])

    conn =
      :get
      |> conn("/thing/fr")
      |> Cldr.TestApp.Router.call(opts)

    assert conn.path_params["locale"] == "fr"

    assert conn.private[:cldr_locale] == %Cldr.LanguageTag{
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

    assert Cldr.get_locale() == %Cldr.LanguageTag{
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
  end

  test "set the locale from the path params with scope parameter" do
    opts = Cldr.TestApp.Router.init([])

    conn =
      :get
      |> conn("/thing/fr/other")
      |> Cldr.TestApp.Router.call(opts)

    assert conn.path_params["locale"] == "fr"
  end
end
