if Mix.env in [:dev, :release] do
  require Cldr.Backend

  defmodule MyApp.Cldr do
    use Cldr, locales: ["en", "de"]
  end
end