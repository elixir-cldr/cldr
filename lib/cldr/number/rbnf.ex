defmodule Cldr.Rbnf do
  @moduledoc """
  Rules Base Number Formatting

  During compilation we want to look up the configured locales
  and generate the functions needed for only those locales.

  For any other recognized locale we need a way to either fallback
  to a known locale, or error exit (configurable)
  """
  # import Xml
  # alias Cldr.Rbnf.Rule
  # defdelegate parse(filename), to: Xml
  # @data_dir Application.get_env(:cldr, :data_dir) || "./priv/cldr"
  # @rbnf_dir Path.join(@data_dir, "rbnf")
  #
  # @spec rbnf_dir :: String.t
  # def rbnf_dir do
  #   @rbnf_dir
  # end
  #
  # {:ok, files} = File.ls(@rbnf_dir)
  # @locales Enum.map(files, &Path.basename(&1, ".xml"))
  # @spec locales :: [String.t] | []
  # def locales do
  #   @locales
  # end
  #
  # @spec locale_path(binary) :: String.t
  # def locale_path(locale) when is_binary(locale) do
  #   Path.join(rbnf_dir(), "/#{locale}.xml")
  # end
  #
  # @spec rulegroups(Xml.xml_node, String.t) :: [String.t]
  # def rulegroups(xml, path \\ "//rulesetGrouping") do
  #   Enum.map(all(xml, path), fn(xml_node) -> attr(xml_node, "type") end)
  # end
  #
  # @spec rulesets(Xml.xml_node, binary) :: list([type: String.t, access: String.t])
  # def rulesets(xml, rulegroup) do
  #   path = "//rulesetGrouping[@type='#{rulegroup}']/ruleset"
  #   Enum.map(all(xml, path), fn(xml_node) -> [attr(xml_node, "type"), attr(xml_node, "access") || "public"] end)
  # end
  #
  # @spec rules(Xml.xml_node, String.t, String.t) :: [%Rule{}]
  # def rules(xml, rulegroup, ruleset) do
  #   path = "//rulesetGrouping[@type='#{rulegroup}']/ruleset[@type='#{ruleset}']/rbnfrule"
  #   xml
  #   |> all(path)
  #   |> Enum.map(fn(xml_node) ->
  #     %Rule{name: attr(xml_node, "value"), radix: attr(xml_node, "radix"), definition: text(xml_node)}
  #   end)
  #   |> set_range
  # end
  #
  # # If the current rule is numeric and the next rule is numeric then
  # # the next rules value determines the upper bound of the validity
  # # of the current rule.
  # #
  # # ie.   "0": "one;"
  # #       "10": "ten;"
  # #
  # # Means that rule "0" is applied for values up to but not including "10"
  # defp set_range([rule | [next_rule | rest]]) do
  #   [%Rule{rule | :range => range_from_next_rule(rule.name, next_rule.name)}] ++ set_range([next_rule] ++ rest)
  # end
  # defp set_range([rule | []]) do
  #   [%Rule{rule | :range => :undefined}]
  # end
  #
  # defp range_from_next_rule(rule, next_rule) do
  #   with {_, ""} <- Integer.parse(rule),
  #        {_, ""} <- Integer.parse(next_rule)
  #   do
  #     next_rule
  #   else
  #     :error -> :undefined
  #   end
  # end
end
