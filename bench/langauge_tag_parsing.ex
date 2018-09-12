defmodule Cldr.Bench.LanguageTag do
  @path "bench/results/language_tag"

  def run do
    version =
      :ex_cldr
      |> Application.spec
      |> Keyword.get(:vsn)

    Benchee.run(%{
      "parse language tag in CLDR #{version}" => fn ->
        Cldr.LanguageTag.parse("en-Latn-US-u-ca-gregory-cu-usd")
       end,
    }, save: [path: path(version), tag: version])
  end

  def compare do
    Benchee.run(%{}, load: "#{@path}*")
  end

  defp path(version) do
    "#{@path}_#{version}.benchee"
  end
end