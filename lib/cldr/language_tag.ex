defmodule Cldr.LanguageTag do
  @moduledoc """
  Represents a language tag as defined in [rfc5646](https://tools.ietf.org/html/rfc5646)
  with extensions "u" and "t" as defined in [BCP 47](https://tools.ietf.org/html/bcp47).

  Language tags are used to help identify languages, whether spoken,
  written, signed, or otherwise signaled, for the purpose of
  communication.  This includes constructed and artificial languages
  but excludes languages not intended primarily for human
  communication, such as programming languages.

  ## Syntax

  A language tag is composed from a sequence of one or more "subtags",
  each of which refines or narrows the range of language identified by
  the overall tag.  Subtags, in turn, are a sequence of alphanumeric
  characters (letters and digits), distinguished and separated from
  other subtags in a tag by a hyphen ("-", [Unicode] U+002D).

  There are different types of subtag, each of which is distinguished
  by length, position in the tag, and content: each subtag's type can
  be recognized solely by these features.  This makes it possible to
  extract and assign some semantic information to the subtags, even if
  the specific subtag values are not recognized.  Thus, a language tag
  processor need not have a list of valid tags or subtags (that is, a
  copy of some version of the IANA Language Subtag Registry) in order
  to perform common searching and matching operations.  The only
  exceptions to this ability to infer meaning from subtag structure are
  the grandfathered tags listed in the productions 'regular' and
  'irregular' below.  These tags were registered under [RFC3066] and
  are a fixed list that can never change.

  The syntax of the language tag in ABNF is:

   Language-Tag  = langtag             ; normal language tags
                 / privateuse          ; private use tag
                 / grandfathered       ; grandfathered tags

   langtag       = language
                   ["-" script]
                   ["-" region]
                   *("-" variant)
                   *("-" extension)
                   ["-" privateuse]

   language      = 2*3ALPHA            ; shortest ISO 639 code
                   ["-" extlang]       ; sometimes followed by
                                       ; extended language subtags
                 / 4ALPHA              ; or reserved for future use
                 / 5*8ALPHA            ; or registered language subtag

   extlang       = 3ALPHA              ; selected ISO 639 codes
                   *2("-" 3ALPHA)      ; permanently reserved

   script        = 4ALPHA              ; ISO 15924 code

   region        = 2ALPHA              ; ISO 3166-1 code
                 / 3DIGIT              ; UN M.49 code

   variant       = 5*8alphanum         ; registered variants
                 / (DIGIT 3alphanum)

   extension     = singleton 1*("-" (2*8alphanum))

                                       ; Single alphanumerics
                                       ; "x" reserved for private use
   singleton     = DIGIT               ; 0 - 9
                 / %x41-57             ; A - W
                 / %x59-5A             ; Y - Z
                 / %x61-77             ; a - w
                 / %x79-7A             ; y - z

   privateuse    = "x" 1*("-" (1*8alphanum))

   grandfathered = irregular           ; non-redundant tags registered
                 / regular             ; during the RFC 3066 era

   irregular     = "en-GB-oed"         ; irregular tags do not match
                 / "i-ami"             ; the 'langtag' production and
                 / "i-bnn"             ; would not otherwise be
                 / "i-default"         ; considered 'well-formed'
                 / "i-enochian"        ; These tags are all valid,
                 / "i-hak"             ; but most are deprecated
                 / "i-klingon"         ; in favor of more modern
                 / "i-lux"             ; subtags or subtag
                 / "i-mingo"           ; combination
                 / "i-navajo"
                 / "i-pwn"
                 / "i-tao"
                 / "i-tay"
                 / "i-tsu"
                 / "sgn-BE-FR"
                 / "sgn-BE-NL"
                 / "sgn-CH-DE"

   regular       = "art-lojban"        ; these tags match the 'langtag'
                 / "cel-gaulish"       ; production, but their subtags
                 / "no-bok"            ; are not extended language
                 / "no-nyn"            ; or variant subtags: their meaning
                 / "zh-guoyu"          ; is defined by their registration
                 / "zh-hakka"          ; and all of these are deprecated
                 / "zh-min"            ; in favor of a more modern
                 / "zh-min-nan"        ; subtag or sequence of subtags
                 / "zh-xiang"

   alphanum      = (ALPHA / DIGIT)     ; letters and numbers

  All subtags have a maximum length of eight characters.  Whitespace is
  not permitted in a language tag.  There is a subtlety in the ABNF
  production 'variant': a variant starting with a digit has a minimum
  length of four characters, while those starting with a letter have a
  minimum length of five characters.

  ## Unicode BCP 47 Extension type "u" - Locale

  Extension | Description                      | Examples
  +-------+ | -------------------------------  | ---------
  ca        | Calendar type                    | buddhist, chinese, gregory
  cf        | Currency format style            | standard, account
  co        | Collation type                   | standard, search, phonetic, pinyin
  cu        | Currency type                    | ISO4217 code like "USD", "EUR"
  fw        | First day of the week identifier | sun, mon, tue, wed, ...
  hc        | Hour cycle identifier            | h12, h23, h11, h24
  lb        | Line break style identifier      | strict, normal, loose
  lw        | Word break identifier            | normal, breakall, keepall, phrase
  ms        | Measurement system identifier    | metric, ussystem, uksystem
  mu        | Measurement unit override        | celsius, fahrenhe, kelvin which overrides the ms key
  nu        | Number system identifier         | arabext, armnlow, roman, tamldec
  rg        | Region override                  | The value is a unicode_region_subtag for a regular region (not a macroregion), suffixed by "ZZZZ"
  sd        | Subdivision identifier           | A unicode_subdivision_id, which is a unicode_region_subtagconcatenated with a unicode_subdivision_suffix.
  ss        | Break suppressions identifier    | none, standard
  tz        | Timezone identifier              | Short identifiers defined in terms of a TZ time zone database
  va        | Common variant type              | POSIX style locale variant

  ## Unicode BCP 47 Extension type "t" - Transforms

  Extension | Description
  +-------+ | -----------------------------------------
  mo        | Transform extension mechanism: to reference an authority or rules for a type of transformation
  s0        | Transform source: for non-languages/scripts, such as fullwidth-halfwidth conversion.
  d0        | Transform sdestination: for non-languages/scripts, such as fullwidth-halfwidth conversion.
  i0        | Input Method Engine transform
  k0        | Keyboard transform
  t0        | Machine Translation: Used to indicate content that has been machine translated
  h0        | Hybrid Locale Identifiers: h0 with the value 'hybrid' indicates that the -t- value is a language that is mixed into the main language tag to form a hybrid
  x0        | Private use transform

  Extensions are formatted by specifying keyword pairs after an extension
  separator. The example `de-DE-u-co-phonebk` specifies German as spoken in
  Germany with a collation of `phonebk`.  Another example, "en-latn-AU-u-cf-account"
  represents English as spoken in Australia, with the number system "latn" but
  formatting currencies with the "accounting" style.
  """
  import Kernel, except: [to_string: 1]

  alias Cldr.Locale
  alias Cldr.LanguageTag.{Parser, U, T}

  if Code.ensure_loaded?(Jason) do
    @derive Jason.Encoder
  end

  defstruct language: nil,
            language_subtags: [],
            script: nil,
            territory: nil,
            language_variants: [],
            locale: %{},
            transform: %{},
            extensions: %{},
            private_use: [],
            requested_locale_name: nil,
            canonical_locale_name: nil,
            cldr_locale_name: nil,
            rbnf_locale_name: nil,
            gettext_locale_name: nil,
            backend: nil

  @type t :: %__MODULE__{
          language: Locale.language(),
          language_subtags: [String.t()],
          script: Locale.script(),
          territory: Locale.territory_code(),
          language_variants: [String.t()],
          locale: U.t() | %{},
          transform: T.t() | %{},
          extensions: map(),
          private_use: [String.t()],
          requested_locale_name: String.t(),
          canonical_locale_name: String.t(),
          cldr_locale_name: Locale.locale_name(),
          rbnf_locale_name: Locale.locale_name(),
          gettext_locale_name: String.t() | nil,
          backend: Cldr.backend()
        }

  @doc """
  Parse a locale name into a `t:Cldr.LanguageTag` struct.

  ## Arguments

  * `locale_name` is any [BCP 47](https://tools.ietf.org/search/bcp47)
    string.

  ## Returns

  * `{:ok, t:Cldr.LanguageTag}` or

  * `{:error, reason}`

  """
  @spec parse(String.t()) :: {:ok, t()} | {:error, {module(), String.t()}}
  def parse(locale_name) when is_binary(locale_name) do
    Parser.parse(locale_name)
  end

  @doc """
  Parse a locale name into a `Cldr.LangaugeTag` struct and raises on error

  ## Arguments

  * `locale_name` is any [BCP 47](https://tools.ietf.org/search/bcp47)
    string.

  ## Returns

  * `t:Cldr.LanguageTag` or

  * raises an exception

  """
  @spec parse!(String.t()) :: t() | none()
  def parse!(locale_string) when is_binary(locale_string) do
    Parser.parse!(locale_string)
  end

  @doc """
  Reconstitute a textual language tag from a
  LanguageTag that is suitable to pass to a collator.

  Note that this function will always calculate the
  canonical locale name. `Kernel.to_string/1` will
  return the pre-calculated canonical locale name and
  is to be preferred.

  ## Arguments

  * `locale` is a `Cldr.LanguageTag` struct returned by `Cldr.Locale.new!/2`

  ## Returns

  * A formatted string representation of the language tag that is also
    parseable back into a `Cldr.LanguageTag.t()`

  ## Examples

      iex> {:ok, locale} = Cldr.validate_locale "en-US", MyApp.Cldr
      iex> Cldr.LanguageTag.to_string(locale)
      "en-Latn-US"

      iex> {:ok, locale} = Cldr.validate_locale "en-US-u-co-phonebk-nu-arab", MyApp.Cldr
      iex> Cldr.LanguageTag.to_string(locale)
      "en-Latn-US-u-co-phonebk-nu-arab"

  """
  @spec to_string(t) :: String.t()
  def to_string(%__MODULE__{} = language_tag) do
    basic_tag =
      [
        language_tag.language,
        language_tag.language_subtags,
        language_tag.script,
        language_tag.territory,
        language_tag.language_variants
      ]
      |> Enum.map(&Cldr.LanguageTag.Chars.to_string/1)
      |> Enum.reject(&empty?/1)

    extensions =
      [{"t", language_tag.transform},{"u", language_tag.locale}]
      |> Kernel.++(Map.to_list(language_tag.extensions))
      |> Enum.map(&Cldr.LanguageTag.Chars.to_string/1)
      |> Enum.reject(&empty?/1)
      |> Enum.map(&join/1)

    private_use =
      format_private_use(language_tag.private_use)

    basic_tag ++ extensions ++ [private_use]
    |> Enum.reject(&empty?/1)
    |> Enum.join("-")
  end

  defp join({k, v}), do: "#{k}-#{v}"

  defp format_private_use([]) do
    []
  end

  defp format_private_use(private_use) do
    "x-" <> Enum.join(private_use, "-")
  end

  @doc false
  def empty?({_k, ""}), do: true
  def empty?(""), do: true
  def empty?(nil), do: true
  def empty?([]), do: true
  def empty?(_other), do: false

  # This is primarily to support
  # implementing canonical locale names
  defimpl Cldr.LanguageTag.Chars, for: Map do
    def to_string(%{}) do
      ""
    end
  end

  defimpl Cldr.LanguageTag.Chars, for: Tuple do
    def to_string({k, v}) do
      {k, Cldr.LanguageTag.Chars.to_string(v)}
    end
  end

  defimpl Cldr.LanguageTag.Chars, for: Atom do
    def to_string(nil) do
      ""
    end

    def to_string(atom) do
      Atom.to_string(atom)
    end
  end

  defimpl Cldr.LanguageTag.Chars, for: BitString do
    def to_string(nil) do
      ""
    end

    def to_string(string) do
      string
    end
  end

  defimpl Cldr.LanguageTag.Chars, for: List do
    def to_string([]) do
      ""
    end

    def to_string(list) do
      list
      |> Enum.sort()
      |> Enum.join("-")
    end
  end

  defimpl String.Chars do
    def to_string(language_tag) do
      language_tag.canonical_locale_name
    end
  end

  defimpl Inspect do
    def inspect(%Cldr.LanguageTag{requested_locale_name: nil} = l, _opts) do
      locale_name =
        Cldr.Locale.locale_name_from(l.language, l.script, l.territory, l.language_variants)

      "#Cldr.LanguageTag<" <> locale_name <> " [tokenized]>"
    end

    def inspect(%Cldr.LanguageTag{canonical_locale_name: nil} = language_tag, _opts) do
      "#Cldr.LanguageTag<" <> language_tag.requested_locale_name <> " [parsed]>"
    end

    def inspect(%Cldr.LanguageTag{cldr_locale_name: nil} = language_tag, _opts) do
      "#Cldr.LanguageTag<" <> language_tag.canonical_locale_name <> " [canonical]>"
    end

    def inspect(%Cldr.LanguageTag{} = language_tag, _opts) do
      "#Cldr.LanguageTag<" <> language_tag.canonical_locale_name <> " [validated]>"
    end
  end
end
