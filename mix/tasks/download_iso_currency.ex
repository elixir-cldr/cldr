if Cldr.Config.production_data_location do
  defmodule Mix.Tasks.Cldr.Download.IsoCurrency do
    @moduledoc """
    Downloads the ISO Currency codes from the ISO site
    """

    use Mix.Task
    require Logger

    @shortdoc "Download ISO Currency codes and definitions"

    @url 'https://www.currency-iso.org/dam/downloads/lists/list_one.xml'
    @output_file_name Path.join(Cldr.Config.download_data_dir(), "iso_currencies.xml")

    @doc false
    def run(_) do
      case :httpc.request(@url) do
        {:ok, {{_version, 200, 'OK'}, _headers, body}} ->
          @output_file_name
          |> File.write!(:erlang.list_to_binary(body))

          Logger.info("Downloaded ISO Currency data")
          {:ok, @output_file_name}

        {_, {{_version, code, message}, _headers, _body}} ->
          Logger.error(
            "Failed to download ISO Currency data from #{@url}. " <>
              "HTTP Error: (#{code}) #{inspect(message)}"
          )

          {:error, code}

        {:error, {:failed_connect, [{_, {host, _port}}, {_, _, sys_message}]}} ->
          Logger.error(
            "Failed to connect to #{inspect(host)} to download " <>
              "ISO Currency data. Reason: #{inspect(sys_message)}"
          )

          {:error, sys_message}
      end
    end
  end
end
