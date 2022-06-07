defmodule Cldr.AcceptLanguage.Backend do
  @moduledoc false

  def define_backend_functions(config) do
    quote location: :keep, bind_quoted: [config: Macro.escape(config)] do
      defmodule AcceptLanguage do
        @moduledoc false

        if Cldr.Config.include_module_docs?(config.generate_docs) do
          @moduledoc """
          Parses HTTP `Accept-Language` header values as defined in
          [rfc2616](https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4).

          The Accept-Language request-header field is similar to Accept, but restricts
          the set of natural languages that are preferred as a response to the request.
          Language tags function are provided in `Cldr.LanguageTag`.

          The format of an `Accept-Language` header is as follows in `ABNF` format:

                 Accept-Language = "Accept-Language" ":"
                                   1#( language-range [ ";" "q" "=" qvalue ] )
                 language-range  = ( ( 1*8ALPHA *( "-" 1*8ALPHA ) ) | "*" )

          Each language-range MAY be given an associated quality value which represents an
          estimate of the user's preference for the languages specified by that range. The
          quality value defaults to "q=1". For example,

                 Accept-Language: da, en-gb;q=0.8, en;q=0.7

          would mean: "I prefer Danish, but will accept British English and other types of English."

          """
        end

        alias Cldr.{Locale, LanguageTag}

        @doc """
        Parses an `Accept-Language` header value in its string
        or tokenized form to return a tuple of the form
        `{:ok, [{quality, %Cldr.LanguageTag{}}, ...]}` sorted by quality.

        ## Arguments

        * `accept-language` is any string in the format defined by
          [rfc2616](https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4)

        * `backend` is any module that includes `use Cldr` and therefore
          is a `Cldr` backend module

        ## Returns

        * `{:ok, [{quality, language_tag}, ...]}` or

        * `{:error, {Cldr.AcceptLanguageError, String.t}}`

        If at least one valid language tag is found but errors are also
        detected on one more more tags, an `{ok, list}` tuple is returned
        wuth an error tuple for each invalid tag added at the end of the list.

        ## Example

            iex> Cldr.AcceptLanguage.parse("da,zh-TW;q=0.3", TestBackend.Cldr)
            {:ok,
             [
               {1.0,
                %Cldr.LanguageTag{
                  backend: TestBackend.Cldr,
                  canonical_locale_name: "da",
                  cldr_locale_name: :da,
                  language_subtags: [],
                  extensions: %{},
                  gettext_locale_name: nil,
                  language: "da",
                  locale: %{},
                  private_use: [],
                  rbnf_locale_name: :da,
                  requested_locale_name: "da",
                  script: :Latn,
                  territory: :DK,
                  transform: %{},
                  language_variants: []
                }},
               {0.3,
                %Cldr.LanguageTag{
                  backend: TestBackend.Cldr,
                  canonical_locale_name: "zh-TW",
                  cldr_locale_name: :"zh-Hant",
                  language_subtags: [],
                  extensions: %{},
                  gettext_locale_name: nil,
                  language: "zh",
                  locale: %{},
                  private_use: [],
                  rbnf_locale_name: :"zh-Hant",
                  requested_locale_name: "zh-TW",
                  script: :Hant,
                  territory: :TW,
                  transform: %{},
                  language_variants: []
                }}
             ]}

            iex> #{inspect __MODULE__}.parse("invalid_tag")
            {:error,
             {Cldr.LanguageTag.ParseError,
              "Expected a BCP47 language tag. Could not parse the remaining \\"g\\" starting at position 11"}}

            iex> #{inspect __MODULE__}.parse("da,zh-TW;q=0.3,invalid_tag")
            {:ok,
             [
               {1.0,
                %Cldr.LanguageTag{
                  backend: TestBackend.Cldr,
                  canonical_locale_name: "da",
                  cldr_locale_name: :da,
                  language_subtags: [],
                  extensions: %{},
                  gettext_locale_name: nil,
                  language: "da",
                  locale: %{},
                  private_use: [],
                  rbnf_locale_name: :da,
                  requested_locale_name: "da",
                  script: :Latn,
                  territory: :DK,
                  transform: %{},
                  language_variants: []
                }},
               {0.3,
                %Cldr.LanguageTag{
                  backend: TestBackend.Cldr,
                  canonical_locale_name: "zh-TW",
                  cldr_locale_name: :"zh-Hant",
                  language_subtags: [],
                  extensions: %{},
                  gettext_locale_name: nil,
                  language: "zh",
                  locale: %{},
                  private_use: [],
                  rbnf_locale_name: :"zh-Hant",
                  requested_locale_name: "zh-TW",
                  script: :Hant,
                  territory: :TW,
                  transform: %{},
                  language_variants: []
                }},
               {:error,
                {Cldr.LanguageTag.ParseError,
                 "Expected a BCP47 language tag. Could not parse the remaining \\"g\\" starting at position 11"}}
             ]}

        """
        @doc since: "2.30.0"

        @spec parse([{float(), String.t()}, ...] | String.t()) ::
                {:ok,
                 [
                   {float(), LanguageTag.t()} | {:error, {Cldr.InvalidLanguageTag, String.t()}},
                   ...
                 ]}
                | {:error, {Cldr.AcceptLanguageError, String.t()}}

        def parse(tokens_or_string) do
          Cldr.AcceptLanguage.parse(tokens_or_string, unquote(config.backend))
        end

        @doc """
        Parses an `Accept-Language` header value in its string
        or tokenized form to produce a list of tuples of the form
        `[{quality, %Cldr.LanguageTag{}}, ...]` sorted by quality
        in descending order.

        ## Arguments

        * `accept-language` is any string in the format defined by [rfc2616](https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4)

        ## Returns

        * `{:ok, [{quality, language_tag}, ...]}` or

        * raises a `Cldr.AcceptLanguageError` exception

        If at least one valid language tag is found but errors are also
        detected on one more more tags, an `{ok, list}` tuple is returned
        wuth an error tuple for each invalid tag added at the end of the list.

        ## Example

            iex> #{inspect __MODULE__}.parse!("da,zh-TW;q=0.3")
            [
              {1.0,
               %Cldr.LanguageTag{
                 backend: TestBackend.Cldr,
                 canonical_locale_name: "da",
                 cldr_locale_name: :da,
                 language_subtags: [],
                 extensions: %{},
                 gettext_locale_name: nil,
                 language: "da",
                 locale: %{},
                 private_use: [],
                 rbnf_locale_name: :da,
                 requested_locale_name: "da",
                 script: :Latn,
                 territory: :DK,
                 transform: %{},
                 language_variants: []
               }},
              {0.3,
               %Cldr.LanguageTag{
                 backend: TestBackend.Cldr,
                 canonical_locale_name: "zh-TW",
                 cldr_locale_name: :"zh-Hant",
                 language_subtags: [],
                 extensions: %{},
                 gettext_locale_name: nil,
                 language: "zh",
                 locale: %{},
                 private_use: [],
                 rbnf_locale_name: :"zh-Hant",
                 requested_locale_name: "zh-TW",
                 script: :Hant,
                 territory: :TW,
                 transform: %{},
                 language_variants: []
               }}
            ]

            #{inspect __MODULE__}.parse! "invalid_tag"
            ** (Cldr.AcceptLanguageError) "Expected a BCP47 language tag. Could not parse the remaining "g" starting at position 11
                (ex_cldr) lib/cldr/accept_language.ex:304: Cldr.AcceptLanguage.parse!/1

            iex> #{inspect __MODULE__}.parse!("da,zh-TW;q=0.3,invalid_tag")
            [
              {1.0,
               %Cldr.LanguageTag{
                 backend: TestBackend.Cldr,
                 canonical_locale_name: "da",
                 cldr_locale_name: :da,
                 language_subtags: [],
                 extensions: %{},
                 gettext_locale_name: nil,
                 language: "da",
                 locale: %{},
                 private_use: [],
                 rbnf_locale_name: :da,
                 requested_locale_name: "da",
                 script: :Latn,
                 territory: :DK,
                 transform: %{},
                 language_variants: []
               }},
              {0.3,
               %Cldr.LanguageTag{
                 backend: TestBackend.Cldr,
                 canonical_locale_name: "zh-TW",
                 cldr_locale_name: :"zh-Hant",
                 language_subtags: [],
                 extensions: %{},
                 gettext_locale_name: nil,
                 language: "zh",
                 locale: %{},
                 private_use: [],
                 rbnf_locale_name: :"zh-Hant",
                 requested_locale_name: "zh-TW",
                 script: :Hant,
                 territory: :TW,
                 transform: %{},
                 language_variants: []
               }},
              {:error,
               {Cldr.LanguageTag.ParseError,
                "Expected a BCP47 language tag. Could not parse the remaining \\"g\\" starting at position 11"}}
            ]

        """
        def parse!(accept_language) do
          Cldr.AcceptLanguage.parse!(accept_language, unquote(config.backend))
        end

        @doc """
        Parse an `Accept-Language` string and return the best match for
        a configured `Cldr` locale.

        ## Arguments

        * `accept_langauge` is a string representing an accept language header

        ## Returns

        * `{:ok, language_tag}` or

        * `{:error, reason}`

        ## Examples

            iex> #{inspect __MODULE__}.best_match("da;q=0.1,zh-TW;q=0.3", TestBackend.Cldr)
            {:ok,
             %Cldr.LanguageTag{
               backend: TestBackend.Cldr,
               canonical_locale_name: "zh-TW",
               cldr_locale_name: :"zh-Hant",
               language_subtags: [],
               extensions: %{},
               gettext_locale_name: nil,
               language: "zh",
               locale: %{},
               private_use: [],
               rbnf_locale_name: :"zh-Hant",
               requested_locale_name: "zh-TW",
               script: :Hant,
               territory: :TW,
               transform: %{},
               language_variants: []
             }}

            iex> #{inspect __MODULE__}.best_match("da;q=0.1,zh-TW;q=0.3", TestBackend.Cldr)
            {:ok,
             %Cldr.LanguageTag{
               backend: TestBackend.Cldr,
               canonical_locale_name: "zh-TW",
               cldr_locale_name: :"zh-Hant",
               language_subtags: [],
               extensions: %{},
               gettext_locale_name: nil,
               language: "zh",
               locale: %{},
               private_use: [],
               rbnf_locale_name: :"zh-Hant",
               requested_locale_name: "zh-TW",
               script: :Hant,
               territory: :TW,
               transform: %{},
               language_variants: []
             }}

            iex> #{inspect __MODULE__}.best_match("xx,yy;q=0.3")
            {:error,
             {Cldr.NoMatchingLocale,
              "No configured locale could be matched to \\"xx,yy;q=0.3\\""}}

            iex> #{inspect __MODULE__}.best_match("invalid_tag")
            {:error, {Cldr.LanguageTag.ParseError,
              "Expected a BCP47 language tag. Could not parse the remaining \\"g\\" starting at position 11"}}

        """
        @spec best_match(String.t()) ::
                {:ok, LanguageTag.t()}
                | {:error, {Cldr.AcceptLanguageError | Cldr.NoMatchingLocale, String.t()}}

        def best_match(accept_language) when is_binary(accept_language) do
          Cldr.AcceptLanguage.best_match(accept_language, unquote(config.backend))
        end
      end
    end
  end
end
