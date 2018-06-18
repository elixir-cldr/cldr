defmodule Cldr.Compiler do
  @moduledoc false

  @doc false
  defmacro __before_compile__(env) do
    cldr_opts = Module.get_attribute(env.module, :cldr_opts)
    install_locales(env.backend)

    quote do
      unquote(validate_locale())
    end
  end

  @warn_if_greater_than 100

  defp install_locales(backend) do
    alias Cldr.Config

    Cldr.Install.install_known_locale_names()

    known_locale_count = Enum.count(Cldr.Config.known_locale_names(backend))
    locale_string = if known_locale_count > 1, do: "locales named ", else: "locale named "

    if Enum.any?(Config.unknown_locale_names()) do
      raise Cldr.UnknownLocaleError,
            "Some locale names are configured that are not known to CLDR. " <>
              "Compilation cannot continue until the configuration includes only " <>
              "locales names known in CLDR.\n\n" <>
              "Configured locales names: #{inspect(Config.requested_locale_names())}\n" <>
              "Gettext locales names:    #{inspect(Config.gettext_locales())}\n" <>
              "Unknown locales names:    " <>
              "#{IO.ANSI.red()}#{inspect(Config.unknown_locale_names())}" <>
              "#{IO.ANSI.default_color()}\n"
    end

    IO.puts(
      "Generating Cldr for #{known_locale_count} " <>
        locale_string <>
        "#{inspect(Config.known_locale_names(), limit: 5)} with " <>
        "a default locale named #{inspect(Config.default_locale())}"
    )

    if known_locale_count > @warn_if_greater_than do
      IO.puts("Please be patient, generating functions for many locales " <> "can take some time")
    end
  end

  def validate_locale do
    quote unquote: false do
      @doc """
      Normalise and validate a locale name.

      ## Arguments

      * `locale` is any valid locale name returned by `Cldr.known_locale_names/0`
        or a `Cldr.LanguageTag` struct returned by `Cldr.Locale.new!/1`

      ## Returns

      * `{:ok, language_tag}`

      * `{:error, reason}`

      ## Examples

          iex> Cldr.validate_locale "en"
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
            variant: nil
          }}


          iex> Cldr.validate_locale Cldr.default_locale
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
            variant: nil
          }}

          iex> Cldr.validate_locale "zzz"
          {:error, {Cldr.UnknownLocaleError, "The locale \\"zzz\\" is not known."}}

      """
      @spec validate_locale(Locale.locale_name() | LanguageTag.t()) ::
              {:ok, String.t()} | {:error, {Exception.t(), String.t()}}

      # Precompile the known locales.  In benchmarking this
      # is 20x faster.
      @language_tags Cldr.Config.all_language_tags()

      for locale_name <- Cldr.Config.known_locale_names() do
        language_tag =
          Map.get(@language_tags, locale_name)
          |> Cldr.Locale.set_gettext_locale_name()

        def validate_locale(unquote(locale_name)) do
          {:ok, unquote(Macro.escape(language_tag))}
        end
      end

      def validate_locale(locale_name) when is_binary(locale_name) do
        case Cldr.Locale.new(locale_name) do
          {:ok, locale} -> validate_locale(locale)
          {:error, reason} -> {:error, reason}
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
    end
  end
end