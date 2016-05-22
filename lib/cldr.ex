# During compilation we want to look up the configured locales
# and generate the functions needed for only those locales.

# For any other recognized locale we need a way to either fallback
# to a known locale, or error exit (configurable)
defmodule Cldr.Rbnf do
  def parse(string) do
    :rbnf.string(String.to_charlist(string))
  end
  
  def rbnf_dir do
    Path.join(__DIR__, "/../data/rbnf")
  end
  
  def locale_filename(locale) do
    path = "#{rbnf_dir}/#{locale}.json"
    if File.exists?(path) do
      {:ok, path}
    else
      {:enoent, path}
    end
  end

  def test1(locale \\ "en") do
    with {:ok, filename} <- locale_filename(locale),
         {:ok, json} <- File.read(filename),
         {:ok, %{"rbnf" => %{"rbnf" => rule_sets}}} <- Poison.decode(json) do
      IO.puts "Rule sets: #{inspect Map.keys(rule_sets)}"
    end
  end
end
