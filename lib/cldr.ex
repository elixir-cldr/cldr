# During compilation we want to look up the configured locales
# and generate the functions needed for only those locales.

# For any other recognized locale we need a way to either fallback
# to a known locale, or error exit (configurable)
defmodule Cldr.Rbnf do
  import Xml
  alias Cldr.Rbnf.Rule
  defdelegate parse(filename), to: Xml
  @rbnf_dir Path.join(__DIR__, "/../data/common/rbnf")
  
  @spec rbnf_dir :: String.t
  def rbnf_dir do
    @rbnf_dir
  end
  
  @spec locale_path(binary) :: String.t
  def locale_path(locale) when is_binary(locale) do
    Path.join(rbnf_dir(), "/#{locale}.xml")
  end
  
  @doc """
  Returns a boolean identifying if the specified locale
  is available in rbnf
  """
  @spec locale_exists?(String.t) :: boolean
  def locale_exists?(locale) when is_binary(locale) do
    locale_path(locale)
    |> File.exists?
  end
  
  @doc """
  Returns a list of the configured locales for rbnf
  
  Locales are configured in `config.exs` 
  
      config :cldr,
        locales: ["en", "fr"]
        
  It's also possible to use the locales from a Gettext
  configuration:
  
      config :cldr,
        gettext: App.Gettext
  """
  @spec configured_locales :: [String.t]
  def configured_locales do
    Application.get_env(:cldr, :locales)
  end
  
  {:ok, files} = File.ls(@rbnf_dir)
  @locales Enum.map(files, &Path.basename(&1, ".xml"))
  
  @doc """
  Returns a list of the locales defined in rbnf
  """
  @spec known_locales :: [String.t]
  def known_locales do
    @locales
  end
  
  @spec rulegroups(Xml.xml_node, String.t) :: [String.t]
  def rulegroups(xml, path \\ "//rulesetGrouping") do
    Enum.map(all(xml, path), fn(node) -> attr(node, "type") end)
  end
  
  @spec rulesets(Xml.xml_node, binary) :: list([type: String.t, access: String.t])
  def rulesets(xml, rulegroup) do
    path = "//rulesetGrouping[@type='#{rulegroup}']/ruleset"
    Enum.map(all(xml, path), fn(node) -> [attr(node, "type"), attr(node, "access") || "public"] end)
  end
  
  @spec rules(Xml.xml_node, String.t, String.t) :: [%Rule{}]
  def rules(xml, rulegroup, ruleset) do
    path = "//rulesetGrouping[@type='#{rulegroup}']/ruleset[@type='#{ruleset}']/rbnfrule"
    Enum.map(all(xml, path), fn(node) -> 
      %Rule{rule: attr(node, "value"), radix: attr(node, "radix"), definition: text(node)}
    end)
    |> set_range
  end
  
  # If the current rule is numeric and the next rule is numeric then
  # the next rules value determines the upper bound of the validity
  # of the current rule.
  #
  # ie.   "0": "one;"
  #       "10": "ten;"
  #
  # Means that rule "0" is applied for values up to but not including "10"
  defp set_range([rule | [next_rule | rest]]) do
    [%Rule{rule | :range => range_from_next_rule(rule.rule, next_rule.rule)}] ++ set_range([next_rule] ++ rest)
  end
  defp set_range([rule | []]) do
    [%Rule{rule | :range => :undefined}]
  end
  
  defp range_from_next_rule(rule, next_rule) do
    with {_, ""} <- Integer.parse(rule),
         {_, ""} <- Integer.parse(next_rule) 
    do
      next_rule
    else
      :error -> :undefined
    end
  end

end
