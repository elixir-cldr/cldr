if Code.ensure_loaded?(Plug) do
  defmodule Cldr.Plug.AcceptLanguage do
    @moduledoc """
    Parses the accept-language header if one is available and sets
    `conn.private[:cldr_locale]` accordingly.  The locale can
    be later retrieved by `Cldr.Plug.AcceptLanguage.get_cldr_locale/1`

    """

    import Plug.Conn
    require Logger

    @language_header "accept-language"

    def init(options) do
      unless options[:cldr_backend] do
        raise ArgumentError, "A Cldr backend module must be specified under the key :cldr"
      end

      Keyword.get(options, :cldr_backend)
    end

    def call(conn, backend) do
      case get_req_header(conn, @language_header) do
        [accept_language] -> put_private(conn, :cldr_locale, best_match(accept_language, backend))
        [accept_language | _] -> put_private(conn, :cldr_locale, best_match(accept_language, backend))
        [] -> put_private(conn, :cldr_locale, nil)
      end
    end

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
