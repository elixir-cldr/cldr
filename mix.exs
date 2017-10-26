defmodule Cldr.Mixfile do
  use Mix.Project

  @version "0.11.0"

  def project do
    [
      app: :ex_cldr,
      version: @version,
      elixir: "~> 1.5",
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
      elixirc_paths: elixirc_paths(Mix.env),
      dialyzer: [ignore_warnings: ".dialyzer_ignore_warnings"]
    ]
  end

  defp description do
    """
    Common Locale Data Repository (CLDR) functions for Elixir to localize and format numbers,
    dates, lists and units with support for over 500 locales for internationalized (i18n) and
    localized (L10N) applications.
    """
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:poison, "~> 2.1 or ~> 3.0"},
      {:decimal, "~> 1.4.1"},
      {:ex_doc, "~> 0.18.1", only: [:dev, :docs]},
      {:abnf, path: "../abnf"},
      {:gettext, "~> 0.13.0", optional: true},
      {:gen_stage, "~> 0.12.2", optional: true, only: [:dev, :test]},
      {:flow, "~> 0.11", optional: true, only: [:dev, :test]},
      {:stream_data, "~> 0.3.0", only: :test},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Kip Cole"],
      licenses: ["Apache 2.0"],
      links: links(),
      files: [
        "lib", "src", "guides", "config",
        "mix.exs", "README*", "CHANGELOG*", "LICENSE*",
        "priv/cldr/locales/en.json",
        "priv/cldr/locales/root.json",
        "priv/cldr/available_locales.json",
        "priv/cldr/number_systems.json",
        "priv/cldr/plural_rules.json",
        "priv/cldr/version.json",
        "priv/cldr/currencies.json",
        "priv/cldr/week_data.json",
        "priv/cldr/calendar_data.json",
        "priv/cldr/day_periods.json",
        "priv/cldr/likely_subtags.json",
        "priv/cldr/aliases.json",
        "priv/cldr/territory_containment.json",
        "priv/cldr/territory_info.json",
        "priv/cldr/rfc5646.abnf"
      ]
    ]
  end

  def links do
    %{
      "GitHub"    => "https://github.com/kipcole9/cldr",
      "Readme"    => "https://github.com/kipcole9/cldr/blob/v#{@version}/README.md",
      "Changelog" => "https://github.com/kipcole9/cldr/blob/v#{@version}/CHANGELOG.md"
    }
  end

  def docs do
    [
      source_ref: "v#{@version}",
      main: "1_getting_started",
      extra_section: "GUIDES",
      extras: extra_docs(),
      groups_for_modules: groups_for_modules()
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

  defp groups_for_modules do
    [
      "Config": [
        Cldr.Config,
        Cldr.Rbnf.Config
      ],
      "Language Tag": ~r/^Cldr.LanguageTag.?/,
      "Plural Rules": ~r/^Cldr.Number.?/,
      "Normalization": ~r/^Cldr.Normalize.?/,
      "Gettext": ~r/^Cldr.Gettext.?/,
      "Helpers": [
        Cldr.Calendar.Conversion,
        Cldr.Digits,
        Cldr.Helpers,
        Cldr.Locale.Cache,
        Cldr.Macros,
        Cldr.Map,
        Cldr.Math,
        Cldr.String
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "mix", "test"]
  defp elixirc_paths(:dev),  do: ["lib", "mix"]
  defp elixirc_paths(_),     do: ["lib"]
end
