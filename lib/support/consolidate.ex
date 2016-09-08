defmodule Cldr.Consolidate do
  @moduledoc """
  Consolidates all locale-specific information from the CLDR repository into
  one locale-specific file in the ./cldr directory
  """

  def consolidate_locales do
    ensure_output_dir_exists!()
    Cldr.all_locales()
    |> Enum.map(&Task.async(fn -> consolidate_locale(&1) end))
    |> Enum.map(&Task.await(&1, 100_000))
    :ok
  end

  def consolidate_locale(locale) do
    cldr_locale_specific_dirs()
    |> Enum.map(&locale_specific_content(locale, &1))
    |> merge_maps
    |> save_locale(locale)
  end

  def save_locale(content, locale) do
    output_path = Path.join(output_dir(), "#{locale}.json")
    File.write!(output_path, Poison.encode!(content))
  end

  def merge_maps([file_1]) do
    file_1
  end

  def merge_maps([file_1, file_2]) do
    Cldr.Map.deep_merge(file_1, file_2)
  end

  def merge_maps([file | rest]) do
    Cldr.Map.deep_merge(file, merge_maps(rest))
  end

  def locale_specific_content(locale, directory) do
    dir = Path.join(directory, ["main/", locale])

    dir
    |> File.ls!
    |> Enum.map(&Path.join(dir, &1))
    |> Enum.map(&File.read!(&1))
    |> Enum.map(&Poison.decode!(&1))
    |> merge_maps
  end

  def cldr_locale_specific_dirs do
    cldr_directories()
    |> Enum.filter(&locale_specific_dir?/1)
  end

  def locale_specific_dir?(filename) do
    String.ends_with?(filename, "-full")
  end

  def cldr_directories do
    Cldr.data_dir()
    |> File.ls!
    |> Enum.filter(&cldr_dir?/1)
    |> Enum.map(&Path.join(Cldr.data_dir(), &1))
  end

  defp cldr_dir?("common") do
    true
  end

  defp cldr_dir?(filename) do
    String.starts_with?(filename, "cldr-")
  end

  defp ensure_output_dir_exists! do
    case File.mkdir(output_dir()) do
      :ok ->
        :ok
      {:error, :eexist} ->
        :ok
      {:error, code} ->
        raise RuntimeError,
          message: "Couldn't create #{output_dir()}: #{inspect code}"
    end
  end

  defp output_dir do
    Path.join(Cldr.Config.app_home, "data/consolidated")
  end
end