defmodule Cldr.Mixfile do
  use Mix.Project

  @version "2.14.0-dev"

  def project do
    [
      app: :ex_cldr,
      version: @version,
      elixir: "~> 1.5",
      name: "Cldr",
      source_url: "https://github.com/elixir-cldr/cldr",
      docs: docs(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env()),
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore_warnings",
        plt_add_apps: ~w(gettext inets jason mix plug sweet_xml)a
      ],
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
      {:cldr_utils, "~> 2.7"},
      {:decimal, "~> 1.6"},
      {:jason, "~> 1.0", optional: true},
      {:ex_doc, "~> 0.18", only: [:release, :dev]},
      {:nimble_parsec, "~> 0.5", optional: true, only: [:release, :dev]},
      {:gettext, "~> 0.13", optional: true},
      {:stream_data, "~> 0.4", only: :test},
      {:dialyxir, "~> 1.0.0-rc", only: [:dev], runtime: false, optional: true},
      {:plug, "~> 1.4", optional: true},
      {:sweet_xml, "~> 0.6", only: [:dev, :test], optional: true},
      {:benchee, "~> 1.0", only: :dev, runtime: false, optional: true},
      {:telemetry, "~> 0.4.0", optional: true},
      {:ratio, "~> 2.0", only: [:dev, :test], optional: true}
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
        "priv/cldr/territory_currencies.json",
        "priv/cldr/week_data.json",
        "priv/cldr/calendar_data.json",
        "priv/cldr/day_periods.json",
        "priv/cldr/likely_subtags.json",
        "priv/cldr/aliases.json",
        "priv/cldr/territory_containment.json",
        "priv/cldr/territory_info.json",
        "priv/cldr/plural_ranges.json",
        "priv/cldr/timezones.json",
        "priv/cldr/measurement_system_preferences.json",
        "priv/cldr/measurement_systems.json",
        "priv/cldr/unit_preference.json",
        "priv/cldr/unit_conversion.json",
        "priv/cldr/language_tags.ebin"
      ]
    ]
  end

  def links do
    %{
      "GitHub" => "https://github.com/elixir-cldr/cldr",
      "Readme" => "https://github.com/elixir-cldr/cldr/blob/v#{@version}/README.md",
      "Changelog" => "https://github.com/elixir-cldr/cldr/blob/v#{@version}/CHANGELOG.md"
    }
  end

  def docs do
    [
      source_ref: "v#{@version}",
      main: "readme",
      logo: "logo.png",
      extras: [
        "README.md",
        "LICENSE.md",
        "CHANGELOG.md"
      ],
      deps: [
        ex_cldr_numbers: "https://hexdocs.pm/ex_cldr_numbers",
        ex_cldr_dates_times: "https://hexdocs.pm/ex_cldr_dates_times",
        ex_cldr_units: "https://hexdocs.pm/ex_cldr_units",
        ex_cldr_lists: "https://hexdocs.pm/ex_cldr_lists"
      ],
      groups_for_modules: groups_for_modules(),
      skip_undefined_reference_warnings_on: ["changelog"]
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
      ],
      "Example Backend": ~r/^MyApp.?/
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "mix", "src", "test"]
  defp elixirc_paths(:dev), do: ["lib", "mix", "src", "bench"]
  defp elixirc_paths(_), do: ["lib", "src"]
end
