defmodule Cldr.Rfc5646.Grammar do
  import NimbleParsec
  import Cldr.Rfc5646.Core

  # NimblePersec 0.2 doesn't have this but its used
  # in Cldr
  if !function_exported?(NimbleParsec, :unwrap_and_tag, 3) do
    def unwrap_and_tag(combinator \\ empty(), to_tag, tag) do
      quoted_traverse(combinator, to_tag, {__MODULE__, :__unwrap_and_tag__, [Macro.escape(tag)]})
    end

    def __unwrap_and_tag__(_rest, acc, context, _line, _offset, tag) when is_list(acc) do
      case acc do
        [one] -> {[{tag, one}], context}
        many -> raise "unwrap_and_tag/3 expected a single token, got: #{inspect(many)}"
      end
    end

    def __unwrap_and_tag__(_rest, acc, context, _line, _offset, tag) do
      quoted =
        quote do
          case :lists.reverse(unquote(acc)) do
            [one] -> one
            many -> raise "unwrap_and_tag/3 expected a single token, got: #{inspect(many)}"
          end
        end

      {[{tag, quoted}], context}
    end
  end

  # langtag       = language
  #                 ["-" script]
  #                 ["-" region]
  #                 *("-" variant)
  #                 *("-" extensions)
  #                 ["-" privateuse]
  def langtag do
    language()
    |> optional(ignore(dash()) |> concat(script()))
    |> optional(ignore(dash()) |> concat(region()))
    |> repeat(ignore(dash()) |> concat(variant()))
    |> repeat(ignore(dash()) |> concat(extensions()) |> reduce(:collapse_extensions))
    |> optional(ignore(dash()) |> concat(private_use()))
    |> traverse({:flatten, []})
    |> label("a valid BCP-47 language tag")
  end

  # language      = 2*3ALPHA            ; shortest ISO 639 code
  #                 ;["-" extlang]      ; sometimes followed by
  #                                     ; extended language subtags
  #                 / 4ALPHA            ; or reserved for future use
  #                 / 5*8ALPHA
  def language do
    choice([
      alpha5_8() |> unwrap_and_tag(:language),
      alpha4() |> unwrap_and_tag(:language),
      iso639()
    ])
    |> label("an ISO-639 country code or between 4 and 8 alphabetic characters")
  end

  # Don't support extended language for now
  def iso639 do
    alpha2_3() |> unwrap_and_tag(:language)
    # |> optional(ignore(dash()) |> extlang()))
    |> label("an ISO-639 language code of two or three alphabetic characters")
  end

  # extlang       = 3ALPHA              ; selected ISO 639 codes
  #                 *2("-" 3ALPHA)      ; permanently reserved
  def extlang do
    choice([
      alpha3() |> ignore(dash()) |> concat(alpha3()) |> ignore(dash()) |> concat(alpha3()),
      alpha3() |> ignore(dash()) |> concat(alpha3()),
      alpha3()
    ])
    |> tag(:extended_language)
    |> label("an ISO-639 language code of between one and three three alphabetic characters")
  end

  # script        = 4ALPHA
  def script do
    alpha4()
    |> unwrap_and_tag(:script)
    |> label("a script id of four alphabetic character")
  end

  # region        = 2ALPHA              ; ISO 3166-1 code
  #                 / 3DIGIT
  def region do
    choice([alpha2(), integer3()])
    |> unwrap_and_tag(:territory)
    |> label("a territory code of two alphabetic character ISO-3166-1 code " <>
             "or a three digit UN M.49 code")
  end

  # variant       = 5*8alphanum         ; registered variants
  #                 / (DIGIT 3alphanum)
  def variant do
    choice([alpha5_8(), digit() |> concat(alpha_numeric3())])
    |> reduce({Enum, :join, []})
    |> unwrap_and_tag(:variant)
    |> label("a language variant code of five to eight alphabetic character or " <>
             "a single digit plus three alphanumeric characters")
  end

  # extensions    = locale / transform / extension
  def extensions do
    choice([locale(), transform(), extension()])
  end

  # locale        = "u" (1*("-" keyword) / 1*("-" attribute) *("-" keyword))
  def locale do
    ignore(ascii_string([?u, ?U], 1))
    |> choice([attributes() |> concat(keywords()), keywords()])
    |> reduce(:combine_attributes_and_keywords)
    |> unwrap_and_tag(:locale)
    |> label("a BCP-47 language tag locale extension")
  end

  def combine_attributes_and_keywords([{:attributes, attributes}, %{} = keywords]) do
    Map.put(keywords, :attributes, attributes)
  end

  def combine_attributes_and_keywords([%{} = other]) do
    other
  end

  # transform     = "t" (1*("-" keyword))
  def transform do
    ignore(ascii_string([?t, ?T], 1))
    |> ignore(dash())
    |> concat(keyword())
    |> reduce(:collapse_keywords)
    |> times(min: 1)
    |> unwrap_and_tag(:transform)
    |> label("a BCP-47 language tag transform extension")
  end

  # extension     = singleton 1*("-" (2*8alphanum))
  def extension do
    singleton()
    |> unwrap_and_tag(:type)
    |> times(ignore(dash()) |> concat(alpha_numeric2_8()) |> unwrap_and_tag(:attribute), min: 1)
    |> reduce(:collapse_extension)
    |> unwrap_and_tag(:extension)
    |> label("a valid BCP-47 language tag extension")
  end

  def collapse_extension(args) do
    type = args[:type]

    attributes =
      args
      |> Keyword.delete(:type)
      |> Keyword.values()

    %{type => attributes}
  end

  # ; Single alphanumerics
  #  ; "x" reserved for private use
  #  ; "u" reserved for CLDR use as locale
  #  ; "t" reserved for CLDR use as tranforms
  # singleton     = DIGIT                 ; 0 - 9
  #                 / %x41-53             ; A - S
  #                 / %x56-57             ; V - W
  #                 / %x59-5A             ; Y - Z
  #                 / %x61-73             ; a - s
  #                 / %x76-77             ; v - w
  #                 / %x79-7A             ; y - z
  def singleton do
    ascii_string([?0..?9, ?a..?s, ?A..?S, ?v..?w, ?V..?W, ?y..?z, ?Y..?Z], 1)
    |> label("a single alphanumeric character that is not 'x', 'u' or 't'")
  end

  def attributes do
    times(ignore(dash()) |> concat(attribute()), min: 1)
    |> tag(:attributes)
  end

  def keywords do
    repeat(ignore(dash()) |> concat(keyword()))
    |> reduce(:collapse_keywords)
  end

  # Transform keywords to a map
  def collapse_keywords(args) do
    args
    |> Enum.chunk_every(2)
    |> Enum.into(%{}, fn
      [key: key, type: type] ->
        {key, type}

      [key: key] ->
        {key, nil}
    end)
  end

  # keyword       = key ["-" type]
  def keyword do
    key()
    |> optional(ignore(dash()) |> concat(type()))
    |> label("a valid keyword or keyword-type pair")
  end

  # key           = 2alphanum
  def key do
    alpha_numeric2()
    |> unwrap_and_tag(:key)
    |> label("a key of two alphanumeric characters")
  end

  # type          = 3*8alphanum *("-" 3*8alphanum)
  def type do
    alpha_numeric3_8()
    |> unwrap_and_tag(:type)
    |> repeat(ignore(dash()) |> concat(alpha_numeric3_8()) |> unwrap_and_tag(:type))
    |> label("a type that is one or more three to eight alphanumeric characters separated by a dash")
  end

  # attribute     = 3*8alphanum
  def attribute do
    alpha_numeric3_8()
  end

  # privateuse    = "x" 1*("-" (1*8alphanum))
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
  def grandfathered do
    choice([irregular(), regular()])
    |> tag(:grandfathered)
    |> label("a grandfathered language tag")
  end

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

  def flatten(_rest, args, context, _line, _offset) do
    {List.flatten(args), context}
  end

  def collapse_extensions(args) do
    extensions =
      args
      |> Enum.filter(fn
        {x, _y} -> x == :extension
        _ -> false
      end)
      |> Keyword.values()
      |> Cldr.Map.merge_map_list()

    args
    |> Enum.reject(fn
      {x, _y} -> x == :extension
      _ -> false
    end)
    |> Keyword.put(:extensions, extensions)
  end
end
