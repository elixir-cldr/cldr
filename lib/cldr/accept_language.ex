defmodule Cldr.AcceptLanguage do
  alias Cldr.LanguageTag

  @reg Regex.compile! "[,;]"
  def tokenize(accept_language) do
    accept_language
    |> String.replace(" ", "")
    |> String.downcase
    |> String.split(@reg)
    |> Enum.map(&token_tuple/1)
  end

  def token_tuple(<<"q=", priority :: binary>>) do
    {:priority, String.to_float(priority)}
  end

  def token_tuple(language_tag) do
    {:language_tag, language_tag}
  end

  def parse(tokens) do
    tokens
    |> Enum.reverse
    |> Enum.reduce({[], 0.5}, fn token, {acc, priority} ->
      case token do
        {:priority, priority} -> {acc, priority}
        {:language_tag, tag} -> {[{priority, LanguageTag.parse!(tag)} | acc], priority}
      end
    end)
    |> elem(0)
    |> Enum.sort(fn {priority_1, _}, {priority_2, _} -> priority_1 > priority_2 end)
  end

end