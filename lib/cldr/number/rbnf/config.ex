defmodule Cldr.Rbnf.Config do
  @moduledoc """
  Rules Base Number Formatting Configuration management.

  During the process of consolidating the various CLDR XML files into
  a standard format that is easily digestible for Cldr, these functions
  are used to do the parsing an normalising of RBNF data.

  Note that many of the functions in this module rely on having the raw
  XML RBNF files from the CLDR repository.  The repository can be installed by
  running:

      mix cldr.download

  Unless you are interested in the muysteries of how the repository is
  put together this is not recommended.
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
    @rbnf_locales Enum.map(File.ls!(@rbnf_dir), &Path.basename(&1, ".xml"))
    |> Enum.map(&String.replace(&1, "_", "-"))
  else
    @rbnf_locales []
  end

  @doc """
  Returns a list of the locales for which there is an rbnf rule set

  Relies on the presence of downloaded CLDR data.  This can be achieved
  by runnuing `mix cldr.download`.  This function is usefully primarily
  to a Cldr library developer.
  """
  @spec rbnf_locales :: [String.t] | []
  def rbnf_locales do
    @rbnf_locales
  end

  @doc """
  Returns the list of locales that is the intersection of
  `Cldr.known_locales/0` and `Cldr.Rbnf.rbnf_locales/0`

  This list is therefore the set of known locales for which
  there are rbnf rules defined.
  """
  def known_locales do
    MapSet.intersection(MapSet.new(Cldr.known_locales), MapSet.new(rbnf_locales()))
    |> MapSet.to_list
  end

  @doc """
  Returns the rbnf rules for a `locale` or `{:error, :rbnf_file_not_found}`

  * `locale` is any locale returned by `Rbnf.known_locales/0`.

  Note that `for_locale/1` does not raise if the locale does not exist
  like the majority of `Cldr`.  This is by design since the set of locales
  that have rbnf rules is substantially less than the set of locales
  supported by `Cldr`.
  """
  @spec for_locale(Locale.t) :: %{} | {:error, :rbnf_file_not_found}
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

  defp rule_sets_from_groups(groups, xml) do
    Enum.reduce groups, %{}, fn group, acc ->
      Map.put(acc, group, rule_sets(xml, group))
    end
  end

  defp rules_from_rule_sets(rulesets, xml) do
    Enum.map(rulesets, fn {group, sets} ->
      {group, rules_from_one_group(group, sets, xml)}
    end)
    |> Enum.into(%{})
  end

  defp rules_from_one_group(group, sets, xml) do
    Enum.reduce sets, %{}, fn [set, access], acc ->
      Map.put acc, function_name_from_rule_group(set), %{access: access, rules: rules(xml, group, set)}
    end
  end

  # Rbnf is directly from XML and hence has "_" as a separator
  # in a locale whereas we use "-" elsewhere
  @spec locale_path(binary) :: String.t
  defp locale_path(locale) when is_binary(locale) do
    locale = String.replace(locale, "-", "_")
    Path.join(rbnf_dir(), "/#{locale}.xml")
  end

  @spec rule_groups(Xml.xml_node, String.t) :: [String.t]
  defp rule_groups(xml, path \\ "//rulesetGrouping") do
    Enum.map(all(xml, path), fn(xml_node) -> attr(xml_node, "type") end)
  end

  @spec rule_sets(Xml.xml_node, binary) :: list([type: String.t, access: String.t])
  defp rule_sets(xml, rulegroup) do
    path = "//rulesetGrouping[@type='#{rulegroup}']/ruleset"
    Enum.map(all(xml, path), fn(xml_node) ->
      [attr(xml_node, "type"), attr(xml_node, "access") || "public"]
    end)
  end

  @spec rules(Xml.xml_node, String.t, String.t) :: [%Rule{}]
  defp rules(xml, rulegroup, ruleset) do
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

  defp to_integer(nil) do
    nil
  end

  defp to_integer(value) do
    with {int, ""} <- Integer.parse(value) do
      int
    else
      _ -> value
    end
  end

  defp remove_trailing_semicolon(text) do
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

  defp function_name_from_rule_group(name) do
    name
    |> String.replace("-","_")
    |> String.to_atom
  end
end