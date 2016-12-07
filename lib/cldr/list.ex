defmodule Cldr.List do
  @moduledoc """
  `Cldr` incudes patterns that enable list to be catenated together
  to form a grammatically correct language construct for a given locale.

  If we have a list of days like `["Monday", "Tuesday", "Wednesday"]`
  then we can format that list for a given locale by:

      iex> Cldr.List.to_string(["Monday", "Tuesday", "Wednesday"], locale: "en")
      "Monday, Tuesday, and Wednesday"
  """

  @type pattern_type :: :standard | :unit | :unit_narrow | :unit_short
  @default_style :standard

  @doc """
  Formats a list into a string according to the list pattern rules for a locale.

  * `list` is any list of of terms that can be passed through `Kernel.to_string/1`

  * `options` are:

    * `locale` is any configured locale. See `Cldr.known_locales()`. The default
    is `locale: Cldr.get_locale()`

    * `format` is one of those returned by
    `Cldr.List.list_pattern_types_for/1`. The default is `format: :standard`

  ## Examples

      iex> Cldr.List.to_string(["a", "b", "c"], locale: "en")
      "a, b, and c"

      iex> Cldr.List.to_string(["a", "b", "c"], locale: "en", format: :unit_narrow)
      "a b c"

      iex> Cldr.List.to_string(["a", "b", "c"], locale: "fr")
      "a, b et c"

      iex> Cldr.List.to_string([1,2,3,4,5,6])
      "1, 2, 3, 4, 5, and 6"

      iex> Cldr.List.to_string(["a"])
      "a"

      iex> Cldr.List.to_string([1,2])
      "1 and 2"
  """
  @spec to_string(List.t, Keyword.t) :: String.t
  def to_string(list, options \\ [])
  def to_string([], _options) do
    ""
  end

  def to_string(list, options) do
    case normalize_options(options) do
      {:error, {_exception, _message}} = error ->
        error
      {locale, format} ->
        to_string(list, locale, format)
    end
  end

  @doc """
  Formats a list using `to_string/2` but raises if there is
  an error.
  """
  @spec to_string(List.t, Keyword.t) :: String.t | Exception.t
  def to_string!(list, options \\ []) do
    case string = to_string(list, options) do
      {:error, {exception, message}} ->
        raise exception, message: message
      _ ->
        string
    end
  end

  # For when the list is empty
  defp to_string([], _locale, _pattern_type) do
    ""
  end

  # For when there is one element only
  defp to_string([first], _locale, _pattern_type) do
    Kernel.to_string(first)
  end

  # For when there are two elements only
  defp to_string([first, last], locale, pattern_type) do
    pattern = list_patterns_for(locale)[pattern_type][:"2"]

    pattern
    |> String.replace("{0}", Kernel.to_string(first))
    |> String.replace("{1}", Kernel.to_string(last))
  end

  # For when there are three elements only
  defp to_string([first, middle, last], locale, pattern_type) do
    first_pattern = list_patterns_for(locale)[pattern_type][:start]
    last_pattern = list_patterns_for(locale)[pattern_type][:end]

    last = last_pattern
    |> String.replace("{0}", Kernel.to_string(middle))
    |> String.replace("{1}", Kernel.to_string(last))

    first_pattern
    |> String.replace("{0}", Kernel.to_string(first))
    |> String.replace("{1}", Kernel.to_string(last))
  end

  # For when there are more than 3 elements
  defp to_string([first | rest], locale, pattern_type) do
    first_pattern = list_patterns_for(locale)[pattern_type][:start]

    first_pattern
    |> String.replace("{0}", Kernel.to_string(first))
    |> String.replace("{1}", do_to_string(rest, locale, pattern_type))
  end

  # When there are only two left (ie last)
  defp do_to_string([first, last], locale, pattern_type) do
    last_pattern = list_patterns_for(locale)[pattern_type][:end]

    last_pattern
    |> String.replace("{0}", Kernel.to_string(first))
    |> String.replace("{1}", Kernel.to_string(last))
  end

  # For the middle elements
  defp do_to_string([first | rest], locale, pattern_type) do
    middle_pattern = list_patterns_for(locale)[pattern_type][:middle]

    middle_pattern
    |> String.replace("{0}", Kernel.to_string(first))
    |> String.replace("{1}", do_to_string(rest, locale, pattern_type))
  end

  @spec list_patterns_for(Cldr.locale) :: Map.t
  @spec list_pattern_styles_for(Cldr.locale) :: [atom]
  Enum.each Cldr.known_locales, fn (locale) ->
    patterns = Cldr.Locale.get_locale(locale).list_formats
    pattern_names = Map.keys(patterns)

    @doc """
    Returns the list patterns for a locale.

    List patterns provide rules for combining multiple
    items into a language format appropriate for a locale.

    ## Example

        iex> Cldr.List.list_patterns_for "en"
        %{standard: %{"2": "{0} and {1}", end: "{0}, and {1}",
           middle: "{0}, {1}", start: "{0}, {1}"},
         standard_short: %{"2": "{0} and {1}", end: "{0}, and {1}",
           middle: "{0}, {1}", start: "{0}, {1}"},
         unit: %{"2": "{0}, {1}", end: "{0}, {1}", middle: "{0}, {1}",
           start: "{0}, {1}"},
         unit_narrow: %{"2": "{0} {1}", end: "{0} {1}", middle: "{0} {1}",
           start: "{0} {1}"},
         unit_short: %{"2": "{0}, {1}", end: "{0}, {1}", middle: "{0}, {1}",
           start: "{0}, {1}"}}
    """
    def list_patterns_for(unquote(locale)) do
      unquote(Macro.escape(patterns))
    end

    @doc """
    Returns the styles of list patterns available for a locale.

    Returns a list of `atom`s of of the list format styles that are
    available in CLDR for a locale.

    ## Example

        iex> Cldr.List.list_pattern_styles_for("en")
        [:standard, :standard_short, :unit, :unit_narrow, :unit_short]
    """
    def list_pattern_styles_for(unquote(locale)) do
      unquote(pattern_names)
    end
  end

  defp normalize_options(options) do
    locale = options[:locale] || Cldr.get_locale()
    format = options[:format] || @default_style

    with :ok <- verify_locale(locale),
         :ok <- verify_format(locale, format)
    do
      {locale, format}
    else
      {:error, {_exception, _message}} = error -> error
    end
  end

  defp verify_locale(locale) do
    if !Cldr.known_locale?(locale) do
      {:error, {Cldr.UnknownLocaleError, "The locale #{inspect locale} is not known."}}
    else
      :ok
    end
  end

  defp verify_format(locale, format) do
    if !(format in list_pattern_styles_for(locale)) do
      {:error, {Cldr.UnknownFormatError, "The list format style #{inspect format} is not known."}}
    else
      :ok
    end
  end
end
