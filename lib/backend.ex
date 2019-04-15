if Mix.env() in [:release, :test] do
  require Cldr.Backend

  defmodule MyApp.Gettext do
    use Gettext,
      otp_app: Cldr.Config.app_name(),
      priv: "priv/gettext_test"
  end

  defmodule MyApp.Cldr do
    use Cldr,
      gettext: MyApp.Gettext,
      locales: ["en", "de", "ja", "en-AU", "th", "ar"],
      generate_docs: false
  end
end
