defmodule Cldr.Mixfile do
  use Mix.Project

  @version "0.0.1-dev"
  
  def project do
    [app: :cldr,
     version: @version,
     elixir: "~> 1.2",
     name: "Cldr",
     source_url: "https://github.com/kipcole9/cldr",
     docs: [source_ref: "v#{@version}", main: "readme", extras: ["README.md"]],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(), 
     description: description(),
     package: package()]
  end

  defp description do
    """
    Common Locale Data Repository (CLDR) functions for Elixir.
    """
  end

  def application do
    []
  end

  defp deps do
    [{:poison, "~> 2.1"},
     {:decimal, github: "ericmj/decimal" },
     {:junit_formatter, "~> 0.0.2", only: :test}]
  end
  
  defp package do
    [maintainers: ["Kip Cole"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/kipcole9/cldr"}]
  end
end
