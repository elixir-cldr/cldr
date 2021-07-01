defmodule Cldr.LanguageTag.T do
  @moduledoc """
  Defines the struct for the BCP 47 `t`
  extension.

  """

  import Cldr.LanguageTag, only: [empty?: 1]

  @fields Cldr.Validity.T.fields()

  typespec =
    {:%, [],
     [
       {:__MODULE__, [], Cldr.LanguageTag.T},
       {:%{}, [], Enum.map(@fields, fn f -> {f, {:atom, [], []}} end)}
     ]}

  defstruct @fields

  @typedoc """
  Defines the [BCP 47 `t` extension](https://unicode-org.github.io/cldr/ldml/tr35.html#t_Extension)
  of a `t:Cldr.LanguageTag`.

  """
  @type t :: unquote(typespec)

  @doc false
  def canonicalize_transform_keys(%Cldr.LanguageTag{transform: transform} = language_tag)
      when transform == %{} do
    {:ok, language_tag}
  end

  def canonicalize_transform_keys(%Cldr.LanguageTag{transform: transform} = language_tag) do
    with {:ok, transform} <- validate_keys(transform) do
      {:ok, Map.put(language_tag, :transform, struct(__MODULE__, transform))}
    end
  end

  # Standalone attributes are not supported
  # in this implementation and they are ignored
  defp validate_keys(locale) do
    Enum.reduce_while(locale, {:ok, %{}}, fn
      {:attributes, _value}, {:ok, acc} ->
        {:cont, {:ok, acc}}

      {key, value}, {:ok, acc} ->
        case Cldr.Validity.T.decode(key, value) do
          {:ok, {key, value}} -> {:cont, {:ok, Map.put(acc, key, value)}}
          other -> {:halt, other}
        end
    end)
  end

  @doc false
  def encode(%__MODULE__{} = t_extension) do
    for field <- @fields -- [:language], value = Map.get(t_extension, field), !is_nil(value) do
      Cldr.Validity.T.encode(field, value)
    end
    |> Enum.sort()
  end

  @doc false
  def to_string(%__MODULE__{} = t_extension) do
    {_, language} = Cldr.Validity.T.encode(:language, t_extension.language)

    params =
      t_extension
      |> encode()
      |> Enum.map(fn {k, v} -> "#{k}-#{v}" end)
      |> Enum.join("-")

    [language, params]
    |> Enum.reject(&empty?/1)
    |> Enum.join("-")
  end

  @doc false
  def to_string(locale) when locale == %{} do
    ""
  end

  def display_name(language_tag, in_locale) do
    module = Module.concat(in_locale.backend, :Locale)
    {:ok, display_names} = module.display_names(in_locale)
    fields = Cldr.Validity.T.field_mapping() |> Enum.sort()

    for {_key, field} <- fields, !is_nil(Map.get(language_tag, field)) do
      [display_field(field, display_names), display_value(language_tag, field, display_names)]
      |> format_key_type(display_names)
    end
    |> join_field_values(display_names)
  end

  def format_key_type(key_value, display_values) do
    display_pattern = get_in(display_values, [:locale_display_pattern, :locale_key_type_pattern])
    Cldr.Substitution.substitute(key_value, display_pattern)
  end

  defp display_field(field, display_names) do
   get_in(display_names, [:keys, field])
  end

  defp display_value(language_tag, field, display_names) do
    value =  Map.fetch!(language_tag, field)
    get_in(display_names, [:types, field, value])
  end

  def join_field_values(fields, display_names) do
    join_pattern = get_in(display_names, [:locale_display_pattern, :locale_separator])
    Enum.reduce(fields, &Cldr.Substitution.substitute([&2, &1], join_pattern))
  end

  defimpl String.Chars do
    def to_string(locale) do
      Cldr.LanguageTag.T.to_string(locale)
    end
  end

  defimpl Cldr.LanguageTag.Chars do
    def to_string(locale) do
      Cldr.LanguageTag.T.to_string(locale)
    end
  end
end
