defmodule Cldr.LanguageTag.U do
  @moduledoc """
  Defines the [BCP 47 `u` extension](https://unicode-org.github.io/cldr/ldml/tr35.html#u_Extension)
  of a `t:Cldr.LanguageTag`.

  """

  defstruct [
    :calendar,
    :collation,
    :col_alternate,
    :col_backwards,
    :col_case_level,
    :col_numeric,
    :col_normalization,
    :col_reorder,
    :col_case_first,
    :col_strength,
    :currency,
    :cf,
    :numbers,
    :em,
    :fw,
    :hc,
    :lb,
    :lw,
    :ms,
    :ss,
    :timezone,
    :rg,
    :sd,
    :vt,
    :va,
    :dx
  ]

  @type t ::
          %__MODULE__{
            calendar: atom(),
            collation: atom(),
            col_alternate: atom(),
            col_backwards: atom(),
            col_case_level: atom(),
            col_numeric: atom(),
            col_normalization: atom(),
            col_reorder: atom(),
            col_case_first: atom(),
            col_strength: atom(),
            currency: atom(),
            cf: atom(),
            numbers: atom(),
            em: atom(),
            fw: atom(),
            hc: atom(),
            lb: atom(),
            lw: atom(),
            ms: atom(),
            ss: atom(),
            timezone: atom(),
            rg: atom(),
            sd: atom(),
            vt: atom(),
            va: atom(),
            dx: atom()
          }

  alias Cldr.Config
  alias Cldr.LanguageTag.Parser

  # from => [to, valid_list, default]
  @locale_map %{
    "ca" => [:calendar, &__MODULE__.validate_calendar/1, :gregorian],
    "co" => [:collation, &__MODULE__.validate_collation/1, :standard],
    "ka" => [:col_alternate, &__MODULE__.validate_alternative_collation/1, :shifted],
    "kb" => [:col_backwards, &__MODULE__.true_false/1, false],
    "kc" => [:col_case_level, &__MODULE__.true_false/1, false],
    "kn" => [:col_numeric, &__MODULE__.true_false/1, false],
    "kk" => [:col_normalization, &__MODULE__.true_false/1, true],
    "kr" => [:col_reorder, :any, nil],
    "kf" => [:col_case_first, &__MODULE__.validate_case_first/1, false],
    "ks" => [:strength, &__MODULE__.validate_strength/1, :level3],
    "cu" => [:currency, &Cldr.validate_currency/1, nil],
    "cf" => [:cf, &__MODULE__.validate_currency_format/1, :currency],
    "nu" => [:numbers, &Cldr.validate_number_system/1, nil],
    "em" => [:em, &__MODULE__.validate_emoji/1, :default],
    "fw" => [:fw, &__MODULE__.validate_first_day/1, 1],
    "hc" => [:hc, &__MODULE__.validate_hour_cycle/1, :h23],
    "lb" => [:lb, &__MODULE__.validate_line_break_style/1, :normal],
    "lw" => [:lw, &__MODULE__.validate_line_break_word/1, :normal],
    "ms" => [:ms, &Cldr.validate_measurement_system/1, :metric],
    "ss" => [:ss, &__MODULE__.validate_sentence_break_supression/1, :standard],
    "tz" => [:timezone, &__MODULE__.validate_timezone/1, nil],
    "rg" => [:rg, &Cldr.validate_territory_subdivision/1, nil],
    "sd" => [:sd, &Cldr.validate_territory_subdivision/1, nil],
    "vt" => :vt,
    "va" => :va,
    "dx" => :dx
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

  def validate_timezone(short_zone) do
    if Map.has_key?(Cldr.Timezone.timezones(), short_zone) do
      {:ok, short_zone}
    else
      {:error, nil}
    end
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
    |> Enum.map(&key_value_pair/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.sort()
    |> Enum.join("-")
  end

  defp key_value_pair({_k, nil}) do
    nil
  end

  defp key_value_pair({k, v}) do
    key =
      inverse_locale_key_map()
      |> Map.get(k)

    value =
      k
      |> inverse(v)
      |> Kernel.to_string()
      |> String.downcase()

    key <> "-" <> value
  end

  defp inverse(:calendar, :gregorian), do: :gregory
  defp inverse(:calendar, calendar), do: String.replace("#{calendar}", "_", "-")
  defp inverse(:first_day, day), do: Enum.at(Config.days_of_week(), day - 1)
  defp inverse(_key, value), do: value
end
