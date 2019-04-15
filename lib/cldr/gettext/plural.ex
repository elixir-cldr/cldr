defmodule Cldr.Gettext.Plural do
  @moduledoc false

  def define_gettext_plurals_module(config) do
    quote location: :keep do
      defmodule Gettext.Plural do
        @moduledoc false
        if Cldr.Config.include_module_docs?(unquote(config.generate_docs)) do
          @moduledoc """
          Defines a Plural module for Gettext that uses the `Cldr` plural rules.

          """
        end

        @behaviour :"Elixir.Gettext.Plural"

        alias Cldr.LanguageTag
        alias Cldr.Locale
        alias unquote(config.backend).Number.Cardinal

        @doc """
        Returns how many plural forms exist for a given locale.

        * `locale` is either a locale name in the list `#{unquote(inspect(config.backend))}.known_locale_names/0` or
          a `%LanguageTag{}` as returned by `Cldr.Locale.new/2`

        ## Examples

            iex> #{inspect(__MODULE__)}.nplurals("pl")
            4

            iex> #{inspect(__MODULE__)}.nplurals("en")
            2

        """
        @spec nplurals(Locale.locale_name() | LanguageTag.t()) :: pos_integer() | no_return()

        def nplurals(%LanguageTag{cldr_locale_name: cldr_locale_name}) do
          Cardinal.gettext_nplurals()
          |> Map.get(cldr_locale_name)
          |> Enum.count()
        end

        def nplurals(locale_name) when is_binary(locale_name) do
          with {:ok, locale} <- unquote(config.backend).validate_locale(locale_name) do
            nplurals(locale)
          else
            {:error, _reason} -> raise :"Elixir.Gettext.Plural.UnknownLocaleError", locale_name
          end
        end

        @doc """
        Returns to what plural form a given number belongs to in a given
        locale.

        * `locale` is either a locale name in the list `#{unquote(inspect(config.backend))}.known_locale_names/0` or
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
        @spec plural(Locale.locale_name() | LanguageTag.t(), number()) ::
                pos_integer() | no_return()

        def plural(%LanguageTag{cldr_locale_name: cldr_locale_name} = locale, n) do
          rule = Cardinal.plural_rule(n, cldr_locale_name)

          Cardinal.gettext_nplurals()
          |> Map.get(cldr_locale_name)
          |> Keyword.get(rule)
        end

        def plural(locale_name, n) when is_binary(locale_name) do
          with {:ok, locale} <- unquote(config.backend).validate_locale(locale_name) do
            plural(locale, n)
          else
            {:error, _reason} -> raise :"Elixir.Gettext.Plural.UnknownLocaleError", locale_name
          end
        end
      end
    end
  end
end
