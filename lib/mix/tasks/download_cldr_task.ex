defmodule Mix.Tasks.Cldr.Download do
  @moduledoc """
  Downloads the latest version of the CLDR repository and then
  unzips the resulting files.  The data is stored in the `./data/downloads`
  directory of the `Cldr` package.

  The `./data/downloads` directory is created if it does not exist.  It is
  also added to the project's `.gitignore` file.
  """

  use Mix.Task

  @shortdoc "Download the latest CLDR data and convert to json"

  @download_url    "http://unicode.org/Public/cldr/latest"
  @required_files  ["core.zip", "tools.zip"]
  @download_dir    "downloads"
  @gitignore       "/data/" <> @download_dir
  @destination_dir Path.join(Cldr.Config.data_dir, @download_dir)
  @need_utils      ["wget", "unzip", "java"]

  def run(_) do
    check_utils()
    download_and_unzip_files()
  end

  defp download_and_unzip_files do
    test File.mkdir(@destination_dir), @destination_dir
    add_dir_to_gitignore()

    @required_files
    |> Enum.map(&Task.async(fn -> fetch_and_unzip_file(&1) end))
    |> Enum.map(&Task.await(&1, 100_000))

  end

  def add_dir_to_gitignore do
    case System.cmd("grep", [@gitignore, ".gitignore"]) do
      {_, 1} ->
        {:ok, file} = File.open ".gitignore", [:append]
        IO.binwrite(file, "\n#{@gitignore}\n")
        File.close file
      {_, 0} ->
        :ok
      {_, code} ->
        raise RuntimeError, "Couldn't add #{inspect @gitignore} to "  <>
        ".gitignore. Error code #{inspect code} was returned."
    end
  end

  def check_utils do
    Enum.each @need_utils, fn util ->
      case System.cmd("which", [util]) do
        {_path, 0} ->
          :ok
        {_, _code} ->
          raise RuntimeError, "Required tool #{inspect util} could not " <>
          "be found.  Please install it or put it in the path."
      end
    end
  end

  def fetch_and_unzip_file(file) do
    url = @download_url <> "/" <> file
    case System.cmd("wget", [url, "-q", "-N"], cd: @destination_dir) do
    {_, 0} ->
      fname = String.to_charlist(@destination_dir <> "/" <> file)
      case :zip.unzip(fname, cwd: @destination_dir) do
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