defmodule Cldr.Consolidate.Bcp47 do
  @u_files [
    "collation.xml", "calendar.xml", "currency.xml", "measure.xml",
    "number.xml", "segmentation.xml", "timezone.xml", "variant.xml"
  ]

  @bcp47_dir "bcp47"

  def consolidate() do
    consolidate_u()
  end

  def consolidate_u() do
    path = Path.join(Cldr.Consolidate.consolidated_output_dir(), [@bcp47_dir, "/u.json"])

    Enum.reduce(@u_files, [], fn file, acc ->
      acc ++ extract_u(file)
    end)
    |> Enum.map(&flatten_u_list/1)
    |> Map.new()
    |> Cldr.Consolidate.save_file(path)

    Cldr.Consolidate.assert_package_file_configured!(path)
  end

  defp extract_u(file) do
    import SweetXml

    Cldr.Consolidate.download_data_dir()
    |> Path.join([@bcp47_dir, "/#{file}"])
    |> File.read!()
    |> String.replace(~r/<!DOCTYPE.*>\n/, "")
    |> xpath(~x"//keyword/key"l,
      name: ~x"./@name"s,
      valid: [~x"./type"l,
        name: ~x"./@name"s, alias: ~x"./@alias"s]
    )
  end

  defp flatten_u_list(%{name: name, valid: valid}) do
    {name, flatten_u_valid(valid)}
  end

  defp flatten_u_valid(list) do
    list
    |> Enum.map(fn
      %{name: name, alias: ""} -> {name, nil}
      %{name: name, alias: aliass} -> {name, aliass}
    end)
    |> Map.new()
  end

end