defmodule Cldr.Mixfile do
  use Mix.Project

  @version "2.43.1"

  def project do
    [
      app: :ex_cldr,
      version: @version,
      elixir: "~> 1.12",
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
        plt_add_apps: ~w(gettext inets jason mix sweet_xml nimble_parsec)a,
        flags: [
          :error_handling,
          :unknown,
          :underspecs,
          :extra_return,
          :missing_return
        ]
      ],
      compilers: [:yecc, :leex] ++ Mix.compilers()
    ]
    |> Keyword.merge(maybe_add_preferred_cli())
  end

  defp maybe_add_preferred_cli() do
    if Version.compare(System.version(), "1.19.0-dev") == :lt do
      [preferred_cli_env: cli()]
    else
      []
    end
  end

  defp description do
    """
    Common Locale Data Repository (CLDR) functions for Elixir to localize and format numbers,
    dates, lists, messages, languages, territories and units with support for over 700 locales
    for internationalized (i18n) and localized (L10N) applications.
    """
  end

  def application do
    [
      extra_applications: [:logger, :inets, :ssl]
    ]
  end

  defp deps do
    [
      {:cldr_utils, "~> 2.28"},
      {:decimal, "~> 1.6 or ~> 2.0"},
      {:jason, "~> 1.0", optional: true},
      {:ex_doc, "~> 0.18", only: [:release, :dev]},
      {:nimble_parsec, "~> 0.5 or ~> 1.0", optional: true},
      {:gettext, "~> 0.19", optional: true},
      {:stream_data, "~> 1.0", only: :test},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false, optional: true},
      {:sweet_xml, "~> 0.6", only: [:dev, :test, :generate], optional: true}
      # {:benchee, "~> 1.0", only: :dev, runtime: false, optional: true}
    ]
  end

  defp package do
    [
      maintainers: ["Kip Cole"],
      licenses: ["Apache-2.0"],
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
        "priv/cldr/locales/und.json",
        "priv/cldr/available_locales.json",
        "priv/cldr/number_systems.json",
        "priv/cldr/plural_rules.json",
        "priv/cldr/version.json",
        "priv/cldr/currencies.json",
        "priv/cldr/territory_currencies.json",
        "priv/cldr/weeks.json",
        "priv/cldr/calendars.json",
        "priv/cldr/calendar_preferences.json",
        "priv/cldr/day_periods.json",
        "priv/cldr/likely_subtags.json",
        "priv/cldr/aliases.json",
        "priv/cldr/territory_containers.json",
        "priv/cldr/territory_containment.json",
        "priv/cldr/territories.json",
        "priv/cldr/territory_subdivisions.json",
        "priv/cldr/territory_subdivision_containment.json",
        "priv/cldr/plural_ranges.json",
        "priv/cldr/timezones.json",
        "priv/cldr/metazones.json",
        "priv/cldr/metazone_mapping.json",
        "priv/cldr/metazone_ids.json",
        "priv/cldr/primary_zones.json",
        "priv/cldr/units.json",
        "priv/cldr/grammatical_features.json",
        "priv/cldr/grammatical_gender.json",
        "priv/cldr/parent_locales.json",
        "priv/cldr/time_preferences.json",
        "priv/cldr/script_metadata.csv",
        "priv/cldr/language_tags.ebin",
        "priv/cldr/language_data.json",
        "priv/cldr/deprecated/measurement_system.json",
        "priv/cldr/deprecated/unit_preference.json",
        "priv/cldr/validity/territories.json",
        "priv/cldr/validity/languages.json",
        "priv/cldr/validity/scripts.json",
        "priv/cldr/validity/subdivisions.json",
        "priv/cldr/validity/variants.json",
        "priv/cldr/validity/units.json",
        "priv/cldr/bcp47/u.json",
        "priv/cldr/bcp47/t.json"
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
      formatters: ["html"],
      deps: [
        ex_cldr_numbers: "https://hexdocs.pm/ex_cldr_numbers",
        ex_cldr_dates_times: "https://hexdocs.pm/ex_cldr_dates_times",
        ex_cldr_units: "https://hexdocs.pm/ex_cldr_units",
        ex_cldr_lists: "https://hexdocs.pm/ex_cldr_lists",
        ex_cldr_calendars: "https://hexdocs.pm/ex_cldr_calendars",
        ex_cldr_html: "https://hexdocs.pm/ex_cldr_html",
        ex_cldr_messages: "https://hexdocs.pm/ex_cldr_messages",
        ex_cldr_routes: "https://hexdocs.pm/ex_cldr_routes",
        ex_cldr_person_names: "https://hexdocs.pm/ex_cldr_person_names"
      ],
      groups_for_modules: groups_for_modules(),
      skip_undefined_reference_warnings_on: ["changelog", "CHANGELOG.md"]
    ]
  end

  @doc false
  def cli() do
    [
      "cldr.generate_language_tags": :generate,
      "cldr.download.iso_currency": :generate,
      "cldr.consolidate": :generate
    ]
  end

  def aliases do
    []
  end

  defp groups_for_modules do
    [
      "Language Tag": ~r/^Cldr.LanguageTag.?/,
      "Plural Rules": ~r/^Cldr.Number.?/,
      Protocols: [
        Cldr.Chars,
        Cldr.DisplayName
      ],
      Plugs: ~r/^Cldr.Plug.?/,
      Gettext: ~r/^Cldr.Gettext.?/,
      Helpers: [
        Cldr.Calendar.Conversion,
        Cldr.Digits,
        Cldr.Helpers,
        Cldr.Locale.Cache,
        Cldr.Locale.Loader,
        Cldr.Macros,
        Cldr.Map,
        Cldr.Math,
        Cldr.String,
        Cldr.Config,
        Cldr.Install,
        Cldr.Substitution,
        Cldr.IsoCurrency,
        Cldr.Timezone
      ],
      "Example Backend": ~r/^MyApp.?/
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "src", "dev", "mix/support/units", "mix/tasks", "test"]
  defp elixirc_paths(:generate), do: ["lib", "src", "mix"]
  defp elixirc_paths(:dev), do: ["lib", "mix", "src", "dev", "bench"]
  defp elixirc_paths(:release), do: ["lib", "src"]
  defp elixirc_paths(_), do: ["lib", "src"]
end
