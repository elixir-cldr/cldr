defmodule Cldr.Backend.Compiler do
  @moduledoc false

  @doc false
  defmacro __before_compile__(env) do
    cldr_opts = Module.get_attribute(env.module, :cldr_opts)
    config = struct(Cldr.Config, cldr_opts)

    config =
      config
      |> Map.put(:backend, env.module)
      |> Map.put(:default_locale, Cldr.Config.default_locale(config))

    [_, backend] = to_string(env.module) |> String.split(".", parts: 2)

    Cldr.Config.check_jason_lib_is_available!()
    Cldr.install_locales(config)

    quote location: :keep do
      @moduledoc """
      Provides the core functions to retrieve and manage
      the CLDR data that supports formatting and localisation.

      It provides the core functions to access formatted
      CLDR data, set and retrieve a current locale and validate
      certain core data types such as locales, currencies and
      territories.

      """
      alias Cldr.Config
      alias Cldr.LanguageTag

      def __cldr__(:backend), do: unquote(Map.get(config, :backend))
      def __cldr__(:locales), do: unquote(Map.get(config, :locales))
      def __cldr__(:default_locale), do: unquote(Map.get(config, :default_locale))
      def __cldr__(:gettext), do: unquote(Map.get(config, :gettext))
      def __cldr__(:data_dir), do: unquote(Map.get(config, :data_dir))
      def __cldr__(:config), do: unquote(Macro.escape(config))

      @doc """
      Returns a list of the known locale names.

      Known locales are those locales which
      are the subset of all CLDR locales that
      have been configured for use either
      in this module or in `Gettext`.

      """
      @known_locale_names Cldr.Config.known_locale_names(unquote(Macro.escape(config)))
      def known_locale_names do
        @known_locale_names
      end

      @doc """
      Returns the default `locale`.

      ## Example

          iex> #{unquote(backend)}.default_locale()
          %Cldr.LanguageTag{
            canonical_locale_name: "en-Latn-001",
            cldr_locale_name: "en-001",
            language_subtags: [],
            extensions: %{},
            gettext_locale_name: nil,
            language: "en",
            locale: %{},
            private_use: [],
            rbnf_locale_name: "en",
            requested_locale_name: "en-001",
            script: "Latn",
            territory: "001",
            transform: %{},
            language_variant: nil
          }

      """
      @default_locale Cldr.Config.default_locale(unquote(Macro.escape(config))) |> Cldr.Config.language_tag()
      @spec default_locale :: Cldr.LanguageTag.t()
      def default_locale do
        @default_locale
      end

      @doc """
      Returns the default territory when a locale
      does not specify one and none can be inferred.

      ## Example

          iex> #{unquote(backend)}.default_territory()
          :"001"

      """
      @default_territory @default_locale |> Map.get(:territory) |> String.to_atom()
      @spec default_territory() :: atom()
      def default_territory do
        @default_territory
      end

      @doc """
      Returns a list of the locales names that are configured,
      but not known in CLDR.

      Since there is a compile-time exception raised if there are
      any unknown locales this function should always
      return an empty list.

      """
      @unknown_locale_names Cldr.Config.unknown_locale_names(unquote(Macro.escape(config)))
      @spec unknown_locale_names() :: [Locale.locale_name(), ...] | []
      def unknown_locale_names do
        @unknown_locale_names
      end

      @doc """
      Returns a list of locale names which have rules-based number
      formats (RBNF).

      """
      @known_rbnf_locale_names Cldr.Config.known_rbnf_locale_names(unquote(Macro.escape(config)))
      @spec known_rbnf_locale_names() :: [Locale.locale_name(), ...] | []
      def known_rbnf_locale_names do
        @known_rbnf_locale_names
      end

      @doc """
      Returns a list of GetText locale names but in CLDR format with
      underscore replaced by hyphen in order to facilitate comparisons
      with `Cldr` locale names.

      """
      @known_gettext_locale_names Config.gettext_locales(unquote(Macro.escape(config)))
      @spec known_gettext_locale_names() :: [Locale.locale_name(), ...] | []
      def known_gettext_locale_names do
        @known_gettext_locale_names
      end

      @doc """
      Returns a boolean indicating if the specified locale
      name is configured and available in Cldr.

      ## Arguments

      * `locale` is any valid locale name returned by `#{unquote(backend)}.known_locale_names/0`

      ## Examples

          iex> #{unquote(backend)}.known_locale_name?("en")
          true

          iex> #{unquote(backend)}.known_locale_name?("!!")
          false

      """
      @spec known_locale_name?(Locale.locale_name()) :: boolean
      def known_locale_name?(locale_name) when is_binary(locale_name) do
        locale_name in known_locale_names()
      end

      @doc """
      Returns a boolean indicating if the specified locale
      name is configured and available in Cldr and supports
      rules based number formats (RBNF).

      ## Arguments

      * `locale` is any valid locale name returned by `#{unquote(backend)}.known_locale_names/0`

      ## Examples

          iex> #{unquote(backend)}.known_rbnf_locale_name?("en")
          true

          iex> #{unquote(backend)}.known_rbnf_locale_name?("!!")
          false

      """
      @spec known_rbnf_locale_name?(Locale.locale_name()) :: boolean
      def known_rbnf_locale_name?(locale_name) when is_binary(locale_name) do
        locale_name in known_rbnf_locale_names()
      end

      @doc """
      Returns a boolean indicating if the specified locale
      name is configured and available in Gettext.

      ## Arguments

      * `locale` is any valid locale name returned by `#{unquote(backend)}.known_locale_names/0`

      ## Examples

          iex> #{unquote(backend)}.known_gettext_locale_name?("en")
          true

          iex> #{unquote(backend)}.known_gettext_locale_name?("!!")
          false

      """
      @spec known_gettext_locale_name?(Locale.locale_name()) :: boolean
      def known_gettext_locale_name?(locale_name) when is_binary(locale_name) do
        locale_name in known_gettext_locale_names()
      end

      @doc """
      Returns either the `locale_name` or `false` based upon
      whether the locale name is configured in `Cldr`.

      This is helpful when building a list of `or` expressions
      to return the first known locale name from a list.

      ## Arguments

      * `locale` is any valid locale name returned by `#{unquote(backend)}.known_locale_names/0`

      ## Examples

          iex> #{unquote(backend)}.known_locale_name "en-AU"
          "en-AU"

          iex> #{unquote(backend)}.known_locale_name "en-SA"
          false

      """
      @spec known_locale_name(Locale.locale_name()) :: String.t() | false
      def known_locale_name(locale_name) when is_binary(locale_name) do
        if known_locale_name?(locale_name) do
          locale_name
        else
          false
        end
      end

      @doc """
      Returns either the RBNF `locale_name` or `false` based upon
      whether the locale name is configured in `Cldr`
      and has RBNF rules defined.

      ## Arguments

      * `locale` is any valid locale name returned by `#{unquote(backend)}.known_locale_names/0`

      ## Examples

          iex> #{unquote(backend)}.known_rbnf_locale_name "en"
          "en"

          iex> #{unquote(backend)}.known_rbnf_locale_name "en-SA"
          false

      """
      @spec known_rbnf_locale_name(Locale.locale_name()) :: String.t() | false
      def known_rbnf_locale_name(locale_name) when is_binary(locale_name) do
        if known_rbnf_locale_name?(locale_name) do
          locale_name
        else
          false
        end
      end

      @doc """
      Returns either the Gettext `locale_name` in Cldr format or
      `false` based upon whether the locale name is configured in
      `Gettext`.

      ## Arguments

      * `locale` is any valid locale name returned by `#{unquote(backend)}.known_locale_names/0`

      ## Examples

          iex> #{unquote(backend)}.known_gettext_locale_name "en"
          "en"

          iex> #{unquote(backend)}.known_gettext_locale_name "en-SA"
          false

      """
      @spec known_gettext_locale_name(Locale.locale_name()) :: String.t() | false
      def known_gettext_locale_name(locale_name) when is_binary(locale_name) do
        if known_gettext_locale_name?(locale_name) do
          locale_name
        else
          false
        end
      end

      defdelegate available_locale_name?(locale_name), to: Cldr
      defdelegate known_calendars(), to: Cldr
      defdelegate validate_calendar(calendar), to: Cldr
      defdelegate known_territories(), to: Cldr
      defdelegate validate_territory(territory), to: Cldr
      defdelegate known_currencies(), to: Cldr
      defdelegate validate_currency(currency), to: Cldr
      defdelegate known_number_systems(), to: Cldr
      defdelegate validate_number_system(number_system), to: Cldr
      defdelegate locale_name(locale), to: Cldr

      unquote(Cldr.define_validate_locale(config))
      unquote(Cldr.Number.PluralRule.define_ordinal_and_cardinal_modules(config))

      if Code.ensure_loaded?(Gettext) do
        unquote(Cldr.Gettext.Plural.define_gettext_plurals_module(config))
      end
    end
  end

end