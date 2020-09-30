defmodule Cldr.Rfc5646.Parser do
  @moduledoc false

  alias Cldr.LanguageTag

  import Cldr.Rfc5646.Helpers

  def parse(rule \\ :language_tag, input) when is_atom(rule) and is_binary(input) do
    apply(__MODULE__, rule, [input])
    |> unwrap
  end

  defp unwrap({:ok, acc, "", _, _, _}) when is_list(acc),
    do: {:ok, acc}

  defp unwrap({:error, <<first::binary-size(1), reason::binary>>, rest, _, _, offset}),
    do:
      {:error,
       {LanguageTag.ParseError,
        "#{String.capitalize(first)}#{reason}. Could not parse the remaining #{inspect(rest)} " <>
          "starting at position #{offset + 1}"}}

  # language-tag  = langtag             ; normal language tags
  #               / privateuse          ; private use tag
  #               / grandfathered       ; grandfathered tags

  import NimbleParsec
  import Cldr.Rfc5646.Grammar

  defparsec :language_tag,
            choice([
              langtag(),
              private_use(),
              grandfathered()
            ])
            |> eos()
            |> label("a BCP47 language tag")

  def error_on_remaining("", context, _line, _offset) do
    {[], context}
  end

  def error_on_remaining(_rest, _context, _line, _offset) do
    {:error, "invalid language tag"}
  end
end
