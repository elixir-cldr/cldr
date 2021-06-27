defmodule Cldr.Consolidate.Bcp47 do
  @moduledoc false

  @u_files [
    "collation.xml",
    "calendar.xml",
    "currency.xml",
    "measure.xml",
    "number.xml",
    "segmentation.xml",
    "timezone.xml",
    "variant.xml"
  ]

  @t_files [
    "transform.xml",
    "transform_hybrid.xml",
    "transform_ime.xml",
    "transform_keyboard.xml",
    "transform_mt.xml",
    "transform-destination.xml"
  ]

  @bcp47_dir "bcp47"

  def consolidate() do
    consolidate(:u)
    consolidate(:t)
  end

  def consolidate(:u) do
    path = Path.join(Cldr.Consolidate.consolidated_output_dir(), [@bcp47_dir, "/u.json"])

    Enum.reduce(@u_files, [], fn file, acc ->
      acc ++ extract(:u, file)
    end)
    |> Enum.map(&flatten_u_list/1)
    |> Map.new()
    |> split_timezone_names()
    |> Cldr.Consolidate.save_file(path)

    Cldr.Consolidate.assert_package_file_configured!(path)
  end

  def consolidate(:t) do
    path = Path.join(Cldr.Consolidate.consolidated_output_dir(), [@bcp47_dir, "/t.json"])

    Enum.reduce(@t_files, [], fn file, acc ->
      acc ++ extract(:t, file)
    end)
    |> Enum.map(&flatten_t_list/1)
    |> Map.new()
    |> Cldr.Consolidate.save_file(path)

    Cldr.Consolidate.assert_package_file_configured!(path)
  end

  defp extract(:u, file) do
    import SweetXml

    Cldr.Consolidate.download_data_dir()
    |> Path.join([@bcp47_dir, "/#{file}"])
    |> File.read!()
    |> String.replace(~r/<!DOCTYPE.*>\n/, "")
    |> xpath(~x"//keyword/key"l,
      name: ~x"./@name"s,
      valid: [~x"./type"l, name: ~x"./@name"s, alias: ~x"./@alias"s]
    )
  end

  defp extract(:t, file) do
    import SweetXml

    Cldr.Consolidate.download_data_dir()
    |> Path.join([@bcp47_dir, "/#{file}"])
    |> File.read!()
    |> String.replace(~r/<!DOCTYPE.*>\n/, "")
    |> xpath(~x"//keyword/key"l,
      name: ~x"./@name"s,
      valid: [~x"./type"l, name: ~x"./@name"s]
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

  defp flatten_t_list(%{name: name, valid: valid}) do
    {name, flatten_t_valid(valid)}
  end

  defp flatten_t_valid(list) do
    Enum.map(list, fn %{name: name} -> name end)
  end

  defp split_timezone_names(map) do
    tz =
      map
      |> Map.fetch!("tz")
      |> Enum.map(fn
        {k, nil} -> {k, nil}
        {k, v} -> {k, String.split(v)}
      end)
      |> Map.new()

    Map.put(map, "tz", tz)
  end
end
