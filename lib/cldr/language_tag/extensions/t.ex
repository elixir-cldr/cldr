defmodule Cldr.LanguageTag.T do
  alias Cldr.LanguageTag.Parser

  @transform_map %{
    "m0" => :mechanism,
    "s0" => :source,
    "d0" => :destination,
    "i0" => :input_method,
    "k0" => :keyboard,
    "t0" => :machine,
    "h0" => :hybrid,
    "x0" => :private
  }

  defp transform_key_map do
    @transform_map
  end

  def canonicalize_transform_keys(%Cldr.LanguageTag{transform: nil} = language_tag) do
    language_tag
  end

  def canonicalize_transform_keys(%Cldr.LanguageTag{transform: locale} = language_tag) do
    canon_transform =
      Enum.map(locale, fn {k, v} ->
        if Map.has_key?(transform_key_map(), k) do
          Parser.canonicalize_key(transform_key_map()[k], v)
        else
          {k, v}
        end
      end)
      |> Enum.into(%{})

    Map.put(language_tag, :transform, canon_transform)
  end
end
