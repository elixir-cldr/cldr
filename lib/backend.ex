if Mix.env() in [:release, :test, :dev] do
  require Cldr.Backend
  Application.ensure_all_started(:gettext)

  defmodule MyApp.Gettext do
    use Gettext,
      otp_app: Cldr.Config.app_name(),
      priv: "priv/gettext_test"
  end

  defmodule MyApp.Cldr do
    use Cldr,
      gettext: MyApp.Gettext,
      locales: ["en", "de", "ja", "en-AU", "th", "ar", "pl", "doi"],
      generate_docs: true,
      providers: []
  end
end
