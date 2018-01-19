defmodule Cldr.TestApp.Router do
  use Phoenix.Router

  pipeline :locale_pipeline do
    plug Cldr.Plug.SetLocale, from: :path
  end

  scope "/thing" do
    pipe_through :locale_pipeline
    get "/:locale", Cldr.PageController, :show
  end

  scope "/thing/:locale" do
    pipe_through :locale_pipeline
    get "/other", Cldr.PageController, :show
  end
end

defmodule Cldr.PageController do
  def init(_) do

  end

  def call(conn, _) do
    conn
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
              variant: nil
            }
    assert Cldr.get_current_locale == %Cldr.LanguageTag{
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
              variant: nil
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