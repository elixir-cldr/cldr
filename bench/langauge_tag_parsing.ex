defmodule Cldr.Bench.LanguageTag do
  @path "bench/language_tag.benchee"
  def run do
    version = Application.spec(:ex_cldr) |> Keyword.get(:vsn)

    Benchee.run(%{
      "parse language tag in CLDR #{version}" => fn ->
        Cldr.LanguageTag.parse("en-Latn-US-u-ca-gregory-cu-usd")
       end,
    }, [save: [path: @path, tag: version]])
  end

  def compare do
    Benchee.run(%{}, load: @path)
  end
end