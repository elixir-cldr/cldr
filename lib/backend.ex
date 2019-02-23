if Mix.env in [:dev, :release, :test] do
  require Cldr.Backend

  defmodule MyApp.Cldr do
    use Cldr, locales: ["en", "de", "ja", "en-AU"]
  end
end