defmodule Cldr.Mixfile do
  use Mix.Project

  @version "0.0.1"

  def project do
    [app: :ex_cldr,
     version: @version,
     elixir: "~> 1.3",
     name: "Cldr",
     source_url: "https://github.com/kipcole9/cldr",
     docs: docs(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     description: description(),
     package: package(),
     test_coverage: [tool: ExCoveralls]
   ]
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
    [
      {:poison, "~> 2.1"},
      {:decimal, "~> 1.1"},
      {:benchfella, "~> 0.3.0", only: :dev},
      {:credo, "~> 0.4", only: [:dev, :test]},
      {:ex_doc, "~> 0.12", only: :dev},
      {:excoveralls, "~> 0.5.6", only: :test},
      {:gettext, "~> 0.11.0", only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["Kip Cole"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/kipcole9/cldr"},
      files: ["lib", "data", "guides", "mix.exs", "README*"]
    ]
  end

  def docs do
    [
      source_ref: "v#{@version}",
      main: "1_getting_started",
      extra_section: "GUIDES",
      extras: extra_docs()
    ]
  end

  @doc_dir "./guides"
  defp extra_docs do
    @doc_dir
    |> File.ls!
    |> Enum.map(&Path.join(@doc_dir, &1))
    |> Enum.sort
  end
end
