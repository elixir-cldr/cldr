if Code.ensure_loaded?(Plug) do
  defmodule Cldr.Plug.AcceptLanguage do
    @moduledoc """
    Parses the accept-language header if one is available and sets
    `conn.private[:cldr_locale]` accordingly.  The locale can
    be later retrieved by `Cldr.Plug.AcceptLanguage.get_cldr_locale/1`

    ## Options

    * `:cldr_backend` is any backend module. The default
      is `Cldr.default_backend/0`. If no `:cldr_backend`
      option is provided and no default backend is configured
      then an exception will be raised.

    * `:no_match_log_level` determines the logging level for
      the case when no matching locale is configured to meet the users
      request. The default is `:warn`. If set to `nil` then no logging
      is performed.

    ## Example

        # Using a specific backend to validate
        # and match locales
        plug Cldr.Plug.AcceptLanguage,
          cldr_backend: MyApp.Cldr

        # Using the default backend to validate
        # and match locales
        plug Cldr.Plug.AcceptLanguage

    """

    import Plug.Conn
    require Logger

    @language_header "accept-language"
    @default_log_level :warn

    @doc false
    def init(options \\ []) do
      backend = Keyword.get_lazy(options, :cldr_backend, &Cldr.default_backend!/0)
      log_level = Keyword.get(options, :no_match_log_level, @default_log_level)
      %{backend: backend, log_level: log_level}
    end

    @doc false
    def call(conn, options) do
      case get_req_header(conn, @language_header) do
        [accept_language] ->
          put_private(conn, :cldr_locale, best_match(accept_language, options))

        [accept_language | _] ->
          put_private(conn, :cldr_locale, best_match(accept_language, options))

        [] ->
          put_private(conn, :cldr_locale, nil)
      end
    end

    @doc """
    Returns the locale which is the best match for the provided
    accept-language header

    """
    def best_match(nil, _) do
      nil
    end

    def best_match(accept_language, options) do
      case Cldr.AcceptLanguage.best_match(accept_language, options.backend) do
        {:ok, locale} ->
          locale

        {:error, {Cldr.NoMatchingLocale = exception, reason}} ->
          if options.log_level,
            do: Logger.log(options.log_level, "#{inspect(exception)}: #{reason}")

          nil

        {:error, {exception, reason}} ->
          Logger.warn("#{inspect(exception)}: #{reason}")
          nil
      end
    end

    @doc """
    Return the locale set by `Cldr.Plug.AcceptLanguage`

    """
    def get_cldr_locale(conn) do
      conn.private[:cldr_locale]
    end
  end
end
