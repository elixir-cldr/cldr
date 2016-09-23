defmodule Mix.Tasks.Cldr.Convert do
  @moduledoc """
  Downloads the latest version of the CLDR repository and then
  unzips the resulting files.  The data is stored in the `./downloads`
  directory of the `ex_cldr` package.

  The `./downloads` directory is created if it does not exist.  It is
  also added to the project's `.gitignore` file.
  """

  use Mix.Task

  @shortdoc "Convert downloaded CLDR data from XML to json"

  @download_dir    "downloads"
  @destination_dir Path.join(Cldr.Config.cldr_home(), @download_dir)
  @need_utils      ["java", "find", "rm"]
  @data_dir        "./data"

  @doc """
  Runs the `cldr.download` Mix task to download and process updates to the
  CLDR data repository.
  """
  def run(_) do
    check_utils(@need_utils)
    IO.puts "Converting CLDR XML files to json format.  This will take tens of minutes."
    Cldr.Downloader.convert_to_json(@destination_dir, @data_dir)

    # Remove bower and package json files since we don't need them
    Cldr.Downloader.remove_package_files(@data_dir)
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

