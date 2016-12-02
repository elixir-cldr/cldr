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

  alias Cldr.Rbnf.Rule

  @default_radix 10
  @data_dir Cldr.Consolidate.download_data_dir() <> "/cldr-rbnf"
  @rbnf_dir Path.join(@data_dir, "rbnf")

  @spec rbnf_dir :: String.t
  def rbnf_dir do
    @rbnf_dir
  end

  if File.exists?(@rbnf_dir) do
    @rbnf_locales Enum.map(File.ls!(@rbnf_dir), &Path.basename(&1, ".json"))
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
      locale
      |> locale_path
      |> File.read!
      |> Poison.decode!
      |> Map.get("rbnf")
      |> Map.get("rbnf")
      |> rules_from_rule_sets
    else
      {:error, :rbnf_file_not_found}
    end
  end

  defp rules_from_rule_sets(json) do
    Enum.map(json, fn {group, sets} ->
      {String.to_atom(group), rules_from_one_group(sets)}
    end)
    |> Enum.into(%{})
  end

  defp rules_from_one_group(sets) do
    Enum.map(sets, fn {set, rules} ->
      access = access_from_set(set)
      {function_name_from(set), %{access: access, rules: rules_from(rules)}}
    end)
    |> Enum.into(%{})
  end

  defp access_from_set(<<"%%", _rest::binary>>), do: :private
  defp access_from_set(_), do: :public

  defp rules_from(rules) do
    Enum.map(rules, fn {name, rule} ->
      {base_value, radix} = radix_from_name(name)
      %Rule{base_value: base_value, radix: radix, definition: remove_trailing_semicolon(rule)}
    end)
    |> sort_rules
    |> set_range
    |> set_divisor
  end

  defp sort_rules(rules) do
    Enum.sort(rules, fn (a, b) ->
      cond do
        is_binary(a.base_value)     -> true
        is_binary(b.base_value)     -> false
        a.base_value < b.base_value -> true
        true                        -> false
      end
    end)
  end

  defp radix_from_name(name) do
    case String.split(name, "/") do
      [base_value, radix] ->
        {to_integer(base_value), to_integer(radix)}
      [base_value] ->
        {to_integer(base_value), @default_radix}
    end
  end

  @spec locale_path(binary) :: String.t
  defp locale_path(locale) when is_binary(locale) do
    Path.join(rbnf_dir(), "/#{locale}.json")
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

  defp function_name_from(set) do
    set
    |> String.trim_leading("%")
    |> String.replace("-","_")
    |> String.to_atom
  end
end