defmodule Cldr.Rbnf.Config do
  @moduledoc """
  Rules Base Number Formatting Configuration management.

  During the process of consolidating the various CLDR files into
  a standard format that is easily digestible for Cldr, these functions
  are used to do the parsing and normalising of RBNF data.
  """
  alias Cldr.Locale

  @default_radix 10
  @data_dir Path.join(Cldr.Config.cldr_home, "data") <> "/cldr-rbnf"
  @rbnf_dir Path.join(@data_dir, "rbnf")

  @doc """
  Returns the directory where the RBNF data is stored

  ## Example

      iex> Cldr.Rbnf.Config.rbnf_dir =~ "/cldr-rbnf/rbnf"
      true

  """
  @spec rbnf_dir :: String.t
  def rbnf_dir do
    @rbnf_dir
  end

  if File.exists?(@rbnf_dir) do
    @rbnf_locale_names Enum.map(File.ls!(@rbnf_dir), &Path.basename(&1, ".json"))
  else
    @rbnf_locale_names []
  end

  @doc """
  Returns a list of the locales for which there is an rbnf rule set

  Relies on the presence of downloaded CLDR data. This function is
  usefully primarily to a Cldr library developer.

  ## Example

      iex> Cldr.Rbnf.Config.rbnf_locales
      ["af", "am", "ar", "az", "be", "bg", "bs", "ca", "cs", "cy", "da", "de-CH",
       "de", "ee", "el", "en", "eo", "es-419", "es", "et", "fa-AF", "fa", "fi", "fil",
       "fo", "fr-BE", "fr-CH", "fr", "ga", "he", "hi", "hr", "hu", "hy", "id", "is",
       "it", "ja", "ka", "kl", "km", "ko", "ky", "lo", "lt", "lv", "mk", "ms", "mt",
       "my", "nb", "nl", "nn", "pl", "pt-PT", "pt", "ro", "root", "ru", "se", "sk",
       "sl", "sq", "sr-Latn", "sr", "sv", "ta", "th", "tr", "uk", "vi", "yue",
       "zh-Hant", "zh"]

  """
  @spec rbnf_locale_names :: [String.t] | []
  def rbnf_locale_names do
    @rbnf_locale_names
  end

  @doc """
  Returns the list of locales that is the intersection of
  `Cldr.known_locales/0` and `Cldr.Rbnf.rbnf_locales/0`

  This list is therefore the set of known locales for which
  there are rbnf rules defined.

  ## Example

      iex> Cldr.Rbnf.Config.known_locale_names
      ["lo", "eo", "ja", "el", "fo", "hu", "yue", "fil", "sq", "cy", "da", "sv", "ee",
       "et", "ta", "nl", "vi", "nb", "lv", "id", "pt-PT", "fa-AF", "lt", "my",
       "sr-Latn", "cs", "ms", "fa", "bg", "es", "en", "af", "mt", "am", "ca", "mk",
       "ro", "de-CH", "ka", "root", "hr", "nn", "hy", "pt", "se", "he", "ga", "sr",
       "hi", "ky", "ko", "zh-Hant", "kl", "km", "sk", "ru", "zh", "de", "fi", "it",
       "be", "pl", "az", "tr", "is", "fr-CH", "es-419", "th", "fr-BE", "fr", "sl",
       "bs", "uk", "ar"]

  """
  def known_locale_names do
    MapSet.intersection(MapSet.new(Cldr.known_locale_names), MapSet.new(rbnf_locale_names()))
    |> MapSet.to_list
  end

  @doc """
  Returns the rbnf rules for a `locale` or `{:error, :rbnf_file_not_found}`

  * `locale_name` is any locale returned by `Rbnf.known_locales/0`.

  Note that `for_locale/1` does not raise if the locale does not exist
  like the majority of `Cldr`.  This is by design since the set of locales
  that have rbnf rules is substantially less than the set of locales
  supported by `Cldr`.

  ## Example

      iex> {:ok, rules} = Cldr.Rbnf.Config.for_locale("en")
      iex> Map.keys(rules)
      [:OrdinalRules, :SpelloutRules]

  """
  @spec for_locale(Locale.locale_name) :: %{} |  {:error, {Cldr.Rbnf.NotAvailable, String.t}}
  def for_locale(locale_name) when is_binary(locale_name) do
    with \
      true <- File.exists?(locale_path(locale_name))
    do
      rules =
        locale_name
        |> locale_path
        |> File.read!
        |> Jason.decode!
        |> Map.get("rbnf")
        |> Map.get("rbnf")
        |> rules_from_rule_sets

      {:ok, rules}
    else
      {:error, {exception, reason}} ->
        {:error, {exception, reason}}
      false ->
        {:error, rbnf_nofile_error(locale_name)}
    end
  end

  defp rbnf_nofile_error(locale_name) do
    {Cldr.Rbnf.NotAvailable, "The locale name #{inspect locale_name} does not have an RBNF configuration file available"}
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
      %{base_value: base_value, radix: radix, definition: remove_trailing_semicolon(rule)}
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
    [Map.put(rule, :range, range_from_next_rule(rule.base_value, next_rule.base_value))] ++ set_range([next_rule] ++ rest)
  end

  defp set_range([rule | []]) do
    [Map.put(rule, :range, :undefined)]
  end

  defp range_from_next_rule(rule, next_rule) when is_number(rule) and is_number(next_rule) do
    next_rule
  end

  defp range_from_next_rule(_rule, _next_rule) do
    :undefined
  end

  defp set_divisor([rule]) do
    [Map.put(rule, :divisor, divisor(rule.base_value, rule.radix))]
  end

  defp set_divisor([rule | rest]) do
    [Map.put(rule, :divisor, divisor(rule.base_value, rule.radix)) | set_divisor(rest)]
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
      trunc(:math.pow(radix, exponent))
    else
      1
    end

    if divisor > base_value do
      trunc(:math.pow(radix, exponent - 1))
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