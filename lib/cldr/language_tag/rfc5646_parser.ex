defmodule Cldr.Rfc5646.Parser do
  import NimbleParsec
  import Cldr.Rfc5646.Grammar

  alias Cldr.LanguageTag

  def parse(rule \\ :language_tag, input) when is_atom(rule) and is_binary(input) do
    apply(__MODULE__, rule, [input])
    |> unwrap
  end

  defp unwrap({:ok, acc, "", _, _, _}) when is_list(acc), do: {:ok, acc}
  defp unwrap({:ok, _, rest, _, _, _}), do: {:error, {LanguageTag.ParseError, rest}}
  defp unwrap({:error, reason, _rest, _, _, _}), do: {:error, {LanguageTag.ParseFailure, reason}}

  # language-tag  = langtag             ; normal language tags
  #               / privateuse          ; private use tag
  #               / grandfathered       ; grandfathered tags
  defparsec :language_tag,
            choice([langtag(), private_use(), grandfathered()])

end