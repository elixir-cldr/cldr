defmodule Cldr.Normalize.Number do
  @moduledoc """
  Takes the number part of the locale map and transforms the formats into a more easily
  processable structure that is then stored in map managed by `Cldr.Locale`
  """
  alias Cldr.Number

  @doc """
  Normalize decimal formats for a locale.

  * `locale` is the full locale map from CLDR. The map is transformed and
    returned so that further processing may occur
  """
  def normalize(content, locale) do
    content
    |> normalize_formats(locale)
    |> normalize_symbols(locale)
  end

  def normalize_formats(content, _locale) do
    numbers        = get_in(content, ["numbers"])
    number_systems = number_system_names_from(numbers)

    number_formats = Enum.reduce number_systems, %{}, fn (number_system, formats) ->
      decimal_formats    = numbers["decimal_formats_number_system_#{number_system}"]
      currency_formats   = numbers["currency_formats_number_system_#{number_system}"]
      scientific_formats = numbers["scientific_formats_number_system_#{number_system}"]
      percent_formats    = numbers["percent_formats_number_system_#{number_system}"]

      decimal_long_format   = get_in(decimal_formats,  ["long", "decimal_format"])
      decimal_short_format  = get_in(decimal_formats,  ["short", "decimal_format"])
      currency_short_format = get_in(currency_formats, ["short", "standard"])

      locale_formats = %Number.Format{
        standard:         decimal_formats["standard"],
        decimal_long:     normalize_short_format(decimal_long_format),
        decimal_short:    normalize_short_format(decimal_short_format),
        currency:         currency_formats["standard"],
        currency_short:   normalize_short_format(currency_short_format),
        currency_long:    currency_long_format(currency_formats),
        accounting:       currency_formats["accounting"],
        scientific:       scientific_formats["standard"],
        percent:          percent_formats["standard"],
        currency_spacing: currency_formats["currency_spacing"],
      }
      Map.put(formats, number_system, locale_formats)
    end
    content = Map.put(content, "minimum_grouping_digits",
      String.to_integer(numbers["minimum_grouping_digits"]))
    Map.put(content, "number_formats", Enum.into(number_formats, %{}))
  end

  def normalize_symbols(content, _locale) do
    numbers        = get_in(content, ["numbers"])
    number_systems = number_system_names_from(numbers)

    symbols = Enum.reduce number_systems, %{}, fn (number_system, number_symbols) ->
      symbols = get_in(numbers, ["symbols_number_system_#{number_system}"])
      Map.put(number_symbols, number_system, symbols)
    end
    Map.put(content, "number_symbols", symbols)
  end


  def number_system_names_from(numbers) do
    default = numbers["default_numbering_system"]
    others = Map.values(numbers["other_numbering_systems"])
    ([default] ++ others)
    |> Enum.uniq
  end

  @spec normalize_short_format(Map.t) :: List.t
  def normalize_short_format(nil) do
    nil
  end

  def normalize_short_format(format) do
    format
    |> Enum.group_by(fn {range, _rules} -> List.first(String.split(range,"_")) end)
    |> Enum.map(fn {range, rules} -> {String.to_integer(range), rules} end)
    |> Enum.map(&flatten_short_formats/1)
    |> Enum.sort
  end

  @doc false
  @spec flatten_short_formats({binary, [] | String.t}) :: tuple
  def flatten_short_formats({range, rules}) when is_list(rules) do
    formats = Enum.map rules, fn {name, format} ->
      plural_type = name
      |> String.split("_")
      |> Enum.reverse
      |> List.first

      {plural_type, [format, number_of_zeros(format)]}
    end
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
    |> String.to_char_list
    |> Enum.reduce(0, fn c, acc -> if c == ?0, do: acc + 1, else: acc end)
  end
end
