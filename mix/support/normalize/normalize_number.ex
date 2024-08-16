defmodule Cldr.Normalize.Number do
  @moduledoc false

  def normalize(content, locale) do
    content
    |> normalize_formats(locale)
    |> normalize_symbols(locale)
  end

  @doc false
  def normalize_formats(content, _locale) do
    numbers = get_in(content, ["numbers"])
    number_systems = number_system_names_from(numbers)

    number_formats =
      Enum.reduce(number_systems, %{}, fn number_system, formats ->
        decimal_formats = numbers["decimal_formats_number_system_#{number_system}"]
        currency_formats = numbers["currency_formats_number_system_#{number_system}"]
        scientific_formats = numbers["scientific_formats_number_system_#{number_system}"]
        percent_formats = numbers["percent_formats_number_system_#{number_system}"]
        misc_formats = numbers["misc_patterns_number_system_#{number_system}"]

        decimal_long_format = get_in(decimal_formats, ["long", "decimal_format"])
        decimal_short_format = get_in(decimal_formats, ["short", "decimal_format"])
        currency_short_format = get_in(currency_formats, ["short", "standard"])
        currency_spacing = currency_formats["currency_spacing"]

        locale_formats = %{
          standard: decimal_formats["standard"],
          decimal_long: normalize_short_format(decimal_long_format),
          decimal_short: normalize_short_format(decimal_short_format),
          currency: currency_formats["standard"],
          currency_no_symbol: currency_formats["standard_no_currency"],
          currency_alpha_next_to_number: currency_formats["standard_alpha_next_to_number"],
          currency_with_iso:
            normalize_iso_format(currency_formats["currency_pattern_append_iso"]),
          currency_short: normalize_short_format(currency_short_format),
          currency_long: currency_long_format(currency_formats),
          accounting: currency_formats["accounting"],
          accounting_no_symbol: currency_formats["accounting_no_currency"],
          accounting_alpha_next_to_number: currency_formats["accounting_alpha_next_to_number"],
          scientific: scientific_formats["standard"],
          percent: percent_formats["standard"],
          currency_spacing: normalize_currency_spacing(currency_spacing),
          other: normalize_misc_formats(misc_formats)
        }

        Map.put(formats, number_system, locale_formats)
      end)
      |> Map.new()
      |> Cldr.Map.integerize_keys()

    content =
      Map.put(
        content,
        "minimum_grouping_digits",
        String.to_integer(numbers["minimum_grouping_digits"])
      )

    Map.put(content, "number_formats", number_formats)
  end

  @doc false
  def normalize_symbols(content, _locale) do
    numbers = get_in(content, ["numbers"])
    number_systems = number_system_names_from(numbers)

    symbols =
      Enum.reduce(number_systems, %{}, fn number_system, number_symbols ->
        symbols = get_in(numbers, ["symbols_number_system_#{number_system}"])
        Map.put(number_symbols, number_system, symbols)
      end)

    Map.put(content, "number_symbols", symbols)
  end

  @doc false
  def normalize_currency_spacing(nil) do
    nil
  end

  def normalize_currency_spacing(currency_spacing) do
    currency_spacing
    |> Cldr.Map.deep_map(
      {fn x -> x end,
       fn
         "[:^S:]" -> "[^\\p{S}]"
         "[:digit:]" -> "[[:digit:]]"
         other -> other
       end}
    )
    |> Map.new()
  end

  @doc false
  def number_system_names_from(numbers) do
    default = numbers["default_numbering_system"]
    others = Map.values(numbers["other_numbering_systems"])

    ([default] ++ others)
    |> Enum.uniq()
  end

  @spec normalize_short_format(%{}) :: list() | nil
  def normalize_short_format(nil) do
    nil
  end

  @doc false
  def normalize_short_format(format) do
    format
    |> Enum.group_by(fn {range, _rules} -> List.first(String.split(range, "_")) end)
    |> Enum.map(fn {range, rules} -> {String.to_integer(range), rules} end)
    |> Enum.map(&flatten_short_formats/1)
    |> Enum.sort()
  end

  @doc false
  def normalize_misc_formats(nil) do
    nil
  end

  def normalize_misc_formats(format) do
    format
    |> Enum.map(fn {k, v} -> {k, Cldr.Substitution.parse(v)} end)
    |> Map.new()
  end

  def normalize_iso_format(nil) do
    nil
  end

  def normalize_iso_format(format) when is_binary(format) do
    Cldr.Substitution.parse(format)
  end

  @doc false
  @spec flatten_short_formats({binary, [] | String.t()}) :: tuple
  def flatten_short_formats({range, rules}) when is_list(rules) do
    formats =
      Enum.map(rules, fn {name, format} ->
        plural_type =
          name
          |> String.split("_")
          |> Enum.reverse()
          |> List.first()

        {plural_type, [format, number_of_zeros(format)]}
      end)

    [range, Enum.into(formats, %{})]
  end

  @doc false
  def flatten_short_formats(formats) do
    formats
  end

  # Here we get the entire currency format section but we only want
  # the section that is marked as a set of "unitPattern-count-___".
  @doc false
  @pattern_count "unit_pattern_count_"
  @pattern_regex Regex.compile!(@pattern_count)
  def currency_long_format(nil), do: nil

  def currency_long_format(formats) do
    formats
    |> Enum.filter(fn {k, _v} -> Regex.match?(@pattern_regex, k) end)
    |> Enum.map(fn {k, v} ->
      @pattern_count <> count = k
      {count, Cldr.Substitution.parse(v)}
    end)
    |> Enum.into(%{})
  end

  defp number_of_zeros(format) do
    format
    |> String.to_charlist()
    |> Enum.reduce(0, fn c, acc -> if c == ?0, do: acc + 1, else: acc end)
  end
end
