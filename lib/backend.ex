if Mix.env in [:dev, :release, :test] do
  require Cldr.Backend

  defmodule MyApp.Cldr do
    use Cldr,
      locales: ["en", "de", "ja", "en-AU", "th", "ar"],
      generate_backend_docs: false
  end
end