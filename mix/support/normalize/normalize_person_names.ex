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

    Map.put(content, "person_names", person_names)
  end
end
