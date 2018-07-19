defmodule Cldr.Mixfile do
  use Mix.Project

  @version "1.6.4"

  def project do
    [
      app: :ex_cldr,
      version: @version,
      elixir: "~> 1.5",
      name: "Cldr",
      source_url: "https://github.com/kipcole9/cldr",
      docs: docs(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env()),
      dialyzer: [ignore_warnings: ".dialyzer_ignore_warnings"],
      compilers: Mix.compilers()
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
      {:poison, "~> 2.1 or ~> 3.0", optional: true},
      {:jason, "~> 1.0", optional: true},
      {:decimal, "~> 1.4"},
      {:ex_doc, "~> 0.18 or ~> 0.19.0-rc", only: [:dev, :docs]},
      {:abnf2, "~> 0.1"},
      {:gettext, "~> 0.13", optional: true},
      {:stream_data, "~> 0.4.0", only: :test},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false},
      # {:dialyxir, git: "https://github.com/jeremyjh/dialyxir", runtime: false},
      {:phoenix, "~> 1.3", optional: true},
      {:plug, "~> 1.4", optional: true},
      {:sweet_xml, "~> 0.6", optional: true}
    ]
  end

  defp package do
    [
      maintainers: ["Kip Cole"],
      licenses: ["Apache 2.0"],
      links: links(),
      files: [
        "lib",
        "src/plural_rules_lexer.xrl",
        "src/plural_rules_parser.yrl",
        "config",
        "mix.exs",
        "README*",
        "CHANGELOG*",
        "LICENSE*",
        "priv/cldr/locales/en.json",
        "priv/cldr/locales/en-001.json",
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
        "priv/cldr/rfc5646.abnf",
        "priv/cldr/language_tags.ebin"
      ]
    ]
  end

  def links do
    %{
      "GitHub" => "https://github.com/kipcole9/cldr",
      "Readme" => "https://github.com/kipcole9/cldr/blob/v#{@version}/README.md",
      "Changelog" => "https://github.com/kipcole9/cldr/blob/v#{@version}/CHANGELOG.md"
    }
  end

  def docs do
    [
      source_ref: "v#{@version}",
      main: "readme",
      logo: "logo.png",
      extras: [
        "README.md",
        "ROADMAP.md",
        "LICENSE.md",
        "CHANGELOG.md"
      ],
      deps: [
        ex_cldr_numbers: "https://hexdocs.pm/ex_cldr_numbers",
        ex_cldr_dates_times: "https://hexdocs.pm/ex_cldr_dates_times",
        ex_cldr_units: "https://hexdocs.pm/ex_cldr_units",
        ex_cldr_lists: "https://hexdocs.pm/ex_cldr_lists"
      ],
      filter_prefix: "Cldr",
      groups_for_modules: groups_for_modules()
    ]
  end

  def aliases do
    []
  end

  defp groups_for_modules do
    [
      Config: [
        Cldr.Config,
        Cldr.Rbnf.Config
      ],
      "Language Tag": ~r/^Cldr.LanguageTag.?/,
      "Plural Rules": ~r/^Cldr.Number.?/,
      Plugs: ~r/^Cldr.Plug.?/,
      Gettext: ~r/^Cldr.Gettext.?/,
      Helpers: [
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
  defp elixirc_paths(:dev), do: ["lib", "mix"]
  defp elixirc_paths(_), do: ["lib"]
end
