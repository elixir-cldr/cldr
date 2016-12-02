defmodule Mix.Tasks.Cldr.Download do
  @moduledoc """
  Downloads the latest version of the CLDR repository and then
  unzips the resulting files.  The data is stored in the `./downloads`
  directory of the `ex_cldr` package.

  The `./downloads` directory is created if it does not exist.  It is
  also added to the project's `.gitignore` file.
  """

  use Mix.Task

  @shortdoc "Download the latest CLDR data from Unicode and convert to json"

  @download_url    "http://unicode.org/Public/cldr/latest"
  @required_files  ["core.zip", "tools.zip", "keyboards.zip"]
  @download_dir    "downloads"
  @destination_dir Path.join(Cldr.Config.cldr_home(), @download_dir)
  @need_utils      ["wget"]

  @doc """
  Runs the `cldr.download` Mix task to download and process updates to the
  CLDR data repository.
  """
  def run(_) do
    check_utils(@need_utils)
    IO.puts "Downloading CLDR Repository from the Unicode Consortium."
    Cldr.Downloader.download(@download_url, @required_files, @destination_dir)
  end

  defp check_utils(utils) do
    Enum.each utils, fn util ->
      case System.cmd("which", [util]) do
        {_path, 0} ->
          :ok
        {_, _code} ->
          raise RuntimeError, "Required tool #{inspect util} could not " <>
          "be found.  Please install it or put it in the path."
      end
    end
  end
end

