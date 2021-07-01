defmodule Cldr.LanguageTag.U do
  @moduledoc """
  Defines the struct for the BCP 47 `u`
  extension.

  """

  @fields Cldr.Validity.U.fields()

  typespec =
    {:%, [],
     [
       {:__MODULE__, [], Cldr.LanguageTag.U},
       {:%{}, [], Enum.map(@fields, fn f -> {f, {:atom, [], []}} end)}
     ]}

  defstruct @fields

  @typedoc """
  Defines the [BCP 47 `u` extension](https://unicode-org.github.io/cldr/ldml/tr35.html#u_Extension)
  of a `t:Cldr.LanguageTag`.

  """
  @type t :: unquote(typespec)

  @doc false
  def canonicalize_locale_keys(%Cldr.LanguageTag{locale: locale} = language_tag)
      when locale == %{} do
    {:ok, language_tag}
  end

  def canonicalize_locale_keys(%Cldr.LanguageTag{locale: locale} = language_tag) do
    with {:ok, locale} <- validate_keys(locale) do
      {:ok, Map.put(language_tag, :locale, struct(__MODULE__, locale))}
    end
  end

  # Standalone attributes are not supported
  # in this implementation and they are ignored
  defp validate_keys(locale) do
    Enum.reduce_while(locale, {:ok, %{}}, fn
      {:attributes, _value}, {:ok, acc} ->
        {:cont, {:ok, acc}}

      {key, value}, {:ok, acc} ->
        case Cldr.Validity.U.decode(key, value) do
          {:ok, {key, value}} -> {:cont, {:ok, Map.put(acc, key, value)}}
          other -> {:halt, other}
        end
    end)
  end

  def encode(%__MODULE__{} = u_extension) do
    for field <- @fields, value = Map.get(u_extension, field), !is_nil(value) do
      Cldr.Validity.U.encode(field, value)
    end
    |> Enum.sort()
  end

  @doc false
  def to_string(%__MODULE__{} = u_extension) do
    u_extension
    |> encode()
    |> Enum.map(fn {k, v} -> "#{k}-#{v}" end)
    |> Enum.join("-")
  end

  @doc false
  def to_string(locale) when locale == %{} do
    ""
  end

  defimpl String.Chars do
    def to_string(locale) do
      Cldr.LanguageTag.U.to_string(locale)
    end
  end

  defimpl Cldr.LanguageTag.Chars do
    def to_string(locale) do
      Cldr.LanguageTag.U.to_string(locale)
    end
  end
end
