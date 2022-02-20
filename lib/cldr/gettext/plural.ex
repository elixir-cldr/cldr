defmodule Cldr.Gettext.Plural do
  @moduledoc """
  Implements a macro to define a CLDR-based Gettext plural
  module

  [gettext](https://hexdocs.pm/gettext) allows for user-defined
  [plural forms](https://hexdocs.pm/gettext/Gettext.Plural.html#content) modules
  to be configured for a [gettext backend](https://hexdocs.pm/gettext/Gettext.Backend.html#content).

  To define a plural forms module that uses [CLDR plural rules](https://cldr.unicode.org/index/cldr-spec/plural-rules)
  create a new module and then `use Cldr.Gettext.Plural`. For example:

      defmodule MyApp.Gettext.Plural do
        use Cldr.Gettext.Plural, cldr_backend: MyApp.Cldr

      end

  This module can then be used in the configuration of a `gettext` backend.
  For example:

      defmodule MyApp.Gettext do
        use Gettext, plural_forms: MyApp.Gettext.Plural

      end

  """

  @doc """
  Configure a module to be a [gettext plural](https://hexdocs.pm/gettext/Gettext.Plural.html#content)
  module.

  A CLDR-based `gettext` plural module is defined by including `use Cldr.Gettext.Plural`
  as in this example:

      defmodule MyApp.Gettext.Plural do
        use Cldr.Gettext.Plural, cldr_backend: MyApp.Cldr

      end

  ## Arguments

  * `options` is a keyword list of options. The default is `[]`

  ## Options

  * `:cldr_backend` is any CLDR [backend](https://hexdocs.pm/ex_cldr/readme.html#backend-module-configuration)
    module. The default is `Cldr.default_backend!/0`.

  """
  defmacro __using__(opts \\ []) do
    backend = Keyword.get_lazy(opts, :cldr_backend, &Cldr.default_backend!/0)

    quote location: :keep do
      @behaviour Elixir.Gettext.Plural

      alias Cldr.LanguageTag
      alias Cldr.Locale

      @rules Cldr.Config.cldr_data_dir()
             |> Path.join("/plural_rules.json")
             |> File.read!()
             |> Cldr.Config.json_library().decode!
             |> Map.get("cardinal")
             |> Cldr.Config.normalize_plural_rules()
             |> Map.new()


      @nplurals_range [0, 1, 2, 3, 4, 5]
      @gettext_nplurals @rules
                        |> Enum.map(fn {locale, rules} ->
                          {locale, Keyword.keys(rules) |> Enum.zip(@nplurals_range)}
                        end)
                        |> Map.new()

      @doc """
      Returns the number of plural forms for a given locale.

      * `locale` is either a locale name in the list
        `#{unquote(inspect(backend))}.known_locale_names/0` or
        a `%LanguageTag{}` as returned by `Cldr.Locale.new/2`

      ## Examples

          iex> #{inspect(__MODULE__)}.nplurals("pl")
          4

          iex> #{inspect(__MODULE__)}.nplurals("en")
          2

      """
      @spec nplurals(Locale.locale_name() | String.t()) :: pos_integer() | no_return()

      def nplurals(%LanguageTag{cldr_locale_name: cldr_locale_name}) do
        nplurals(cldr_locale_name)
      end

      def nplurals(locale_name) when is_atom(locale_name) do
        gettext_nplurals()
        |> Map.fetch!(locale_name)
        |> Enum.count()
      end

      def nplurals(locale_name) when is_binary(locale_name) do
        locale_name = String.to_existing_atom(locale_name)
        nplurals(locale_name)
      rescue ArgumentError ->
        raise KeyError, "Key #{inspect locale_name} not found"
      end

      @doc """
      Returns the plural form of a number for a given
      locale.

      * `locale` is either a locale name in the list `#{unquote(inspect(backend))}.known_locale_names/0` or
        a `%LanguageTag{}` as returned by `Cldr.Locale.new/2`

      ## Examples

          iex> #{inspect(__MODULE__)}.plural("pl", 1)
          0

          iex> #{inspect(__MODULE__)}.plural("pl", 2)
          1

          iex> #{inspect(__MODULE__)}.plural("pl", 5)
          2

          iex> #{inspect(__MODULE__)}.plural("pl", 112)
          2

          iex> #{inspect(__MODULE__)}.plural("en", 1)
          0

          iex> #{inspect(__MODULE__)}.plural("en", 2)
          1

          iex> #{inspect(__MODULE__)}.plural("en", 112)
          1

      """
      @spec plural(String.t() | LanguageTag.t(), number()) ::
              0 | pos_integer() | no_return()

      def plural(%LanguageTag{cldr_locale_name: cldr_locale_name} = locale, n) do
        rule = unquote(backend).Number.Cardinal.plural_rule(n, cldr_locale_name)

        gettext_nplurals()
        |> Map.get(cldr_locale_name)
        |> Keyword.get(rule)
      end

      def plural(locale_name, n) do
        with {:ok, locale} <- unquote(backend).validate_locale(locale_name) do
          plural(locale, n)
        else
          {:error, _reason} -> raise Elixir.Gettext.Plural.UnknownLocaleError, locale_name
        end
      end

      defp gettext_nplurals do
        @gettext_nplurals
      end
    end
  end
end
