if Cldr.Config.production_data_location() do
  defmodule Mix.Tasks.Cldr.Download.IsoCurrency do
    @moduledoc """
    Downloads the ISO Currency codes from the ISO site
    """

    use Mix.Task
    require Logger

    @shortdoc "Download ISO Currency codes and definitions"

    @url "https://www.six-group.com/dam/download/financial-information/data-center/iso-currrency/lists/list-one.xml"
    @output_file_name Path.join(Cldr.Config.download_data_dir(), "iso_currencies.xml")

    @doc false
    def run(_) do
      case Cldr.Http.get(@url) do
        {:ok, body} ->
          File.write(@output_file_name, body)
          Logger.info("Downloaded current ISO currency codes to #{inspect(@output_file_name)}")

        other ->
          other
      end
    end
  end
end
