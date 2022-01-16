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

        @doc """
        Returns the "best fit" locale for a given territory.

        Using the population percentage data from CLDR, the
        language most commonly spoken in the given territory
        is used to form a locale name which is then validated
        against the given backend.

        First a territory-specific locale is validated and if
        that fails, the base language only is validate.

        For example, if the territory is `AU` then then the
        language most spoken is "en". First, the locale "en-AU"
        is validated and if that fails, "en" is validated.

        ## Arguments

        * `territory` is any ISO 3166 Alpha-2 territory
          code that can be validated by `Cldr.validate_territory/1`

        ## Returns

        * `{:ok, language_tag}` or

        * `{:error, {exception, reason}}`

        ## Examples

          iex> #{inspect(__MODULE__)}.locale_for_territory(:AU)
          #{config.backend}.validate_locale("en-AU")

          iex> #{inspect(__MODULE__)}.locale_for_territory(:US)
          #{config.backend}.validate_locale("en-US")

          iex> #{inspect(__MODULE__)}.locale_for_territory(:ZZ)
          {:error, {Cldr.UnknownTerritoryError, "The territory :ZZ is unknown"}}

        """
        @doc since: "2.26.0"
        @spec locale_for_territory(Cldr.Locale.territory_code()) ::
          {:ok, LanguageTag.t()} | {:error, {module(), String.t()}}

        def locale_for_territory(territory) do
          Cldr.Locale.locale_for_territory(territory)
        end

        @doc """
        Returns a "best fit" locale for a host name.

        ## Arguments

        * `host` is any valid host name

        * `options` is a keyword list of options. The default
          is `[]`.

        ## Options

        * `:tlds` is a list of territory codes as upper-cased
          atoms that are to be considered as top-level domains.
          See `Cldr.Locale.locale_from_host/2` for the default
          list.

        ## Returns

        * `{:ok, langauge_tag}` or

        * `{:error, {exception, reason}}`

        ## Notes

        Certain top-level domains have become associated with content
        underlated to the territory for who the domain is registered.
        Therefore Google (and perhaps others) do not associate these
        TLDs as belonging to the territory but rather are considered
        generic top-level domain names.

        ## Examples

            iex> #{inspect(__MODULE__)}.locale_from_host "a.b.com.au"
            #{config.backend}.validate_locale("en-AU")

            iex> #{inspect(__MODULE__)}.locale_from_host("a.b.com.tv")
            {:error,
             {Cldr.UnknownLocaleError, "No locale was identified for territory \\"tv\\""}}

            iex> #{inspect(__MODULE__)}.locale_from_host("a.b.com")
            {:error,
             {Cldr.UnknownLocaleError, "No locale was identified for territory \\"com\\""}}

        """
        @doc since: "2.26.0"
        @spec locale_from_host(String.t(), Keyword.t()) ::
          {:ok, LanguageTag.t()} | {:error, {module(), String.t()}}

        def locale_from_host(host, options \\ []) do
          Cldr.Locale.locale_from_host(host, unquote(config.backend), options)
        end

        @doc """
        Returns the last segment of a host that might
        be a territory.

        ## Arguments

        * `host` is any valid host name

        ## Returns

        * `{:ok, territory}` or

        * `{:error, {exception, reason}}`

        ## Examples

            iex> Cldr.Locale.territory_from_host("a.b.com.au")
            {:ok, :AU}

            iex> Cldr.Locale.territory_from_host("a.b.com")
            {:error,
             {Cldr.UnknownLocaleError, "No locale was identified for territory \\"com\\""}}

        """
        @doc since: "2.26.0"
        @spec territory_from_host(String.t()) ::
          {:ok, Cldr.Locale.territory_code()} | {:error, {module(), String.t()}}

        def territory_from_host(host) do
          Cldr.Locale.territory_from_host(host)
        end

      end
    end
  end
end
