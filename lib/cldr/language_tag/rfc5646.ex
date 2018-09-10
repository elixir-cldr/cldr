defmodule Cldr.Rfc5646 do
  import NimbleParsec
  import Cldr.Rfc5646.Helpers

  def parse(rule \\ :language_tag, input) when is_atom(rule) and is_binary(input) do
    apply(__MODULE__, rule, [input])
    |> unwrap
  end

  defp unwrap({:ok, acc, "", _, _, _}) when is_list(acc), do: {:ok, acc}
  defp unwrap({:ok, _, rest, _, _, _}), do: {:error, {Cldr.LanguageTag.ParseError, rest}}
  defp unwrap({:error, reason, _rest, _, _, _}), do: {:error, {Cldr.LanguageTag.ParseFailure, reason}}

  # language-tag  = langtag             ; normal language tags
  #               / privateuse          ; private use tag
  #               / grandfathered       ; grandfathered tags

  defparsec :language_tag,
            choice([parsec(:langtag), parsec(:private_use), parsec(:grandfathered)])

  # langtag       = language
  #                 ["-" script]
  #                 ["-" region]
  #                 *("-" variant)
  #                 *("-" extensions)
  #                 ["-" privateuse]
  defparsec :langtag,
            parsec(:language)
            |> optional(ignore(dash()) |> parsec(:script))
            |> optional(ignore(dash()) |> parsec(:region))
            |> repeat(ignore(dash())   |> parsec(:variant))
            |> repeat(ignore(dash())   |> parsec(:extensions)) |> reduce(:collapse_extensions)
            |> optional(ignore(dash()) |> parsec(:private_use))
            |> traverse({:flatten, []})


  defp collapse_extensions(args) do
    extensions =
      args
      |> Enum.filter(fn {x, _y} -> x == :extension; _ -> false end)
      |> Keyword.values
      |> Cldr.Map.merge_map_list

    args
    |> Enum.reject(fn {x, _y} -> x == :extension; _ -> false end)
    |> Keyword.put(:extensions, extensions)
  end

  # language      = 2*3ALPHA            ; shortest ISO 639 code
  #                 ;["-" extlang]      ; sometimes followed by
  #                                     ; extended language subtags
  #                 / 4ALPHA            ; or reserved for future use
  #                 / 5*8ALPHA
  defparsec :language,
            parsec(:iso639)
            # choice([
            #   alpha5_8(),
            #   alpha4(),
            #   parsec(:iso639),
            # ])

  # Don't support extended language for now
  defparsec :iso639,
            alpha2_3() |> unwrap_and_tag(:language)
            # |> optional(ignore(dash()) |> parsec(:extlang))

  # extlang       = 3ALPHA              ; selected ISO 639 codes
  #                 *2("-" 3ALPHA)      ; permanently reserved
  defparsec :alpha3, alpha3()

  defparsec :extlang,
            choice([
              alpha3() |> ignore(dash()) |> parsec(:alpha3) |> ignore(dash()) |> parsec(:alpha3),
              alpha3() |> ignore(dash()) |> parsec(:alpha3),
              alpha3()
            ])
            |> tag(:extended_language)

  # If there is a leading dash in the remaining text then ok
  def fail_if_no_trailing_dash(<<?-, _::binary>>, context, _line, _offset) do
    {[], context}
  end

  # If there is no more text, ok too
  def fail_if_no_trailing_dash(<<"">>, context, _line, _offset) do
    {[], context}
  end

  # We want to fail the :extlang parser, but not error the entire
  # parse operation.  Note that `:fail` is not supported
  def fail_if_no_trailing_dash(_rest, context, _line, _offset) do
    {:fail, context}
  end

  # script        = 4ALPHA
  defparsec :script,
            alpha4()
            |> unwrap_and_tag(:script)

  # region        = 2ALPHA              ; ISO 3166-1 code
  #                 / 3DIGIT
  defparsec :region,
            choice([alpha2(), integer3()])
            |> unwrap_and_tag(:territory)

  # variant       = 5*8alphanum         ; registered variants
  #                 / (DIGIT 3alphanum)
  defparsec :alpha_numeric3, alpha_numeric3()

  defparsec :variant,
            choice([alpha5_8(), digit() |> parsec(:alpha_numeric3)])
            |> reduce({Enum, :join, []})
            |> unwrap_and_tag(:variant)

  # extensions    = locale / transform / extension
  defparsec :extensions,
            choice([parsec(:locale), parsec(:transform), parsec(:extension)])

  # locale        = "u" (1*("-" keyword) / 1*("-" attribute) *("-" keyword))
  defparsec :locale,
            ignore(ascii_string([?u, ?U], 1))
            |> choice([parsec(:attributes) |> parsec(:keywords), parsec(:keywords)])
            |> reduce(:combine_attributes_and_keywords)
            |> unwrap_and_tag(:locale)

  defp combine_attributes_and_keywords([{:attributes, attributes}, %{} = keywords]) do
    Map.put(keywords, :attributes, attributes)
  end

  defp combine_attributes_and_keywords([%{} = other]) do
    other
  end

  # transform     = "t" (1*("-" keyword))
  defparsec :transform,
            ignore(ascii_string([?t, ?T], 1))
            |> ignore(dash()) |> parsec(:keyword) |> reduce(:collapse_keywords)
            |> times(min: 1)
            |> unwrap_and_tag(:transform)

  # extension     = singleton 1*("-" (2*8alphanum))
  defparsec :alpha_numeric2_8, alpha_numeric2_8()

  defparsec :extension,
            parsec(:singleton) |> unwrap_and_tag(:type)
            |> times(ignore(dash()) |> parsec(:alpha_numeric2_8) |> unwrap_and_tag(:attribute), min: 1)
            |> reduce(:collapse_extension)
            |> unwrap_and_tag(:extension)

  defp collapse_extension(args) do
    type = args[:type]
    attributes =
      args
      |> Keyword.delete(:type)
      |> Keyword.values

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
  defparsec :singleton,
    ascii_string([?0..?9, ?a..?s, ?A..?S, ?v..?w, ?V..?W, ?y..?z, ?Y..?Z], 1)

  defparsec :attributes,
    times(ignore(dash()) |> parsec(:attribute), min: 1)
    |> tag(:attributes)

  defparsec :keywords,
            repeat(ignore(dash()) |> parsec(:keyword))
            |> reduce(:collapse_keywords)

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
  defparsec :keyword,
            parsec(:key)
            |> optional(ignore(dash()) |> parsec(:type))

  # key           = 2alphanum
  defparsec :key,
            alpha_numeric2()
            |> unwrap_and_tag(:key)

  # type          = 3*8alphanum *("-" 3*8alphanum)
  defparsec :alpha_numeric3_8, alpha_numeric3_8()

  defparsec :type,
            alpha_numeric3_8()
            |> unwrap_and_tag(:type)
            |> repeat(ignore(dash()) |> parsec(:alpha_numeric3_8) |> unwrap_and_tag(:type))

  # attribute     = 3*8alphanum
  defparsec :attribute,
            alpha_numeric3_8()

  # privateuse    = "x" 1*("-" (1*8alphanum))
  defparsec :alpha_numeric1_8, alpha_numeric1_8()

  defparsec :private_use,
            ignore(ascii_string([?x, ?X], 1))
            |> times(ignore(dash()) |> parsec(:alpha_numeric1_8), min: 1)
            |> tag(:private_use)

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
  defparsec :grandfathered,
            choice([parsec(:irregular), parsec(:regular)])
            |> tag(:grandfathered)

  defparsec :irregular,
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

  defparsec :regular,
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

end