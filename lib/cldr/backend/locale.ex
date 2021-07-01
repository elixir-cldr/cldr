defmodule Cldr.Locale.Backend do
  @moduledoc false

  def define_locale_backend(config) do
    quote location: :keep, bind_quoted: [config: Macro.escape(config)] do
      defmodule Locale do
        @moduledoc false
        if Cldr.Config.include_module_docs?(config.generate_docs) do
          @moduledoc """
          Backend module that provides functions
          to define new locales and display human-readable
          locale names for presentation purposes.

          """
        end

        def new(locale_name), do: Cldr.Locale.new(locale_name, unquote(config.backend))
        def new!(locale_name), do: Cldr.Locale.new!(locale_name, unquote(config.backend))

        @doc """
        Returns the territory from a language tag or
        locale name.

        ## Arguments

        * `locale` is any language tag returned by
          `#{inspect(__MODULE__)}.new/1`
          or a locale name in the list returned by
          `#{inspect(config.backend)}.known_locale_names/0`

        ## Returns

        * A territory code as an atom

        ## Examples

            iex> #{inspect(__MODULE__)}.territory_from_locale "en-US"
            :US

            iex> #{inspect(__MODULE__)}.territory_from_locale "en-US-u-rg-GBzzzz"
            :GB

        """
        @spec territory_from_locale(Cldr.LanguageTag.t() | Cldr.Locale.locale_name()) ::
                Cldr.Locale.territory()

        @doc since: "2.18.2"

        def territory_from_locale(locale) when is_binary(locale) do
          Cldr.Locale.territory_from_locale(locale, unquote(config.backend))
        end

        def territory_from_locale(%LanguageTag{} = locale) do
          Cldr.Locale.territory_from_locale(locale)
        end

        @doc """
        Returns the time zone from a language tag or
        locale name.

        ## Arguments

        * `locale` is any language tag returned by
          `#{inspect(__MODULE__)}.new/1`
          or a locale name in the list returned by
          `#{inspect(config.backend)}.known_locale_names/0`

        ## Returns

        * A time zone ID as a string or

        * `:error` if no time zone can be determined

        ## Examples

            iex> #{inspect(__MODULE__)}.timezone_from_locale "en-US-u-tz-ausyd"
            "Australia/Sydney"

        """
        @doc since: "2.19.0"

        @spec timezone_from_locale(Cldr.LanguageTag.t() | Cldr.Locale.locale_name()) ::
                String.t() | {:error, {module(), String.t()}}

        def timezone_from_locale(locale) when is_binary(locale) do
          Cldr.Locale.timezone_from_locale(locale, unquote(config.backend))
        end

        def timezone_from_locale(%LanguageTag{} = locale) do
          Cldr.Locale.timezone_from_locale(locale)
        end

      end
    end
  end
end
