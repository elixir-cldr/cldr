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

        alias Cldr.{Locale, LanguageTag}

        def new(locale_name), do: Locale.new(locale_name, unquote(config.backend))
        def new!(locale_name), do: Locale.new!(locale_name, unquote(config.backend))

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
        @spec territory_from_locale(LanguageTag.t() | Locale.locale_name()) ::
          Locale.territory_code()

        @doc since: "2.18.2"

        def territory_from_locale(%LanguageTag{} = locale) do
          Locale.territory_from_locale(locale)
        end

        def territory_from_locale(locale) do
          Locale.territory_from_locale(locale, unquote(config.backend))
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

        @spec timezone_from_locale(LanguageTag.t() | Locale.locale_name()) ::
                String.t() | {:error, {module(), String.t()}}

        def timezone_from_locale(%LanguageTag{} = locale) do
          Locale.timezone_from_locale(locale)
        end

        def timezone_from_locale(locale) do
          Locale.timezone_from_locale(locale, unquote(config.backend))
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
          #{config.backend}.validate_locale(:"en-AU")

          iex> #{inspect(__MODULE__)}.locale_for_territory(:US)
          #{config.backend}.validate_locale(:"en-US")

          iex> #{inspect(__MODULE__)}.locale_for_territory(:ZZ)
          {:error, {Cldr.UnknownTerritoryError, "The territory :ZZ is unknown"}}

        """
        @doc since: "2.26.0"
        @spec locale_for_territory(Locale.territory_code()) ::
          {:ok, LanguageTag.t()} | {:error, {module(), String.t()}}

        def locale_for_territory(territory) do
          Locale.locale_for_territory(territory)
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
            #{config.backend}.validate_locale(:"en-AU")

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
          Locale.locale_from_host(host, unquote(config.backend), options)
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
          {:ok, Locale.territory_code()} | {:error, {module(), String.t()}}

        def territory_from_host(host) do
          Cldr.Locale.territory_from_host(host)
        end

        @doc """
        Returns the list of fallback locales, starting
        with the provided locale.

        Fallbacks are a list of locate names which can
        be used to resolve translation or other localization
        data if such localised data does not exist for
        this specific locale. After locale-specific fallbacks
        are determined, the the default locale and its fallbacks
        are added to the chain.

        ## Arguments

        * `locale` is any `LanguageTag.t`

        ## Returns

        * `{:ok, list_of_locales}` or

        * `{:error, {exception, reason}}`

        ## Examples

        In these examples the default locale is `:"en-001"`.

            #{inspect __MODULE__}.fallback_locales(#{inspect __MODULE__}.new!("fr-CA"))
            => {:ok,
                 [#Cldr.LanguageTag<fr-CA [validated]>, #Cldr.LanguageTag<fr [validated]>,
                  #Cldr.LanguageTag<en [validated]>]}

            # Fallbacks are typically formed by progressively
            # stripping variant, territory and script from the
            # given locale name. But not always - there are
            # certain fallbacks that take a different path.

            #{inspect __MODULE__}.fallback_locales(#{inspect __MODULE__}.new!("nb"))
            => {:ok,
                 [#Cldr.LanguageTag<nb [validated]>, #Cldr.LanguageTag<no [validated]>,
                  #Cldr.LanguageTag<en [validated]>]}

        """
        @spec fallback_locales(LanguageTag.t() | Cldr.Locale.locale_reference) ::
                {:ok, [LanguageTag.t(), ...]} | {:error, {module(), String.t()}}

        @doc since: "2.26.0"
        def fallback_locales(%LanguageTag{} = locale) do
          Cldr.Locale.fallback_locales(locale)
        end

        @doc """
        Returns the list of fallback locales, starting
        with the provided locale name.

        Fallbacks are a list of locate names which can
        be used to resolve translation or other localization
        data if such localised data does not exist for
        this specific locale. After locale-specific fallbacks
        are determined, the the default locale and its fallbacks
        are added to the chain.

        ## Arguments

        * `locale_name` is any locale name returned by
          `#{inspect config.backend}.known_locale_names/0`

        ## Returns

        * `{:ok, list_of_locales}` or

        * `{:error, {exception, reason}}`

        ## Examples

        In these examples the default locale is `:"en-001"`.

            #{inspect __MODULE__}.fallback_locales(:"fr-CA")
            => {:ok,
                 [#Cldr.LanguageTag<fr-CA [validated]>, #Cldr.LanguageTag<fr [validated]>,
                  #Cldr.LanguageTag<en [validated]>]}

            # Fallbacks are typically formed by progressively
            # stripping variant, territory and script from the
            # given locale name. But not always - there are
            # certain fallbacks that take a different path.

            #{inspect __MODULE__}.fallback_locales(:nb))
            => {:ok,
                 [#Cldr.LanguageTag<nb [validated]>, #Cldr.LanguageTag<no [validated]>,
                  #Cldr.LanguageTag<en [validated]>]}

        """

        @doc since: "2.26.0"
        def fallback_locales(locale_name) do
          Cldr.Locale.fallback_locales(locale_name, unquote(config.backend))
        end

        @doc """
        Returns the list of fallback locale names, starting
        with the provided locale.

        Fallbacks are a list of locate names which can
        be used to resolve translation or other localization
        data if such localised data does not exist for
        this specific locale. After locale-specific fallbacks
        are determined, the the default locale and its fallbacks
        are added to the chain.

        ## Arguments

        * `locale` is any `Cldr,LangaugeTag.t`

        ## Returns

        * `{:ok, list_of_locale_names}` or

        * `{:error, {exception, reason}}`

        ## Examples

        In these examples the default locale is `:"en-001"`.

            iex> #{inspect __MODULE__}.fallback_locale_names(#{inspect __MODULE__}.new!("fr-CA"))
            {:ok, [:"fr-CA", :fr, :"en-001", :en]}

            # Fallbacks are typically formed by progressively
            # stripping variant, territory and script from the
            # given locale name. But not always - there are
            # certain fallbacks that take a different path.

            iex> #{inspect __MODULE__}.fallback_locale_names(#{inspect __MODULE__}.new!("nb"))
            {:ok, [:nb, :no, :"en-001", :en]}

        """
        @spec fallback_locale_names(LanguageTag.t() | Cldr.Locale.locale_reference) ::
                {:ok, [Cldr.Locale.locale_name, ...]} | {:error, {module(), String.t()}}

        @doc since: "2.26.0"
        def fallback_locale_names(%LanguageTag{} = locale) do
          Cldr.Locale.fallback_locale_names(locale)
        end

        @doc """
        Returns the list of fallback locale names, starting
        with the provided locale name.

        Fallbacks are a list of locate names which can
        be used to resolve translation or other localization
        data if such localised data does not exist for
        this specific locale. After locale-specific fallbacks
        are determined, the the default locale and its fallbacks
        are added to the chain.

        ## Arguments

        * `locale_name` is any locale name returned by
          `#{inspect config.backend}.known_locale_names/0`

        ## Returns

        * `{:ok, list_of_locale_names}` or

        * `{:error, {exception, reason}}`

        ## Examples

        In these examples the default locale is `:"en-001"`.

            iex> #{inspect __MODULE__}.fallback_locale_names(:"fr-CA")
            {:ok, [:"fr-CA", :fr, :"en-001", :en]}

            # Fallbacks are typically formed by progressively
            # stripping variant, territory and script from the
            # given locale name. But not always - there are
            # certain fallbacks that take a different path.

            iex> #{inspect __MODULE__}.fallback_locale_names(:nb)
            {:ok, [:nb, :no, :"en-001", :en]}

        """
        @doc since: "2.26.0"
        def fallback_locale_names(locale_name) do
          Cldr.Locale.fallback_locale_names(locale_name, unquote(config.backend))
        end
      end
    end
  end
end
