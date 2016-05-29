# During compilation we want to look up the configured locales
# and generate the functions needed for only those locales.

# For any other recognized locale we need a way to either fallback
# to a known locale, or error exit (configurable)
defmodule Cldr.Rbnf do
  import Xml
  alias Cldr.Rbnf.Rule

  def f do
    "/Users/kip/Development/databases/cldr/common/rbnf/en.xml"
  end
  
  def rulegroups(xml, path \\ "//rulesetGrouping") do
    Enum.map(all(xml, path), fn(node) -> attr(node, "type") end)
  end
  
  def rulesets(xml, rulegroup) do
    path = "//rulesetGrouping[@type='#{rulegroup}']/ruleset"
    Enum.map(all(xml, path), fn(node) -> [attr(node, "type"), attr(node, "access") || "public"] end)
  end
  
  def rules(xml, rulegroup, ruleset) do
    path = "//rulesetGrouping[@type='#{rulegroup}']/ruleset[@type='#{ruleset}']/rbnfrule"
    Enum.map(all(xml, path), fn(node) -> 
      %Rule{rule: attr(node, "value"), radix: attr(node, "radix"), definition: text(node)}
    end)
    |> set_range
  end
  
  def set_range([rule | [next_rule | rest]]) do
    [%Rule{rule | :range => range_from_next_rule(rule.rule, next_rule.rule)}] ++ set_range([next_rule] ++ rest)
  end
  def set_range([rule | []]) do
    [%Rule{rule | :range => nil}]
  end
  
  def range_from_next_rule(rule, next_rule) do
    with {_, ""} <- Integer.parse(rule),
         {_, ""} <- Integer.parse(next_rule) 
    do
      next_rule
    else
      :error -> :undefined
      _ -> :error
    end
  end

end
