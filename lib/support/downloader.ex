defmodule Cldr.Downloader do
  def download(base_url, required_files, destination_dir) do
    test File.mkdir(destination_dir), destination_dir
    add_dir_to_gitignore(destination_dir)

    required_files
    |> Enum.map(&Task.async(fn -> fetch_and_unzip_file(base_url, destination_dir, &1) end))
    |> Enum.map(&Task.await(&1, 100_000))
  end

  def add_dir_to_gitignore(destination_dir) do
    ignore_path = "/" <> destination_dir
    |> String.split("/")
    |> Enum.reverse
    |> Enum.slice(1, 2)
    |> Enum.reverse
    |> Enum.join("/")
    IO.puts ignore_path
    case System.cmd("grep", ["/#{ignore_path}", ".gitignore"]) do
      {_, 1} ->
        {:ok, file} = File.open ".gitignore", [:append]
        IO.binwrite(file, "\n#{ignore_path}\n")
        File.close file
      {_, 0} ->
        :ok
      {_, code} ->
        raise RuntimeError, "Couldn't add #{inspect ignore_path} to "  <>
        ".gitignore. Error code #{inspect code} was returned."
    end
  end

  def fetch_and_unzip_file(download_url, file, destination_dir) do
    url = download_url <> "/" <> file
    case System.cmd("wget", [url, "-q", "-N"], cd: destination_dir) do
    {_, 0} ->
      fname = String.to_charlist(destination_dir <> "/" <> file)
      case :zip.unzip(fname, cwd: destination_dir) do
        {:error, code} ->
          raise RuntimeError, "Could not unzip file #{file}.  Error " <>
          inspect(code) <> " was returned."
        :ok ->
          :ok
      end
    {_, code} ->
      raise RuntimeError, "Error donwloading #{inspect file}.  " <>
      "Exited with code #{inspect code}"
    end
  end

  def test(:ok, _dir), do: :ok
  def test({:error, :eexist}, _dir), do: :ok
  def test(error, dir) do
    raise RuntimeError, "#{inspect error}: Could not create #{inspect dir}"
  end
end