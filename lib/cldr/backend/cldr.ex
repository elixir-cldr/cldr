defmodule Cldr.Backend do
  @moduledoc false

  def define_backend_functions(config) do
    quote location: :keep, bind_quoted: [config: Macro.escape(config)] do
      @doc """
      Returns a list of the known locale names.

      Known locales are those locales which
      are the subset of all CLDR locales that
      have been configured for use either
      in this module or in `Gettext`.

      """
      @known_locale_names Cldr.Config.known_locale_names(config)
      def known_locale_names do
        @known_locale_names
      end

      @doc """
      Returns the default `locale`.

      ## Example

          iex> #{__MODULE__}.default_locale()
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
      @default_locale Cldr.Config.default_locale(config) |> Cldr.Config.language_tag()
      @spec default_locale :: Cldr.LanguageTag.t()
      def default_locale do
        @default_locale
      end

      @doc """
      Returns the default territory when a locale
      does not specify one and none can be inferred.

      ## Example

          iex> #{__MODULE__}.default_territory()
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
      @unknown_locale_names Cldr.Config.unknown_locale_names(config)
      @spec unknown_locale_names() :: [Locale.locale_name(), ...] | []
      def unknown_locale_names do
        @unknown_locale_names
      end

      @doc """
      Returns a list of locale names which have rules-based number
      formats (RBNF).

      """
      @known_rbnf_locale_names Cldr.Config.known_rbnf_locale_names(config)
      @spec known_rbnf_locale_names() :: [Locale.locale_name(), ...] | []
      def known_rbnf_locale_names do
        @known_rbnf_locale_names
      end

      @doc """
      Returns a list of GetText locale names but in CLDR format with
      underscore replaced by hyphen in order to facilitate comparisons
      with `Cldr` locale names.

      """
      @known_gettext_locale_names Config.gettext_locales(config)
      @spec known_gettext_locale_names() :: [Locale.locale_name(), ...] | []
      def known_gettext_locale_names do
        @known_gettext_locale_names
      end

      @doc """
      Returns a boolean indicating if the specified locale
      name is configured and available in Cldr.

      ## Arguments

      * `locale` is any valid locale name returned by `#{__MODULE__}.known_locale_names/0`

      ## Examples

          iex> #{__MODULE__}.known_locale_name?("en")
          true

          iex> #{__MODULE__}.known_locale_name?("!!")
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

      * `locale` is any valid locale name returned by `#{__MODULE__}.known_locale_names/0`

      ## Examples

          iex> #{__MODULE__}.known_rbnf_locale_name?("en")
          true

          iex> #{__MODULE__}.known_rbnf_locale_name?("!!")
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

      * `locale` is any valid locale name returned by `#{__MODULE__}.known_locale_names/0`

      ## Examples

          iex> #{__MODULE__}.known_gettext_locale_name?("en")
          true

          iex> #{__MODULE__}.known_gettext_locale_name?("!!")
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

      * `locale` is any valid locale name returned by `#{__MODULE__}.known_locale_names/0`

      ## Examples

          iex> #{__MODULE__}.known_locale_name "en-AU"
          "en-AU"

          iex> #{__MODULE__}.known_locale_name "en-SA"
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

      * `locale` is any valid locale name returned by `#{__MODULE__}.known_locale_names/0`

      ## Examples

          iex> #{__MODULE__}.known_rbnf_locale_name "en"
          "en"

          iex> #{__MODULE__}.known_rbnf_locale_name "en-SA"
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

      * `locale` is any valid locale name returned by `#{__MODULE__}.known_locale_names/0`

      ## Examples

          iex> #{__MODULE__}.known_gettext_locale_name "en"
          "en"

          iex> #{__MODULE__}.known_gettext_locale_name "en-SA"
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

      @doc """
      Return the current locale to be used for `Cldr` functions that
      take an optional locale parameter for which a locale is not supplied.

      ## Example

          iex> #{__MODULE__}.put_current_locale("pl")
          iex> #{__MODULE__}.get_current_locale
          %Cldr.LanguageTag{
             canonical_locale_name: "pl-Latn-PL",
             cldr_locale_name: "pl",
             extensions: %{},
             language: "pl",
             locale: %{},
             private_use: [],
             rbnf_locale_name: "pl",
             territory: "PL",
             requested_locale_name: "pl",
             script: "Latn",
             transform: %{},
             language_variant: nil
           }

      """
      @spec get_current_locale :: LanguageTag.t()
      def get_current_locale do
        Cldr.get_current_locale(default_locale())
      end

      @doc """
      Set the current locale to be used for `Cldr` functions that
      take an optional locale parameter for which a locale is not supplied.

      ## Arguments

      * `locale` is any valid locale name returned by `Cldr.known_locale_names/1`
        or a `Cldr.LanguageTag` struct returned by `Cldr.Locale.new!/1`

      See [rfc5646](https://tools.ietf.org/html/rfc5646) for the specification
      of a language tag and consult `./priv/cldr/rfc5646.abnf` for the
      specification as implemented that includes the CLDR extensions for
      "u" (locales) and "t" (transforms).

      ## Examples

          iex> #{__MODULE__}.put_current_locale("en")
          {:ok,
           %Cldr.LanguageTag{
             canonical_locale_name: "en-Latn-US",
             cldr_locale_name: "en",
             language_subtags: [],
             extensions: %{},
             gettext_locale_name: "en",
             language: "en",
             locale: %{},
             private_use: [],
             rbnf_locale_name: "en",
             requested_locale_name: "en",
             script: "Latn",
             territory: "US",
             transform: %{},
             language_variant: nil
           }}

          iex> #{__MODULE__}.put_current_locale("invalid_locale")
          {:error,
           {Cldr.LanguageTag.ParseError,
            "Invalid language tag. Could not parse the remaining \\"le\\" starting at position 13"}}

      """
      @spec put_current_locale(Locale.locale_name() | LanguageTag.t()) ::
              {:ok, LanguageTag.t()} | {:error, {Exception.t(), String.t()}}

      def put_current_locale(locale_name) when is_binary(locale_name) do
        Cldr.put_current_locale(locale_name, __MODULE__)
      end

      @doc """
      Normalise and validate a locale name.

      ## Arguments

      * `locale` is any valid locale name returned by `#{__MODULE__}.known_locale_names/0`
        or a `Cldr.LanguageTag` struct returned by `Cldr.Locale.new!/2

      ## Returns

      * `{:ok, language_tag}`

      * `{:error, reason}`

      ## Examples

          iex> #{__MODULE__}.validate_locale("en")
          {:ok,
          %Cldr.LanguageTag{
            canonical_locale_name: "en-Latn-US",
            cldr_locale_name: "en",
            extensions: %{},
            gettext_locale_name: "en",
            language: "en",
            locale: %{},
            private_use: [],
            rbnf_locale_name: "en",
            requested_locale_name: "en",
            script: "Latn",
            territory: "US",
            transform: %{},
            language_variant: nil
          }}


          iex> #{__MODULE__}.validate_locale #{__MODULE__}.default_locale()
          {:ok,
          %Cldr.LanguageTag{
            canonical_locale_name: "en-Latn-001",
            cldr_locale_name: "en-001",
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
          }}

          iex> #{__MODULE__}.validate_locale("zzz")
          {:error, {Cldr.UnknownLocaleError, "The locale \\"zzz\\" is not known."}}

      """
      @spec validate_locale(Locale.locale_name() | LanguageTag.t()) ::
              {:ok, String.t()} | {:error, {Exception.t(), String.t()}}

      language_tags = Cldr.Config.all_language_tags()

      for locale_name <- Cldr.Config.known_locale_names(config) do
        language_tag =
          Map.get(language_tags, locale_name)
          |> Cldr.Locale.put_gettext_locale_name(config)

        def validate_locale(unquote(locale_name)) do
          {:ok, unquote(Macro.escape(language_tag))}
        end
      end

      def validate_locale(%LanguageTag{cldr_locale_name: nil} = locale) do
        {:error, Locale.locale_error(locale)}
      end

      def validate_locale(%LanguageTag{} = language_tag) do
        {:ok, language_tag}
      end

      def validate_locale(locale) do
        {:error, Locale.locale_error(locale)}
      end

      defdelegate available_locale_name?(locale_name), to: Cldr

      defdelegate known_calendars(), to: Cldr
      defdelegate known_territories(), to: Cldr
      defdelegate known_currencies(), to: Cldr
      defdelegate known_number_systems(), to: Cldr

      defdelegate validate_calendar(calendar), to: Cldr
      defdelegate validate_territory(territory), to: Cldr
      defdelegate validate_currency(currency), to: Cldr
      defdelegate validate_number_system(number_system), to: Cldr
    end
  end
end