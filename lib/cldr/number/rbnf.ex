defmodule Cldr.Rbnf do
  @moduledoc """
  Rules Base Number Formatting

  During compilation we want to look up the configured locales
  and generate the functions needed for only those locales.

  For any other recognized locale we need a way to either fallback
  to a known locale, or error exit (configurable)
  """

  import Xml
  alias Cldr.Rbnf.Rule

  @default_radix 10
  @data_dir "./downloads/common"
  @rbnf_dir Path.join(@data_dir, "rbnf")

  @spec rbnf_dir :: String.t
  def rbnf_dir do
    @rbnf_dir
  end

  if File.exists?(@rbnf_dir) do
    @locales Enum.map(File.ls!(@rbnf_dir), &Path.basename(&1, ".xml"))
  else
    @locales []
  end

  @spec locales :: [String.t] | []
  def locales do
    @locales
  end

  def for_locale(locale) do
    if File.exists?(locale_path(locale)) do
      xml = locale
      |> locale_path
      |> Xml.parse

      xml
      |> rule_groups
      |> rule_sets_from_groups(xml)
      |> rules_from_rule_sets(xml)
    else
      {:error, :rbnf_file_not_found}
    end
  end

  # Returns all the rules in rbnf - helpful for testing
  # only.
  @doc false
  def all_rules do
    locales()
    |> Enum.map(&Cldr.Rbnf.for_locale/1)
    |> Enum.map(&Map.values/1)
    |> List.flatten
    |> Enum.map(&(&1.rules))
    |> List.flatten
  end

  def rule_sets_from_groups(groups, xml) do
    Enum.reduce groups, %{}, fn group, acc ->
      Map.put(acc, group, rule_sets(xml, group))
    end
  end

  def rules_from_rule_sets(rulesets, xml) do
    Enum.map(rulesets, fn {group, sets} ->
      {group, rules_from_one_group(group, sets, xml)}
    end)
    |> Enum.into(%{})
  end

  def rules_from_one_group(group, sets, xml) do
    Enum.map sets, fn [set, access] ->
      %{set: set, access: access, rules: rules(xml, group, set)}
    end
  end

  @spec locale_path(binary) :: String.t
  def locale_path(locale) when is_binary(locale) do
    Path.join(rbnf_dir(), "/#{locale}.xml")
  end

  @spec rule_groups(Xml.xml_node, String.t) :: [String.t]
  def rule_groups(xml, path \\ "//rulesetGrouping") do
    Enum.map(all(xml, path), fn(xml_node) -> attr(xml_node, "type") end)
  end

  @spec rule_sets(Xml.xml_node, binary) :: list([type: String.t, access: String.t])
  def rule_sets(xml, rulegroup) do
    path = "//rulesetGrouping[@type='#{rulegroup}']/ruleset"
    Enum.map(all(xml, path), fn(xml_node) ->
      [attr(xml_node, "type"), attr(xml_node, "access") || "public"]
    end)
  end

  @spec rules(Xml.xml_node, String.t, String.t) :: [%Rule{}]
  def rules(xml, rulegroup, ruleset) do
    path = "//rulesetGrouping[@type='#{rulegroup}']/ruleset[@type='#{ruleset}']/rbnfrule"
    xml
    |> all(path)
    |> Enum.map(fn(xml_node) ->
        %Rule{base_value: to_integer(attr(xml_node, "value")),
              radix:      to_integer(attr(xml_node, "radix")) || @default_radix,
              definition: remove_trailing_semicolon(text(xml_node))}
       end)
    |> set_range
    |> set_divisor
  end

  def to_integer(nil) do
    nil
  end

  def to_integer(value) do
    with {int, ""} <- Integer.parse(value) do
      int
    else
      _ -> value
    end
  end

  def remove_trailing_semicolon(text) do
    String.replace_suffix(text, ";", "")
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
    [%Rule{rule | range: range_from_next_rule(rule.base_value, next_rule.base_value)}] ++ set_range([next_rule] ++ rest)
  end

  defp set_range([rule | []]) do
    [%Rule{rule | :range => :undefined}]
  end

  defp range_from_next_rule(rule, next_rule) when is_number(rule) and is_number(next_rule) do
    next_rule
  end

  defp range_from_next_rule(_rule, _next_rule) do
    :undefined
  end

  defp set_divisor([rule]) do
    [%Rule{rule | divisor: divisor(rule.base_value, rule.radix)}]
  end

  defp set_divisor([rule | rest]) do
    [%Rule{rule | divisor: divisor(rule.base_value, rule.radix)} | set_divisor(rest)]
  end

  # Thanks to twitter-cldr:
  # https://github.com/twitter/twitter-cldr-rb/blob/master/lib/twitter_cldr/formatters/numbers/rbnf/rule.rb
  defp divisor(base_value, radix) when is_integer(base_value) and is_integer(radix) do
    exponent = if base_value > 0 do
      Float.ceil(:math.log(base_value) / :math.log(radix)) |> trunc
    else
      1
    end

    divisor = if exponent > 0 do
      :math.pow(radix, exponent) |> trunc
    else
      1
    end

    if divisor > base_value do
      :math.pow(radix, exponent - 1) |> trunc
    else
      divisor
    end
  end

  defp divisor(_base_value, _radix) do
    nil
  end
end
