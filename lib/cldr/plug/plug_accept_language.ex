if Code.ensure_loaded?(Plug) do
  defmodule Cldr.Plug.AcceptLanguage do
    @moduledoc """
    A Phoenix plug that is used to parse the `HTTP Accept-Language header` and
    set the `Cldr` locale appropriately.

    The language accept header [defines](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html)
    a locale as having up to 8 characters, with an optional dash ('-')
    and up to 8 additional characters for the region code.  This plug extends that
    syntax to include a more complete form of a locale string as defined by the
    [Unicode Consortium](http://unicode.org).

    ## Cldr.Plug.Locale support

    `Cldr.Plug.Locale` will support parsing a locale identifier using the
    following formats:

    Locale               | Meaning
    -------------------- | -----------------------
    en                   | Language "en"
    en-GB                | Language "en" with region subtag "GB".
    en-Latn-AU           | Language "en" with script "latn" and regional subtag "AU"
    en-AU-u-cu-usd       | Language "en", region subtag "AU", currency unit "USD"
    en-CA-u-cu-use-hc-12 | Multiple extensions can be specified
    """

    import Plug.Conn
    require Logger

    @language_header "accept-language"

    def init(default) do
      default
    end

    def call(conn, _default) do
      accept_language = get_req_header(conn, @language_header)
      put_private(conn, :cldr_locale, best_match(accept_language))
    end

    def best_match(nil) do
      nil
    end

    def best_match(accept_language) do
      case Cldr.AcceptLanguage.best_match(accept_language) do
        {:ok, locale} ->
          locale
        {:error, {exception, reason}} ->
          Logger.warn "#{exception}: #{reason}"
          nil
      end
    end

    def get_cldr_locale(conn) do
      conn.private[:cldr_locale]
    end
  end
end