defmodule Cldr.CanonicalLocaleGenerator do
  def data do
    Path.join(__DIR__, "../support/data/locale_canonicalization.txt")
    |> Path.expand()
    |> File.read!()
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.reject(fn {elem, _index} -> String.starts_with?(elem, "#") end)
    |> Enum.reject(fn {elem, _index} -> elem == "" end)
    |> Enum.map(fn {l, index} ->
      l
      |> String.split(";")
      |> Enum.map(&String.trim/1)
      |> Enum.map(&Cldr.Locale.locale_name_from_posix/1)
      |> List.insert_at(0, index)
    end)
  end
end
