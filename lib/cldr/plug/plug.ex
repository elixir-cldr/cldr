if Code.ensure_loaded?(Plug) do
  defmodule Cldr.Plug.Locale do
    @moduledoc """
    A Phoenix plug that is used to parse the `HTTP Accept-Language header` and
    set the `Cldr` locale appropriately.

    The language accept header [defines](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html)
    a locale as having up to 8 characters, with an optional dash ('-')
    and up to 8 additional characters for the region code.  This plug extends that
    syntax to include a more complete form of a locale string as defined by the
    [Unicode Consortium](http://unicode.org).

    The Unicode consortium [defines](http://unicode.org/reports/tr35/#Identifiers)
    a format that can include locale extension "u" and "t".  `Cldr.Plug.Locale`
    supports only the "u" extensions.

    ## Unicode BCP 47 Extensions type "u"

    Extension | Description                      | Examples
    --------- | -------------------------------  | ---------
    ca        | Calendar type                    | buddhist, chinese, gregory
    cf        | Currency format style            | standard, account
    co        | Collation type                   | standard, search, phonetic, pinyin
    cu        | Currency type                    | ISO4217 code like "USD", "EUR"
    fw        | First day of the week identifier | sun, mon, tue, wed, ...
    hc        | Hour cycle identifier            | h12, h23, h11, h24
    lb        | Line break style identifier      | strict, normal, loose
    lw        | Word break identifier            | normal, breakall, keepall
    ms        | Measurement system identifier    | metric, ussystem, uksystem
    nu        | Number system identifier         | arabext, armnlow, roman, tamldec
    rg        | Region override                  | The value is a unicode_region_subtag for a regular region (not a macroregion), suffixed by "ZZZZ"
    sd        | Subdivision identifier           | A unicode_subdivision_id, which is a unicode_region_subtagconcatenated with a unicode_subdivision_suffix.
    ss        | Break supressions identifier     | none, standard
    tz        | Timezone idenfitifier            | Short identifiers defined in terms of a TZ time zone database
    va        | Common variant type              | POSIX style locale variant

    Extensions are formatted by specifying keyword pairs after an extension
    separator. The example `de-DE-u-co-phonebk` specifies German as spoken in
    Germany with a collation of `phonebk`.  Another example, "en-latn-AU-u-cf-account"
    represents English as spoken in Australia, with the number system "latn" but
    formatting currencies with the "accounting" style.

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