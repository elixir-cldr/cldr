defmodule Cldr.Backend do
  @moduledoc false

  def define_backend_functions(config) do
    backend = config.backend

    quote location: :keep,bind_quoted: [config: Macro.escape(config), backend: backend] do
      @doc """
      Returns a list of the known locale names.

      Known locales are those locales which
      are the subset of all CLDR locales that
      have been configured for use either
      in this module or in `Gettext`.

      """

      alias Cldr.{Locale, Config, LanguageTag}

      @omit_locales [Config.root_locale_name()]
      @known_locale_names Locale.Loader.known_locale_names(config) -- @omit_locales

      def known_locale_names do
        @known_locale_names
      end

      @doc """
      Returns the default `locale`.

      ## Example

          iex> #{inspect(__MODULE__)}.default_locale()
          %Cldr.LanguageTag{
            backend: #{inspect(__MODULE__)},
            canonical_locale_name: "en-001",
            cldr_locale_name: :"en-001",
            language_subtags: [],
            extensions: %{},
            gettext_locale_name: "en",
            language: "en",
            locale: %{},
            private_use: [],
            rbnf_locale_name: :en,
            requested_locale_name: "en-001",
            script: :Latn,
            territory: :"001",
            transform: %{},
            language_variants: []
          }

      """
      @default_locale config
                      |> Config.default_locale_name()
                      |> Config.language_tag()
                      |> Map.put(:backend, __MODULE__)

      @compile {:inline, default_locale: 0}
      @spec default_locale :: LanguageTag.t() | no_return()
      def default_locale do
        Cldr.Locale.put_gettext_locale_name(@default_locale)
      end

      @doc """
      Returns the default territory when a locale
      does not specify one and none can be inferred.

      ## Example

          iex> #{inspect(__MODULE__)}.default_territory()
          :"001"

      """
      @spec default_territory() :: Locale.territory_code()
      def default_territory do
        Cldr.Locale.territory_from_locale(@default_locale)
      end

      @doc """
      Returns a list of the locales names that are configured,
      but not known in CLDR.

      Since there is a compile-time exception raised if there are
      any unknown locales this function should always
      return an empty list.

      """
      @unknown_locale_names Config.unknown_locale_names(config)
      @spec unknown_locale_names() :: [Locale.locale_name()]
      def unknown_locale_names do
        @unknown_locale_names
      end

      @doc """
      Returns a list of locale names which have rules-based number
      formats (RBNF).

      """
      @known_rbnf_locale_names Locale.Loader.known_rbnf_locale_names(config)

      @spec known_rbnf_locale_names() :: [Locale.locale_name()]
      def known_rbnf_locale_names do
        @known_rbnf_locale_names
      end

      @doc """
      Returns a list of Gettext locale names but in CLDR format with
      underscore replaced by hyphen in order to facilitate comparisons
      with `Cldr` locale names.

      """
      @known_gettext_locale_names Config.known_gettext_locale_names(config)

      @spec known_gettext_locale_names() :: [String.t()]
      def known_gettext_locale_names do
        @known_gettext_locale_names
      end

      @doc """
      Returns a boolean indicating if the specified locale
      name is configured and available in Cldr.

      ## Arguments

      * `locale` is any valid locale name returned by `#{inspect(__MODULE__)}.known_locale_names/0`

      ## Examples

          iex> #{inspect(__MODULE__)}.known_locale_name?(:en)
          true

          iex> #{inspect(__MODULE__)}.known_locale_name?(:"!!")
          false

      """
      @spec known_locale_name?(Locale.locale_name()) :: boolean
      def known_locale_name?(locale_name) when is_atom(locale_name) do
        locale_name in known_locale_names()
      end

      @doc """
      Returns a boolean indicating if the specified locale
      name is configured and available in Cldr and supports
      rules based number formats (RBNF).

      ## Arguments

      * `locale` is any valid locale name returned by `#{inspect(__MODULE__)}.known_locale_names/0`

      ## Examples

          iex> #{inspect(__MODULE__)}.known_rbnf_locale_name?(:en)
          true

          iex> #{inspect(__MODULE__)}.known_rbnf_locale_name?(:"!!")
          false

      """
      @spec known_rbnf_locale_name?(Locale.locale_name()) :: boolean
      def known_rbnf_locale_name?(locale_name) when is_atom(locale_name) do
        locale_name in known_rbnf_locale_names()
      end

      @doc """
      Returns a boolean indicating if the specified locale
      name is configured and available in Gettext.

      ## Arguments

      * `locale` is any valid locale name returned by
        `#{inspect(__MODULE__)}.known_locale_names/0`

      ## Examples

          iex> #{inspect(__MODULE__)}.known_gettext_locale_name?("en")
          true

          iex> #{inspect(__MODULE__)}.known_gettext_locale_name?("!!")
          false

      """
      @spec known_gettext_locale_name?(String.t()) :: boolean
      def known_gettext_locale_name?(locale_name) when is_binary(locale_name) do
        locale_name in known_gettext_locale_names()
      end

      @doc """
      Returns either the `locale_name` or `false` based upon
      whether the locale name is configured in `Cldr`.

      This is helpful when building a list of `or` expressions
      to return the first known locale name from a list.

      ## Arguments

      * `locale` is any valid locale name returned by
        `#{inspect(__MODULE__)}.known_locale_names/0`

      ## Examples

          iex> #{inspect(__MODULE__)}.known_locale_name :"en-AU"
          :"en-AU"

          iex> #{inspect(__MODULE__)}.known_locale_name :"en-SA"
          false

      """
      @spec known_locale_name(Locale.locale_name()) :: String.t() | false
      def known_locale_name(locale_name) when is_atom(locale_name) do
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

      * `locale` is any valid locale name returned by
        `#{inspect(__MODULE__)}.known_locale_names/0`

      ## Examples

          iex> #{inspect(__MODULE__)}.known_rbnf_locale_name :en
          :en

          iex> #{inspect(__MODULE__)}.known_rbnf_locale_name :"en-SA"
          false

      """
      @spec known_rbnf_locale_name(Locale.locale_name()) :: String.t() | false
      def known_rbnf_locale_name(locale_name) when is_atom(locale_name) do
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

      * `locale` is any valid locale name returned by
        `#{inspect(__MODULE__)}.known_gettext_locale_names/0`

      ## Examples

          iex> #{inspect(__MODULE__)}.known_gettext_locale_name "en"
          "en"

          iex> #{inspect(__MODULE__)}.known_gettext_locale_name "en-SA"
          false

      """
      @spec known_gettext_locale_name(String.t()) :: String.t() | false
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

          iex> #{inspect(__MODULE__)}.put_locale("pl")
          iex> #{inspect(__MODULE__)}.get_locale
          %Cldr.LanguageTag{
             backend: #{__MODULE__},
             canonical_locale_name: "pl",
             cldr_locale_name: :pl,
             extensions: %{},
             language: "pl",
             locale: %{},
             private_use: [],
             rbnf_locale_name: :pl,
             territory: :PL,
             requested_locale_name: "pl",
             script: :Latn,
             transform: %{},
             language_variants: []
           }

      """
      @spec get_locale :: LanguageTag.t()
      def get_locale do
        Cldr.get_locale(__MODULE__)
      end

      @doc """
      Set the current locale to be used for `Cldr` functions that
      take an optional locale parameter for which a locale is not supplied.

      ## Arguments

      * `locale` is any valid locale name returned by `#{inspect(__MODULE__)}.known_locale_names/0`
        or a `t:Cldr.LanguageTag` struct returned by `#{inspect(__MODULE__)}.Locale.new!/1`

      See [rfc5646](https://tools.ietf.org/html/rfc5646) for the specification
      of a language tag.

      ## Examples

          iex> #{inspect(__MODULE__)}.put_locale("en")
          {:ok,
           %Cldr.LanguageTag{
             backend: #{inspect(__MODULE__)},
             canonical_locale_name: "en",
             cldr_locale_name: :en,
             language_subtags: [],
             extensions: %{},
             gettext_locale_name: "en",
             language: "en",
             locale: %{},
             private_use: [],
             rbnf_locale_name: :en,
             requested_locale_name: "en",
             script: :Latn,
             territory: :US,
             transform: %{},
             language_variants: []
           }}

          iex> #{inspect(__MODULE__)}.put_locale("invalid-locale!")
          {:error, {Cldr.LanguageTag.ParseError,
            "Expected a BCP47 language tag. Could not parse the remaining \\"!\\" starting at position 15"}}

      """
      @spec put_locale(Locale.locale_reference()) ::
              {:ok, LanguageTag.t()} | {:error, {module(), String.t()}}

      def put_locale(locale_name) do
        with {:ok, locale} <- validate_locale(locale_name) do
          Cldr.put_locale(__MODULE__, locale)
        end
      end

      @doc """
      Execute a function with a locale ensuring that the
      current locale is restored after the function.

      ## Arguments

      * `locale` is any `t:Cldr.LanguageTag.t/0`, tyically returned
        by `Cldr.validate_locale/2`.

      * `fun` is any 0-arity function or function capture.

      ## Returns

      * The value returned by the function `fun/0` or

      * raises an exception if the current locale cannot be
        identified.

      """
      @doc since: "2.32.0"

      @spec with_locale(Cldr.LanguageTag.t(), fun) :: any
      def with_locale(%Cldr.LanguageTag{} = locale, fun) when is_function(fun) do
        Cldr.with_locale(locale, fun)
      end

      @doc """
      Execute a function with a locale ensuring that the
      current locale is restored after the function.

      ## Arguments

      * `locale` is any valid locale name returned by `Cldr.known_locale_names/1`.

      * `fun` is any 0-arity function or function capture.

      ## Returns

      * The value returned by the function `fun/0` or

      * `{:error, {exception, reason}}` if the locale is invalid or

      * raises an exception if the current locale cannot be
        identified.

      """
      @doc since: "2.32.0"

      @spec with_locale(Cldr.Locale.locale_name(), fun) :: any
      def with_locale(locale, fun) when Cldr.is_locale_name(locale) do
        with {:ok, locale} = validate_locale(locale) do
          with_locale(locale, fun)
        end
      end

      @doc """
      Add locale-specific quotation marks around a string.

      ## Arguments

      * `string` is any valid Elixir string

      * `options` is a keyword list of options

      ## Options

      * `locale` is any valid locale name returned by `Cldr.known_locale_names/1`.
        The default is `Cldr.get_locale/0`

      ## Examples

          iex> #{inspect(__MODULE__)}.quote "Quoted String"
          "“Quoted String”"

          iex> #{inspect(__MODULE__)}.quote "Quoted String", locale: :ja
          "「Quoted String」"

      """
      @spec quote(String.t(), Keyword.t()) :: String.t()

      def quote(string, options \\ []) when is_binary(string) and is_list(options) do
        locale = options[:locale] || Cldr.get_locale()

        with {:ok, %LanguageTag{cldr_locale_name: locale_name}} <- validate_locale(locale) do
          marks = quote_marks_for(locale_name)
          marks[:quotation_start] <> string <> marks[:quotation_end]
        end
      end

      @doc """
      Add locale-specific ellipsis to a string.

      ## Arguments

      * `string` is any `String.t` or a 2-element list
        of `String.t` between which the ellipsis is inserted.

      * `backend` is any module that includes `use Cldr` and therefore
        is a `Cldr` backend module.  The default is `Cldr.default_backend!/0`.
        Note that `Cldr.default_backend!/0` will raise an exception if
        no `:default_backend` is configured under the `:ex_cldr` key in
        `config.exs`.

      * `options` is a keyword list of options

      ## Options

      * `:locale` is any valid locale name returned by `Cldr.known_locale_names/1`.
        The default is `Cldr.get_locale/0`.

      * `:location` determines where to place the ellipsis. The options are
        `:after` (the default for a single string argument), `:between`
        (the default and only valid location for an argument that is a list
        of two strings) and `:before`.

      * `:format` formats based upon whether the ellipsis
        is inserted between words or sentences. The valid options are
        `:word` or `:sentence`. The default is `:sentence`.

      ## Examples

          iex> #{inspect(__MODULE__)}.ellipsis "And furthermore"
          "And furthermore…"

          iex> #{inspect(__MODULE__)}.ellipsis ["And furthermore", "there is much to be done"], locale: :ja
          "And furthermore…there is much to be done"

          iex> #{inspect(__MODULE__)}.ellipsis "And furthermore", format: :word
          "And furthermore …"

          iex> #{inspect(__MODULE__)}.ellipsis ["And furthermore", "there is much to be done"], locale: :ja, format: :word
          "And furthermore … there is much to be done"

      """
      @spec ellipsis(String.t() | list(String.t()), Keyword.t()) :: String.t()

      def ellipsis(string, options \\ []) when is_list(options) do
        locale = options[:locale] || Cldr.get_locale()
        format = options[:format] || :sentence
        location = options[:location] || :between

        with {:ok, %LanguageTag{cldr_locale_name: locale_name}} <- validate_locale(locale) do
          ellipsis(string, ellipsis_chars(locale_name), location, format)
        end
      end

      # For the :word format

      defp ellipsis([string_1, string_2], %{word_medial: medial}, _, :word)
           when is_binary(string_1) and is_binary(string_2) do
        [string_1, string_2]
        |> Cldr.Substitution.substitute(medial)
        |> :erlang.iolist_to_binary()
      end

      defp ellipsis(string, %{word_final: final}, :after, :word) when is_binary(string) do
        string
        |> Cldr.Substitution.substitute(final)
        |> :erlang.iolist_to_binary()
      end

      defp ellipsis(string, %{word_initial: initial}, :before, :word) when is_binary(string) do
        string
        |> Cldr.Substitution.substitute(initial)
        |> :erlang.iolist_to_binary()
      end

      defp ellipsis(string, %{word_final: final}, _, :word) when is_binary(string) do
        string
        |> Cldr.Substitution.substitute(final)
        |> :erlang.iolist_to_binary()
      end

      # For the :sentence format

      defp ellipsis([string_1, string_2], %{medial: medial}, _, _)
           when is_binary(string_1) and is_binary(string_2) do
        [string_1, string_2]
        |> Cldr.Substitution.substitute(medial)
        |> :erlang.iolist_to_binary()
      end

      defp ellipsis(string, %{final: final}, :after, _) when is_binary(string) do
        string
        |> Cldr.Substitution.substitute(final)
        |> :erlang.iolist_to_binary()
      end

      defp ellipsis(string, %{initial: initial}, :before, _) when is_binary(string) do
        string
        |> Cldr.Substitution.substitute(initial)
        |> :erlang.iolist_to_binary()
      end

      defp ellipsis(string, %{final: final}, _, _) when is_binary(string) do
        string
        |> Cldr.Substitution.substitute(final)
        |> :erlang.iolist_to_binary()
      end

      @doc """
      Normalise and validate a locale name.

      ## Arguments

      * `locale` is any valid locale name returned by `#{inspect(__MODULE__)}.known_locale_names/0`
        or a `Cldr.LanguageTag` struct returned by `#{inspect(__MODULE__)}.Locale.new!/1`

      ## Returns

      * `{:ok, language_tag}`

      * `{:error, reason}`

      ## Notes

      See [rfc5646](https://tools.ietf.org/html/rfc5646) for the specification
      of a language tag.

      ## Examples

          iex> #{inspect(__MODULE__)}.validate_locale(:en)
          {:ok,
          %Cldr.LanguageTag{
            backend: #{inspect(__MODULE__)},
            canonical_locale_name: "en",
            cldr_locale_name: :en,
            extensions: %{},
            gettext_locale_name: "en",
            language: "en",
            locale: %{},
            private_use: [],
            rbnf_locale_name: :en,
            requested_locale_name: "en",
            script: :Latn,
            territory: :US,
            transform: %{},
            language_variants: []
          }}


          iex> #{inspect(__MODULE__)}.validate_locale #{inspect(__MODULE__)}.default_locale()
          {:ok,
          %Cldr.LanguageTag{
            backend: #{inspect(__MODULE__)},
            canonical_locale_name: "en-001",
            cldr_locale_name: :"en-001",
            extensions: %{},
            gettext_locale_name: "en",
            language: "en",
            locale: %{},
            private_use: [],
            rbnf_locale_name: :en,
            requested_locale_name: "en-001",
            script: :Latn,
            territory: :"001",
            transform: %{},
            language_variants: []
          }}

          iex> #{inspect(__MODULE__)}.validate_locale("zzz")
          {:error, {Cldr.InvalidLanguageError, "The language \\"zzz\\" is invalid"}}

      """
      @spec validate_locale(Locale.locale_name() | LanguageTag.t() | String.t()) ::
              {:ok, LanguageTag.t()} | {:error, {module(), String.t()}}

      def validate_locale(%LanguageTag{cldr_locale_name: nil} = locale) do
        {:error, Locale.locale_error(locale)}
      end

      def validate_locale(%LanguageTag{} = language_tag) do
        {:ok, language_tag}
      end

      def validate_locale(locale_name) when is_binary(locale_name) do
        locale =
          locale_name
          |> String.downcase()
          |> Cldr.Locale.locale_name_from_posix()
          |> do_validate_locale

        case locale do
          {:error, {Cldr.UnknownLocaleError, _}} -> {:error, Locale.locale_error(locale_name)}
          {:error, reason} -> {:error, reason}
          {:ok, locale} -> {:ok, locale}
        end
      end

      def validate_locale(locale_name) when is_atom(locale_name) do
        locale =
          locale_name
          |> Atom.to_string()
          |> validate_locale

        case locale do
          {:error, {Cldr.UnknownLocaleError, _}} -> {:error, Locale.locale_error(locale_name)}
          {:error, reason} -> {:error, reason}
          {:ok, locale} -> {:ok, locale}
        end
      end

      def validate_locale(locale) do
        {:error, Locale.locale_error(locale)}
      end

      @doc """
      Normalizes a string by applying transliteration
      of common symbols in numbers, currencies and dates

      """
      def normalize_lenient_parse(string, scope, locale \\ get_locale()) do
        with {:ok, locale} <- validate_locale(locale) do
          locale_name = locale.cldr_locale_name

          Enum.reduce(lenient_parse_map(scope, locale_name), string, fn
            {replacement, regex}, acc ->
              String.replace(acc, regex, replacement)
          end)
        end
      end

      @doc false
      # We make two adjustments to the character classes
      # in CLDR
      #
      # 1. Adjust the escaping of "\" to suit
      # 2. Remove compound patterns like `{Rs}` which
      #    are not supported in Erlang's re

      @remove_compounds Regex.compile!("{.*}", [:ungreedy])

      for locale_name <- Cldr.Locale.Loader.known_locale_names(config) do
        lenient_parse =
          locale_name
          |> Cldr.Locale.Loader.get_locale(config)
          |> Map.get(:lenient_parse)
          |> Cldr.Map.deep_map(
            fn {k, v} ->
              regex =
                v
                |> String.replace("\x5c\x5c", "\x5c")
                |> String.replace(@remove_compounds, "")

              {k, Regex.compile!(regex, "u")}
            end,
            level: 2
          )
          |> Cldr.Map.atomize_keys(level: 1)
          |> Map.new()

        for {scope, map} <- lenient_parse do
          def lenient_parse_map(unquote(scope), unquote(locale_name)) do
            unquote(Macro.escape(map))
          end
        end
      end

      # When validating known locale names we memoize the
      # parsed language tag for performance reasons and only
      # add the gettext locale name (if there is one) and the
      # backend module.

      for locale_name <- Cldr.Locale.Loader.known_locale_names(config),
          not is_nil(Cldr.Config.language_tag(locale_name)) do

        language_tag =
          locale_name
          |> Cldr.Config.language_tag()
          |> Cldr.Locale.put_gettext_locale_name(config)
          |> Map.put(:backend, __MODULE__)

        locale_name =
          locale_name
          |> Atom.to_string()
          |> String.downcase()

        defp do_validate_locale(unquote(locale_name)) do
          {:ok, unquote(Macro.escape(language_tag))}
        end
      end

      for locale_name <- Cldr.Locale.Loader.known_locale_names(config) do
        delimiters =
          locale_name
          |> Cldr.Locale.Loader.get_locale(config)
          |> Map.get(:delimiters)

        defp quote_marks_for(unquote(locale_name)) do
          unquote(Macro.escape(delimiters))
        end

        ellipsis =
          locale_name
          |> Cldr.Locale.Loader.get_locale(config)
          |> Map.get(:ellipsis)

        @doc false
        def ellipsis_chars(unquote(locale_name)) do
          unquote(Macro.escape(ellipsis))
        end
      end

      # It's not a well known locale so we need to
      # parse and validate

      defp do_validate_locale(locale_name) do
        with {:ok, locale} <- Cldr.Locale.new(locale_name, unquote(backend)),
             {:ok, locale} <- known_cldr_locale(locale, locale_name),
             {:ok, locale} <- known_cldr_territory(locale) do
          {:ok, locale}
        end
      end

      defp known_cldr_locale(%LanguageTag{cldr_locale_name: nil}, locale_name) do
        {:error, Cldr.Locale.locale_error(locale_name)}
      end

      defp known_cldr_locale(%LanguageTag{} = locale, _locale_name) do
        {:ok, locale}
      end

      defp known_cldr_territory(%LanguageTag{territory: territory} = language_tag) do
        if territory in Cldr.known_territories() do
          {:ok, language_tag}
        else
          {:error, Cldr.unknown_territory_error(territory)}
        end
      end

      @doc """
      Returns a list of atoms representing the number systems types known to `Cldr`.

      ## Example

          iex> #{inspect(__MODULE__)}.known_number_system_types
          [:default, :finance, :native, :traditional]

      """
      @known_number_system_types Cldr.Config.known_number_system_types(config)
      def known_number_system_types do
        @known_number_system_types
      end

      @doc """
      Normalise and validate a number system type.

      ## Arguments

      * `number_system_type` is any number system type returned by
        `Cldr.known_number_system_types/1`

      ## Returns

      * `{:ok, normalized_number_system_type}` or

      * `{:error, {exception, message}}`

      ## Examples

          iex> #{inspect(__MODULE__)}.validate_number_system_type :default
          {:ok, :default}

          iex> #{inspect(__MODULE__)}.validate_number_system_type :traditional
          {:ok, :traditional}

          iex> #{inspect(__MODULE__)}.validate_number_system_type :latn
          {
            :error,
            {Cldr.UnknownNumberSystemTypeError, "The number system type :latn is unknown"}
          }

          iex> #{inspect(__MODULE__)}.validate_number_system_type "bork"
          {
            :error,
            {Cldr.UnknownNumberSystemTypeError, "The number system type \\"bork\\" is invalid"}
          }

      """
      @spec validate_number_system_type(String.t() | atom()) ::
              {:ok, atom()} | {:error, {module(), String.t()}}

      def validate_number_system_type(number_system_type) when is_atom(number_system_type) do
        if number_system_type in known_number_system_types() do
          {:ok, number_system_type}
        else
          {:error, Cldr.unknown_number_system_type_error(number_system_type)}
        end
      end

      def validate_number_system_type(number_system_type) when is_binary(number_system_type) do
        number_system_type
        |> String.downcase()
        |> String.to_existing_atom()
        |> validate_number_system_type
      rescue
        ArgumentError ->
          {:error, Cldr.unknown_number_system_type_error(to_string(number_system_type))}
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
