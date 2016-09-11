defmodule Cldr.Downloader do
  @moduledoc """
  Downloads the CLDR repositoey from the Unicode consortium.

  The files are downloaded `./data` directory, unzipped and
  converted to JSON.
  """

  @doc """
  Downloads the CLDR repository files.

  One task for per file is created which then fetches the
  file and unzips it.  This strategy works because there are
  less than 5 files to be downloaded.

  * `base_url` is the URL of the Unicode CLDR server

  * `required_files` is a list of the files to be downloaded

  * `destination_dir` is the directory of the download destination
  """
  def download(base_url, required_files, destination_dir) do
    ensure File.mkdir(destination_dir), destination_dir
    add_dir_to_gitignore(destination_dir)

    required_files
    |> Enum.map(&Task.async(fn -> fetch_and_unzip_file(base_url, destination_dir, &1) end))
    |> Enum.map(&Task.await(&1, 100_000))
  end

  @doc """
  Adds the data directory to the `.gitignore` file of the project
  if it does not exist.

  * `destination_dir` is the name of the data dir, `./data`
  """
  @gitignore ".gitignore"
  def add_dir_to_gitignore(destination_dir) do
    ignore_path = destination_dir
    |> String.split(Cldr.Config.app_home())
    |> Enum.reverse
    |> hd

    case System.cmd("grep", ["#{ignore_path}", @gitignore]) do
      {_, 1} ->
        {:ok, file} = File.open(@gitignore, [:append])
        IO.binwrite(file, "#{ignore_path}\n")
        File.close file
      {_, 0} ->
        :ok
      {_, code} ->
        raise RuntimeError, "Couldn't add #{inspect ignore_path} to "  <>
        ".gitignore. Error code #{inspect code} was returned."
    end
  end

  @doc """
  Uses `wget` to retrieve the latest version of the CLDR repository
  and stores it in the `./data` directory.

  * `download_url` is the url of the Unicode CLDR repository

  * `destination_dir` is the location to store the file.  Usually
  `./data`

  * `file` is the name of the file to be downloaded from the server
  """
  def fetch_and_unzip_file(download_url, destination_dir, file) do
    url = download_url <> "/" <> file
    case System.cmd("wget", [url, "-q", "-N"], cd: destination_dir) do
    {_, 0} ->
      fname = String.to_charlist(destination_dir <> "/" <> file)
      case :zip.unzip(fname, cwd: destination_dir) do
        {:error, code} ->
          raise RuntimeError, "Could not unzip file #{file}.  Error " <>
          inspect(code) <> " was returned."
        {:ok, files} ->
          IO.puts "Downloaded #{inspect file} to #{inspect destination_dir} " <>
          "and unzipped #{Enum.count(files)} files."
          :ok
      end
    {_, code} ->
      raise RuntimeError, "Error downloading #{inspect file}.  " <>
      "Exited with code #{inspect code} files."
    end
  end

  @doc """
  Converts the CLDR repository from XML to JSON using the Unicode
  java-based utility `ldml2json`.

  * `download_dir` is the location of the downloaded repository

  * `destination_dir` is the destination for the converted files
  """
  def convert_to_json(download_dir, destination_dir) do
    args = ["-DCLDR_DIR=#{download_dir}", "-jar",
            "#{download_dir}/tools/java/cldr.jar", "ldml2json",
            "-d", destination_dir,
            "-p", "true", "-r", "true", "-t"]
    System.cmd("java", args ++ ["main"])
    System.cmd("java", args ++ ["supplemental"])
  end

  def remove_package_files(data_dir) do
    args1 = [data_dir, "-name", "package.json", "-exec", "rm", "-rf", "{}", "\;"]
    args2 = [data_dir, "-name", "bower.json", "-exec", "rm", "-rf", "{}", "\;"]

    System.cmd("find", args1)
    System.cmd("find", args2)
  end


  def ensure(:ok, _dir), do: :ok
  def ensure({:error, :eexist}, _dir), do: :ok
  def ensure(error, dir) do
    raise RuntimeError, "#{inspect error}: Could not create #{inspect dir}"
  end
end