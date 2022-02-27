defmodule Cldr.AcceptLanguage do
  @moduledoc """
  Tokenizer and parser for HTTP `Accept-Language` header values as defined in
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
  alias Cldr.Locale
  alias Cldr.LanguageTag

  @default_quality 1.0
  @low_quality 0.2

  @doc """
  Splits the language ranges for an `Accept-Language` header
  value into tuples `{quality, language}`.

  * `accept-language` is any string in the format defined by [rfc2616](https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4)

  ## Example

      iex> Cldr.AcceptLanguage.tokenize "da,zh-TW;q=0.3"
      [{1.0, "da"}, {0.3, "zh-tw"}]

  """
  @spec tokenize(String.t()) :: [{float(), String.t()}, ...]
  @language_separator ","
  def tokenize(accept_language) do
    accept_language
    |> String.downcase()
    |> remove_whitespace
    |> String.split(@language_separator)
    |> Enum.reject(&is_nil/1)
    |> Enum.reject(&String.starts_with?(&1, "*"))
    |> Enum.map(&token_tuple/1)
  end

  @quality_separator ";q="
  defp token_tuple(language) do
    case String.split(language, @quality_separator) do
      [language, quality] ->
        {parse_quality(quality), language}

      [language] ->
        {@default_quality, language}

      [language | _rest] ->
        {@low_quality, language}
    end
  end

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

      iex> Cldr.AcceptLanguage.parse("invalid_tag", TestBackend.Cldr)
      {:error,
       {Cldr.LanguageTag.ParseError,
        "Expected a BCP47 language tag. Could not parse the remaining \\"g\\" starting at position 11"}}

      iex> Cldr.AcceptLanguage.parse("da,zh-TW;q=0.3,invalid_tag", TestBackend.Cldr)
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
  @spec parse([{float(), String.t()}, ...] | String.t(), Cldr.backend()) ::
          {:ok,
           [
             {float(), LanguageTag.t()} | {:error, {Cldr.InvalidLanguageTag, String.t()}},
             ...
           ]}
          | {:error, {Cldr.AcceptLanguageError, String.t()}}

  def parse(tokens, backend) when is_list(tokens) do
    accept_language =
      tokens
      |> parse_language_tags(backend)
      |> sort_by_quality

    case accept_language do
      [error: reason] ->
        {:error, reason}

      _ ->
        {:ok, accept_language}
    end
  end

  def parse(string, backend) when is_binary(string) do
    string
    |> tokenize
    |> parse(backend)
  end

  @doc """
  Parses an `Accept-Language` header value in its string
  or tokenized form to produce a list of tuples of the form
  `[{quality, %Cldr.LanguageTag{}}, ...]` sorted by quality
  in descending order.

  * `accept-language` is any string in the format defined by [rfc2616](https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4)

  Returns:

  * `{:ok, [{quality, language_tag}, ...]}` or

  * raises a `Cldr.AcceptLanguageError` exception

  If at least one valid language tag is found but errors are also
  detected on one more more tags, an `{ok, list}` tuple is returned
  wuth an error tuple for each invalid tag added at the end of the list.

  ## Example

      iex> Cldr.AcceptLanguage.parse!("da,zh-TW;q=0.3", TestBackend.Cldr)
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

      Cldr.AcceptLanguage.parse! "invalid_tag"
      ** (Cldr.AcceptLanguageError) "Expected a BCP47 language tag. Could not parse the remaining "g" starting at position 11
          (ex_cldr) lib/cldr/accept_language.ex:304: Cldr.AcceptLanguage.parse!/1

      iex> Cldr.AcceptLanguage.parse!("da,zh-TW;q=0.3,invalid_tag", TestBackend.Cldr)
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
  def parse!(accept_language, backend) do
    case parse(accept_language, backend) do
      {:ok, parse_result} -> parse_result
      {:error, {exception, reason}} -> raise exception, reason
    end
  end

  @doc """
  Parse an `Accept-Language` string and return the best match for
  a configured `Cldr` locale.

  * `accept_langauge` is a string representing an accept language header

  Returns:

  * `{:ok, language_tag}` or

  * `{:error, reason}`

  ## Examples

      iex> Cldr.AcceptLanguage.best_match("da;q=0.1,zh-TW;q=0.3", TestBackend.Cldr)
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

      iex> Cldr.AcceptLanguage.best_match("da;q=0.1,zh-TW;q=0.3", TestBackend.Cldr)
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

      iex> Cldr.AcceptLanguage.best_match("xx,yy;q=0.3", TestBackend.Cldr)
      {:error,
       {Cldr.NoMatchingLocale,
        "No configured locale could be matched to \\"xx,yy;q=0.3\\""}}

      iex> Cldr.AcceptLanguage.best_match("invalid_tag", TestBackend.Cldr)
      {:error, {Cldr.LanguageTag.ParseError,
        "Expected a BCP47 language tag. Could not parse the remaining \\"g\\" starting at position 11"}}

  """
  @spec best_match(String.t(), Cldr.backend()) ::
          {:ok, LanguageTag.t()}
          | {:error, {Cldr.AcceptLanguageError | Cldr.NoMatchingLocale, String.t()}}

  def best_match(accept_language, backend) when is_binary(accept_language) do
    with {:ok, languages} <- parse(accept_language, backend) do
      candidates =
        Enum.filter(languages, fn
          {priority, %LanguageTag{cldr_locale_name: locale_name}}
          when is_float(priority) and not is_nil(locale_name) ->
            true

          _ ->
            false
        end)

      case candidates do
        [{_priority, language_tag} | _] ->
          {:ok, language_tag}

        _ ->
          {
            :error,
            {
              Cldr.NoMatchingLocale,
              "No configured locale could be matched to #{inspect(accept_language)}"
            }
          }
      end
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Filters the returned results of `parse/1` to return
  only the error tuples.

  ## Example

      iex> Cldr.AcceptLanguage.parse!("da,zh-TW;q=0.3,invalid_tag", TestBackend.Cldr)
      ...> |> Cldr.AcceptLanguage.errors
      [
        error: {Cldr.LanguageTag.ParseError,
        "Expected a BCP47 language tag. Could not parse the remaining \\"g\\" starting at position 11"}
      ]

  """
  @spec errors([tuple(), ...]) :: [{:error, {Cldr.InvalidLanguageTag, String.t()}}, ...]
  def errors(parse_result) when is_list(parse_result) do
    Enum.filter(parse_result, fn
      {:error, _} -> true
      _ -> false
    end)
  end

  defp parse_quality(quality_string) do
    case Float.parse(quality_string) do
      :error -> @low_quality
      {quality, _} -> quality
    end
  end

  defp parse_language_tags(tokens, backend) do
    Enum.map(tokens, fn {quality, language_tag} ->
      case Locale.canonical_language_tag(language_tag, backend) do
        {:ok, tag} ->
          {quality, tag}

        {:error, reason} ->
          {:error, reason}
      end
    end)
  end

  defp remove_whitespace(accept_language) do
    String.replace(accept_language, " ", "")
  end

  def sort_by_quality(tokens) do
    Enum.sort(tokens, fn
      {:error, _}, {_quality_2, _} -> false
      {_quality_2, _}, {:error, _} -> true
      {quality_1, _}, {quality_2, _} when quality_1 == quality_2 -> true
      {quality_1, _}, {quality_2, _} -> quality_1 > quality_2
    end)
  end
end
