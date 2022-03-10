if Code.ensure_loaded?(NimbleParsec) do
  defmodule Cldr.Rfc5646.Grammar do
    @moduledoc false

    import NimbleParsec
    import Cldr.Rfc5646.Core

    # langtag       = language
    #                 ["-" script]
    #                 ["-" region]
    #                 *("-" variant)
    #                 *("-" extensions)
    @spec langtag :: NimbleParsec.t()
    def langtag do
      basic_langtag()
      |> repeat(ignore(dash()) |> concat(extensions()))
      |> reduce(:collapse_extensions)
      |> optional(ignore(dash()) |> concat(private_use()))
      |> post_traverse({:flatten, []})
      |> label("a valid BCP-47 language tag")
    end

    def basic_langtag do
      language()
      |> optional(ignore(dash()) |> concat(script()))
      |> optional(ignore(dash()) |> concat(region()))
      |> repeat(ignore(dash()) |> concat(variant()))
      |> reduce(:collapse_variants)
    end

    # language      = 2*3ALPHA            ; shortest ISO 639 code
    #                 ;["-" extlang]      ; sometimes followed by
    #                                     ; extended language subtags
    #                 / 4ALPHA            ; or reserved for future use
    #                 / 5*8ALPHA
    @spec language :: NimbleParsec.t()
    def language do
      choice([
        alpha5_8() |> unwrap_and_tag(:language),
        alpha4() |> unwrap_and_tag(:language),
        iso639()
      ])
      |> label("an ISO-639 country code or between 4 and 8 alphabetic characters")
    end

    # Don't support extended language for now
    @spec iso639 :: NimbleParsec.t()
    def iso639 do
      alpha2_3()
      |> unwrap_and_tag(:language)
      |> optional(ignore(dash()) |> concat(extlangs()))
      |> label("an ISO-639 language code of two or three alphabetic characters")
    end

    # extlang       = 3ALPHA              ; selected ISO 639 codes
    #                 *2("-" 3ALPHA)      ; permanently reserved
    @spec extlangs :: NimbleParsec.t()
    def extlangs do
      lookahead_not(variant())
      |> choice([
        script(),
        extlang()
        |> ignore(dash())
        |> concat(extlang())
        |> ignore(dash())
        |> concat(extlang())
        |> tag(:language_subtags)
        |> ignore(dash())
        |> concat(script()),
        extlang()
        |> ignore(dash())
        |> concat(extlang())
        |> tag(:language_subtags)
        |> ignore(dash())
        |> concat(script()),
        extlang() |> ignore(dash()) |> tag(:language_subtags) |> concat(script()),
        extlang() |> ignore(dash()) |> concat(extlang()) |> ignore(dash()) |> concat(extlang()),
        extlang() |> ignore(dash()) |> concat(extlang()),
        extlang() |> tag(:language_subtags)
      ])
      |> label("an ISO-639 language code of between one and three three alphabetic characters")
    end

    @spec extlang :: NimbleParsec.t()
    def extlang do
      alpha3()
    end

    # script        = 4ALPHA
    @spec script :: NimbleParsec.t()
    def script do
      lookahead_not(variant())
      |> concat(alpha4())
      |> unwrap_and_tag(:script)
      |> label("a script id of four alphabetic character")
    end

    # region        = 2ALPHA              ; ISO 3166-1 code
    #                 / 3DIGIT
    @spec region :: NimbleParsec.t()
    def region do
      lookahead_not(variant())
      |> choice([alpha2(), integer3()])
      |> unwrap_and_tag(:territory)
      |> label(
        "a territory code of two alphabetic character ISO-3166-1 code " <>
          "or a three digit UN M.49 code"
      )
    end

    # variant       = 5*8alphanum         ; registered variants
    #                 / (DIGIT 3alphanum)
    @spec variant :: NimbleParsec.t()
    def variant do
      choice([
        alpha_numeric5_8(),
        digit() |> concat(alpha_numeric3()) |> reduce({Enum, :join, []})
      ])
      |> unwrap_and_tag(:language_variant)
      |> label(
        "a language variant code of five to eight alphabetic character or " <>
          "a single digit plus three alphanumeric characters"
      )
    end

    # extensions    = locale / transform / extension
    @spec extensions :: NimbleParsec.t()
    def extensions do
      choice([locale(), transform(), extension()])
    end

    # locale        = "u" (1*("-" keyword) / 1*("-" attribute) *("-" keyword))
    @spec locale :: NimbleParsec.t()
    def locale do
      ignore(ascii_string([?u, ?U], 1))
      |> choice([attributes() |> concat(keywords()), keywords()])
      |> reduce(:combine_attributes_and_keywords)
      |> unwrap_and_tag(:locale)
      |> label("a BCP-47 language tag locale extension")
    end

    # transform     = "t" (1*("-" keyword))
    @spec transform :: NimbleParsec.t()
    def transform do
      ignore(ascii_string([?t, ?T], 1))
      |> optional(ignore(dash()) |> concat(basic_langtag()))
      |> concat(keywords())
      |> reduce(:merge_langtag_and_transform)
      |> unwrap_and_tag(:transform)
      |> label("a BCP-47 language tag transform extension")
    end

    # extension     = singleton 1*("-" (2*8alphanum))
    @spec extension :: NimbleParsec.t()
    def extension do
      singleton()
      |> unwrap_and_tag(:type)
      |> times(ignore(dash()) |> concat(alpha_numeric2_8()) |> unwrap_and_tag(:attribute), min: 1)
      |> reduce(:collapse_extension)
      |> unwrap_and_tag(:extension)
      |> label("a valid BCP-47 language tag extension")
    end

    # ; Single alphanumerics
    #  ; "x" reserved for private use
    #  ; "u" reserved for CLDR use as locale
    #  ; "t" reserved for CLDR use as transforms
    # singleton     = DIGIT                 ; 0 - 9
    #                 / %x41-53             ; A - S
    #                 / %x56-57             ; V - W
    #                 / %x59-5A             ; Y - Z
    #                 / %x61-73             ; a - s
    #                 / %x76-77             ; v - w
    #                 / %x79-7A             ; y - z
    @spec singleton :: NimbleParsec.t()
    def singleton do
      ascii_string([?0..?9, ?a..?s, ?A..?S, ?v..?w, ?V..?W, ?y..?z, ?Y..?Z], 1)
      |> label("a single alphanumeric character that is not 'x', 'u' or 't'")
    end

    @spec attributes :: NimbleParsec.t()
    def attributes do
      times(ignore(dash()) |> concat(attribute()), min: 1)
      |> tag(:attributes)
    end

    @spec keywords :: NimbleParsec.t()
    def keywords do
      repeat(ignore(dash()) |> concat(keyword()))
      |> reduce(:collapse_keywords)
    end

    # keyword       = key ["-" type]
    @spec keyword :: NimbleParsec.t()
    def keyword do
      key()
      |> optional(ignore(dash()) |> concat(type()))

      # |> label("a valid keyword or keyword-type pair")
    end

    # key           = 2alphanum
    @spec key :: NimbleParsec.t()
    def key do
      alpha_numeric2()
      |> unwrap_and_tag(:key)
      |> label("a key of two alphanumeric characters")
    end

    # type          = 3*8alphanum *("-" 3*8alphanum)
    @spec type :: NimbleParsec.t()
    def type do
      alpha_numeric3_8()
      |> unwrap_and_tag(:type)
      |> repeat(ignore(dash()) |> concat(alpha_numeric3_8()) |> unwrap_and_tag(:type))
      |> label(
        "a type that is one or more three to eight alphanumeric characters separated by a dash"
      )
    end

    # attribute     = 3*8alphanum
    @spec attribute :: NimbleParsec.t()
    def attribute do
      alpha_numeric3_8()
    end

    # privateuse    = "x" 1*("-" (1*8alphanum))
    @spec private_use :: NimbleParsec.t()
    def private_use do
      ignore(ascii_string([?x, ?X], 1))
      |> times(ignore(dash()) |> concat(alpha_numeric1_8()), min: 1)
      |> tag(:private_use)
      |> label("an 'x' representing a private use tag")
    end

    # grandfathered = irregular           ; non-redundant tags registered
    #               / regular             ; during the RFC 3066 era
    #
    # irregular     = "en-GB-oed"         ; irregular tags do not match
    #               / "i-ami"             ; the 'langtag' production and
    #               / "i-bnn"             ; would not otherwise be
    #               / "i-default"         ; considered 'well-formed'
    #               / "i-enochian"        ; These tags are all valid,
    #               / "i-hak"             ; but most are deprecated
    #               / "i-klingon"         ; in favor of more modern
    #               / "i-lux"             ; subtags or subtag
    #               / "i-mingo"           ; combination
    #               / "i-navajo"
    #               / "i-pwn"
    #               / "i-tao"
    #               / "i-tay"
    #               / "i-tsu"
    #               / "sgn-BE-FR"
    #               / "sgn-BE-NL"
    #               / "sgn-CH-DE"
    #
    # regular       = "art-lojban"        ; these tags match the 'langtag'
    #               / "cel-gaulish"       ; production, but their subtags
    #               / "no-bok"            ; are not extended language
    #               / "no-nyn"            ; or variant subtags: their meaning
    #               / "zh-guoyu"          ; is defined by their registration
    #               / "zh-hakka"          ; and all of these are deprecated
    #               / "zh-min"            ; in favor of a more modern
    #               / "zh-min-nan"        ; subtag or sequence of subtags
    #               / "zh-xiang"
    @spec grandfathered :: NimbleParsec.t()
    def grandfathered do
      choice([irregular(), regular()])
      |> tag(:grandfathered)
      |> label("a grandfathered language tag")
    end

    @spec irregular :: NimbleParsec.t()
    def irregular do
      choice([
        string("en-GB-oed"),
        string("i-ami"),
        string("i-bnn"),
        string("i-default"),
        string("i-enochian"),
        string("i-hak"),
        string("i-klingon"),
        string("i-lux"),
        string("i-mingo"),
        string("i-navajo"),
        string("i-pwn"),
        string("i-tao"),
        string("i-tay"),
        string("i-tsu"),
        string("sgn-BE-FR"),
        string("sgn-BE-NL"),
        string("sgn-CH-DE")
      ])
      |> unwrap_and_tag(:irregular)
      |> label("one of the irregular language tags in BCP-47")
    end

    @spec regular :: NimbleParsec.t()
    def regular do
      choice([
        string("art-lojban"),
        string("cel-gaulish"),
        string("no-bok"),
        string("no-nyn"),
        string("zh-guoyu"),
        string("zh-hakka"),
        string("zh-min"),
        string("zh-min-nan"),
        string("zh-xiang")
      ])
      |> unwrap_and_tag(:regular)
      |> label("one of the regular language tags in BCP-47")
    end
  end
end
