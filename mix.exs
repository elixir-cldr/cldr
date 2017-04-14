defmodule Cldr.Mixfile do
  use Mix.Project

  @version "0.1.3"

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
     test_coverage: [tool: ExCoveralls],
     aliases: aliases(),
     elixirc_paths: elixirc_paths(Mix.env)
   ]
  end

  defp description do
    """
    Common Locale Data Repository (CLDR) functions for Elixir to localize and format numbers,
    lists and units with support for over 500 locales for internationalized (i18n) and localized
    (L10N) applications.
    """
  end

  def application do
    [
      applications: [:poison, :decimal]
    ]
  end

  defp deps do
    [
      {:poison, "~> 2.1"},
      {:decimal, "~> 1.1"},
      {:benchfella, "~> 0.3.0", only: :dev},
      {:credo, "~> 0.4", only: [:dev, :test]},
      {:ex_doc, "~> 0.15", only: :dev},
      {:excoveralls, "~> 0.5.6", only: :test},
      {:gettext, "~> 0.11.0", only: :dev},
      {:gen_stage, "~> 0.9.0", optional: true, only: [:dev, :test]},
      {:exprof, "~> 0.2.0", optional: true, only: [:dev, :test]}
    ]
  end

  defp package do
    [
      maintainers: ["Kip Cole"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/kipcole9/cldr"},
      files: [
        "lib", "src", "guides", "config",
        "mix.exs", "README*", "CHANGELOG*", "LICENSE*",
        "priv/cldr/locales/en.json",
        "priv/cldr/locales/root.json",
        "priv/cldr/available_locales.json",
        "priv/cldr/number_systems.json",
        "priv/cldr/plural_rules.json",
        "priv/cldr/version.json",
        "priv/cldr/currencies.json"
      ]
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

  def aliases do
    [ ]
  end

  @doc_dir "./guides"
  defp extra_docs do
    @doc_dir
    |> File.ls!
    |> Enum.map(&Path.join(@doc_dir, &1))
    |> Enum.sort
  end

  defp elixirc_paths(:test), do: ["lib", "mix", "test"]
  defp elixirc_paths(:dev),  do: ["lib", "mix"]
  defp elixirc_paths(_),     do: ["lib"]
end
