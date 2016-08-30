defmodule Cldr.List do
  @moduledoc """
  Cldr incudes patterns that enable list to be catenated together
  to form a grammatically correct language construct for a given locale.

  If we have a list of days like `["Monday", "Tuesday", "Wednesday"]`
  then we can format that list for a given locale by:

      iex> Cldr.List.to_string(["Monday", "Tuesday", "Wednesday"], "en")
      "Monday, Tuesday, and Wednesday"
  """
  alias Cldr.File
  @type pattern_type :: :standard | :unit | :unit_narrow | :unit_short

  Enum.each Cldr.known_locales, fn (locale) ->
    patterns = File.read(:list_patterns, locale)
    pattern_names = Map.keys(patterns)

    @doc """
    Returns the list patterns for a locale.

    List patterns provide rules for combining multiple
    items into a language format appropriate for a locale.

    ## Example

        iex> Cldr.List.list_patterns_for "en"
        %{standard: %{"2" => "{0} and {1}", "end" => "{0}, and {1}",
            "middle" => "{0}, {1}", "start" => "{0}, {1}"},
          unit: %{"2" => "{0}, {1}", "end" => "{0}, {1}", "middle" => "{0}, {1}",
            "start" => "{0}, {1}"},
          unit_narrow: %{"2" => "{0} {1}", "end" => "{0} {1}", "middle" => "{0} {1}",
            "start" => "{0} {1}"},
          unit_short: %{"2" => "{0}, {1}", "end" => "{0}, {1}", "middle" => "{0}, {1}",
            "start" => "{0}, {1}"}}
    """
    @spec list_patterns_for(Cldr.locale) :: Map.t
    def list_patterns_for(unquote(locale)) do
      unquote(Macro.escape(patterns))
    end

    @doc """
    Returns the types of list patterns available for a locale.

    Returns a list of `atom`s of of the list format types that are
    available in CLDR for a locale.

    ## Example

        iex> Cldr.List.list_pattern_types_for("en")
        [:standard, :unit, :unit_narrow, :unit_short]
    """
    @spec list_pattern_types_for(Cldr.locale) :: [atom]
    def list_pattern_types_for(unquote(locale)) do
      unquote(pattern_names)
    end
  end

  @doc """
  Formats a list into a string according to the list pattern rules for a locale.

  * `list` is any list of of terms that can be passed through `Kernel.to_string/1`

  * `locale` is any configured locale.  See `Cldr.known_locales()`

  * `pattern_type` is one of those returned by
    `Cldr.List.list_pattern_types_for/1`. The default is `:standard`

  ## Examples

      iex> Cldr.List.to_string(["a", "b", "c"], "en")
      "a, b, and c"

      iex> Cldr.List.to_string(["a", "b", "c"], "en", :unit_narrow)
      "a b c"

      iex> Cldr.List.to_string(["a", "b", "c"], "fr")
      "a, b et c"

      iex> Cldr.List.to_string([1,2,3,4,5,6])
      "1, 2, 3, 4, 5, and 6"

      iex> Cldr.List.to_string(["a"])
      "a"

      iex> Cldr.List.to_string([1,2])
      "1 and 2"
  """
  @spec to_string(List.t, Cldr.locale, pattern_type) :: String.t
  def to_string(list, locale \\ Cldr.get_locale(), pattern_type \\ :standard)

  # For when the list is empty
  def to_string([], _locale, _pattern_type) do
    ""
  end

  # For when there is one element only
  def to_string([first], _locale, _pattern_type) do
    Kernel.to_string(first)
  end

  # For when there are two elements only
  def to_string([first, last], locale, pattern_type) do
    pattern = list_patterns_for(locale)[pattern_type]["2"]

    pattern
    |> String.replace("{0}", Kernel.to_string(first))
    |> String.replace("{1}", Kernel.to_string(last))
  end

  # For when there are three elements only
  def to_string([first, middle, last], locale, pattern_type) do
    first_pattern = list_patterns_for(locale)[pattern_type]["start"]
    last_pattern = list_patterns_for(locale)[pattern_type]["end"]

    last = last_pattern
    |> String.replace("{0}", Kernel.to_string(middle))
    |> String.replace("{1}", Kernel.to_string(last))

    first_pattern
    |> String.replace("{0}", Kernel.to_string(first))
    |> String.replace("{1}", Kernel.to_string(last))
  end

  # For when there are more than 3 elements
  def to_string([first | rest], locale, pattern_type) do
    first_pattern = list_patterns_for(locale)[pattern_type]["start"]

    first_pattern
    |> String.replace("{0}", Kernel.to_string(first))
    |> String.replace("{1}", do_to_string(rest, locale, pattern_type))
  end

  # When there are only two left (ie last)
  defp do_to_string([first, last], locale, pattern_type) do
    last_pattern = list_patterns_for(locale)[pattern_type]["end"]

    last_pattern
    |> String.replace("{0}", Kernel.to_string(first))
    |> String.replace("{1}", Kernel.to_string(last))
  end

  # For the middle elements
  defp do_to_string([first | rest], locale, pattern_type) do
    middle_pattern = list_patterns_for(locale)[pattern_type]["middle"]

    middle_pattern
    |> String.replace("{0}", Kernel.to_string(first))
    |> String.replace("{1}", do_to_string(rest, locale, pattern_type))
  end
end
