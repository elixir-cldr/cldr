defmodule Cldr.LanguageTag.U do
  @moduledoc false

  defstruct [
    :calendar,
    :collation,
    :alternative_collation,
    :backward_level2,
    :case_level,
    :numeric,
    :hiragana_quarternary,
    :normalization,
    :reorder,
    :case_first,
    :strength,
    :currency,
    :currency_format,
    :number_system,
    :emoji_style,
    :first_day_of_week,
    :hour_cycle,
    :line_break_style,
    :line_break_word,
    :measurement_system,
    :sentence_break_supression,
    :timezone,
    :region_override,
    :subdivision,
    :variable_top,
    :variant
  ]

  @type t ::
          %__MODULE__{
            calendar: atom(),
            collation: atom(),
            alternative_collation: atom(),
            backward_level2: atom(),
            case_level: atom(),
            numeric: atom(),
            hiragana_quarternary: atom(),
            normalization: atom(),
            reorder: atom(),
            case_first: atom(),
            strength: atom(),
            currency: atom(),
            currency_format: atom(),
            number_system: atom(),
            emoji_style: atom(),
            first_day_of_week: atom(),
            hour_cycle: atom(),
            line_break_style: atom(),
            line_break_word: atom(),
            measurement_system: atom(),
            sentence_break_supression: atom(),
            timezone: atom(),
            region_override: atom(),
            subdivision: atom(),
            variable_top: atom(),
            variant: atom()
          }
          | map()

  alias Cldr.Config
  alias Cldr.LanguageTag.Parser

  # from => [to, valid_list, default]
  @locale_map %{
    "ca" => [:calendar, &__MODULE__.validate_calendar/1, :gregorian],
    "co" => [:collation, &__MODULE__.validate_collation/1, :standard],
    "ka" => [:alternative_collation, &__MODULE__.validate_alternative_collation/1, :shifted],
    "kb" => [:backward_level2, &__MODULE__.true_false/1, false],
    "kc" => [:case_level, &__MODULE__.true_false/1, false],
    "kn" => [:numeric, &__MODULE__.true_false/1, false],
    "kh" => [:hiragana_quarternary, &__MODULE__.true_false/1, true],
    "kk" => [:normalization, &__MODULE__.true_false/1, true],
    "kr" => [:reorder, :any, nil],
    "kf" => [:case_first, &__MODULE__.validate_case_first/1, false],
    "ks" => [:strength, &__MODULE__.validate_strength/1, :level3],
    "cu" => [:currency, &Cldr.validate_currency/1, nil],
    "cf" => [:currency_format, &__MODULE__.validate_currency_format/1, :currency],
    "nu" => [:number_system, &Cldr.validate_number_system/1, nil],
    "em" => [:emoji_style, &__MODULE__.validate_emoji/1, :default],
    "fw" => [:first_day_of_week, &__MODULE__.validate_first_day/1, 1],
    "hc" => [:hour_cycle, &__MODULE__.validate_hour_cycle/1, :h23],
    "lb" => [:line_break_style, &__MODULE__.validate_line_break_style/1, :normal],
    "lw" => [:line_break_word, &__MODULE__.validate_line_break_word/1, :normal],
    "ms" => [:measurement_system, &Cldr.validate_measurement_system/1, :metric],
    "ss" => [
      :sentence_break_supression,
      &__MODULE__.validate_sentence_break_supression/1,
      :standard
    ],
    "tz" => [:timezone, &Cldr.Timezone.validate_timezone/1, nil],
    "rg" => [:region_override, &Cldr.validate_territory_subdivision/1, nil],
    "sd" => [:subdivision, &Cldr.validate_territory_subdivision/1, nil],
    "vt" => :variable_top,
    "va" => :variant
  }

  @doc false
  def canonicalize_locale_keys(%Cldr.LanguageTag{locale: locale} = language_tag)
      when locale == %{} do
    language_tag
  end

  def canonicalize_locale_keys(%Cldr.LanguageTag{locale: locale} = language_tag) do
    canon_locale =
      Enum.map(locale, fn {k, v} ->
        if Map.has_key?(locale_key_map(), k) do
          Parser.canonicalize_key(locale_key_map()[k], v)
        else
          {k, v}
        end
      end)
      |> Map.new()

    Map.put(language_tag, :locale, struct(__MODULE__, canon_locale))
  end

  @doc false
  def validate_calendar("gregory"), do: {:ok, :gregorian}

  def validate_calendar(calendar) when is_list(calendar) do
    calendar
    |> Enum.join("_")
    |> validate_calendar
  end

  def validate_calendar(calendar) do
    Cldr.validate_calendar(calendar)
  end

  @doc false
  @collations Cldr.Config.collations()
  def validate_collation(collation) when collation in @collations do
    {:ok, String.to_atom(collation)}
  end

  def validate_collation(value), do: {:error, value}

  @doc false
  def validate_currency_format("standard"), do: {:ok, :currency}
  def validate_currency_format("account"), do: {:ok, :accounting}
  def validate_currency_format(value), do: {:error, value}

  @doc false
  def validate_alternative_collation("noignore"), do: {:ok, :noignore}
  def validate_alternative_collation("shifted"), do: {:ok, :shifted}
  def validate_alternative_collation(value), do: {:error, value}

  @doc false
  def validate_case_first("upper"), do: {:ok, :upper}
  def validate_case_first("lower"), do: {:ok, :lower}
  def validate_case_first("false"), do: {:ok, false}
  def validate_case_first(value), do: {:error, value}

  @doc false
  def validate_strength("level1"), do: {:ok, :level1}
  def validate_strength("level2"), do: {:ok, :level2}
  def validate_strength("level3"), do: {:ok, :level3}
  def validate_strength("level4"), do: {:ok, :level4}
  def validate_strength("identic"), do: {:ok, :identic}
  def validate_strength(value), do: {:error, value}

  @doc false
  def validate_emoji("emoji"), do: {:ok, :emoji}
  def validate_emoji("text"), do: {:ok, :text}
  def validate_emoji("default"), do: {:ok, :default}
  def validate_emoji(value), do: {:error, value}

  def validate_first_day("mon"), do: {:ok, 1}
  def validate_first_day("tue"), do: {:ok, 2}
  def validate_first_day("wed"), do: {:ok, 3}
  def validate_first_day("thu"), do: {:ok, 4}
  def validate_first_day("fri"), do: {:ok, 5}
  def validate_first_day("sat"), do: {:ok, 6}
  def validate_first_day("sun"), do: {:ok, 7}
  def validate_first_day(value), do: {:error, value}

  @doc false
  def validate_hour_cycle("h12"), do: {:ok, :hour_1_12}
  def validate_hour_cycle("h23"), do: {:ok, :hour_0_23}
  def validate_hour_cycle("h11"), do: {:ok, :hour_0_11}
  def validate_hour_cycle("h24"), do: {:ok, :hour_1_24}
  def validate_hour_cycle(value), do: {:error, value}

  @doc false
  def validate_line_break_style("strict"), do: {:ok, :strict}
  def validate_line_break_style("normal"), do: {:ok, :normal}
  def validate_line_break_style("loose"), do: {:ok, :loose}
  def validate_line_break_style(value), do: {:error, value}

  @doc false
  def validate_line_break_word("normal"), do: {:ok, :normal}
  def validate_line_break_word("breakall"), do: {:ok, :breakall}
  def validate_line_break_word("keepall"), do: {:ok, :keepall}
  def validate_line_break_word(value), do: {:error, value}

  @doc false
  def validate_sentence_break_supression("standard"), do: {:ok, :standard}
  def validate_sentence_break_supression("none"), do: {:ok, :nonel}
  def validate_sentence_break_supression(value), do: {:error, value}

  @doc false
  def true_false("true"), do: {:ok, true}
  def true_false("false"), do: {:ok, false}
  def true_false(value), do: {:error, value}

  @doc false
  def locale_key_map do
    @locale_map
  end

  @inverse_locale_map @locale_map
                      |> Enum.map(fn
                        {attr, [key | _rest]} -> {key, attr}
                        {attr, key} -> {key, attr}
                      end)
                      |> Map.new()

  @doc false
  def inverse_locale_key_map do
    @inverse_locale_map
  end

  @doc false
  def to_string(locale) when locale == %{} do
    ""
  end

  def to_string(locale) do
    locale
    |> Map.to_list()
    |> tl()
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Enum.map(fn {k, v} -> "#{inverse_locale_key_map()[k]}-#{inverse(k, v)}" end)
    |> Enum.reject(&is_nil/1)
    |> Enum.join("-")
  end

  defp inverse(:calendar, :gregorian), do: :gregory
  defp inverse(:calendar, calendar), do: String.replace("#{calendar}", "_", "-")
  defp inverse(:first_day, day), do: Enum.at(Config.days_of_week(), day - 1)
  defp inverse(_key, value), do: value
end
