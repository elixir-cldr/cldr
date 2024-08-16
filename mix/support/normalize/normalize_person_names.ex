defmodule Cldr.Normalize.PersonName do
  @moduledoc false

  def normalize(content, locale) do
    content
    |> normalize_person_names(locale)
  end

  def normalize_person_names(content, _locale) do
    person_names =
      content
      |> Map.fetch!("person_names")
      |> Map.delete("sample_name")
      |> Cldr.Map.deep_map(fn
        {k, v} ->
          if (k != "formality" && String.starts_with?(k, "formal")) ||
               String.starts_with?(k, "informal") do
            {String.split(k, "_"), v}
          else
            {String.to_atom(k), v}
          end

        other ->
          other
      end)
      |> Cldr.Map.deep_map(fn
        {k, v} when k in [:addressing, :monogram, :referring] ->
          formats =
            Enum.group_by(v, fn {key, _value} -> hd(key) end, fn {_key, value} -> value end)

          {k, formats}

        other ->
          other
      end)
      |> Cldr.Map.deep_map(fn
        {k, v} when k in ["formal", "informal"] ->
          {String.to_atom(k), Enum.sort(v)}

        {k, v} when k in [:formality, :length] ->
          {k, String.to_atom(v)}

        other ->
          other
      end)

    Map.put(content, "person_names", person_names)
  end
end
