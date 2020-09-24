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

    @doc false
    def init(options \\ []) do
      Keyword.get_lazy(options, :cldr_backend, &Cldr.default_backend!/0)
    end

    @doc false
    def call(conn, backend) do
      case get_req_header(conn, @language_header) do
        [accept_language] ->
          put_private(conn, :cldr_locale, best_match(accept_language, backend))

        [accept_language | _] ->
          put_private(conn, :cldr_locale, best_match(accept_language, backend))

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

    def best_match(accept_language, backend) do
      case Cldr.AcceptLanguage.best_match(accept_language, backend) do
        {:ok, locale} ->
          locale

        {:error, {exception, reason}} ->
          Logger.warn("#{exception}: #{reason}")
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
