if Code.ensure_loaded?(Plug) do
  defmodule Cldr.Plug.AcceptLanguage do
    @moduledoc """
    Parses the accept-language header if one is available and sets
    `conn.private[:cldr_locale]` accordingly.  The locale can
    be later retrieved by `Cldr.Plug.AcceptLanguage.get_cldr_locale/1`

    There are no configuration options for this plug.
    """

    import Plug.Conn
    require Logger

    @language_header "accept-language"

    def init(any) do
      Logger.warn(
        "#{__MODULE__} does not support configuration options. " <>
          "Please remove #{inspect(any)} from the plug invokation."
      )

      init()
    end

    def init do
      nil
    end

    def call(conn, _default) do
      case get_req_header(conn, @language_header) do
        [accept_language] -> put_private(conn, :cldr_locale, best_match(accept_language))
        [accept_language | _] -> put_private(conn, :cldr_locale, best_match(accept_language))
        [] -> put_private(conn, :cldr_locale, nil)
      end
    end

    def best_match(nil) do
      nil
    end

    def best_match(accept_language) do
      case Cldr.AcceptLanguage.best_match(accept_language) do
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
