if Code.ensure_loaded?(Plug) and false do
  defmodule Cldr.Plug.Locale do
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
    en-latn-AU           | Language "en" with script "latn" and regional subtag "AU"
    en-AU-u-cu-USD       | Language "en", region subtag "AU", currency unit "USD"
    en-CA-u-cu-USD-hc-12 | Multiple extensions can be specified
    """

    import Plug.Conn

    @language_header "accept-language"

    def init(default \\ Cldr.default_locale()) do
      default
    end

    def call(conn, default) do
      parse_locale(conn.assigns[:locale], conn)
    end

    defp parse_locale(nil, conn) do
      accept_languages = get_req_header(conn, "accept-language")
      conn |> assign(:locale, locale)
    end

    defp parse_locale(_locale, conn) do
      conn
    end
  end
end