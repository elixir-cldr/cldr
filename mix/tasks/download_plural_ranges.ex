if File.exists?(Cldr.Config.download_data_dir()) do
  defmodule Mix.Tasks.Cldr.Download.PluralRanges do
    @moduledoc """
    Downloads the pluralRanges.xml file from CLDR
    """

    use Mix.Task
    require Logger

    @shortdoc "Downloads the pluralRanges.xml file from CLDR"

    @url 'https://unicode.org/Public/cldr/'
    @plural_range 'common/supplemental/pluralRanges.xml'
    @core 'core.zip'
    @output_file Path.join(Cldr.Config.download_data_dir(), "plural_ranges.xml")

    def run(_) do
      with {:ok, content} <- download(url()),
           :ok <- File.write(to_string(@core), content),
           {:ok, [{@plural_range, plural_ranges}]} <-
             :zip.unzip(@core, [:memory, {:file_list, [@plural_range]}]) do
        File.write!(@output_file, plural_ranges)
        Logger.info("Saved #{@plural_range} to #{@output_file}")
        File.rm!(to_string(@core))
      else
        {:error, reason} -> {:error, "Unable to write #{@output_file}: #{inspect reason}"}
      end
    end

    @doc false
    def download(url) do
      case :httpc.request(url) do
        {:ok, {{_version, 200, 'OK'}, _headers, body}} ->
          Logger.info("Downloaded pluralRanges.xml")
          {:ok, body}

        {_, {{_version, code, message}, _headers, _body}} ->
          Logger.error(
            "Failed to download pluralRanges.xml from #{url()}. " <>
              "HTTP Error: (#{code}) #{inspect(message)}"
          )

          {:error, code}

        {:error, {:failed_connect, [{_, {host, _port}}, {_, _, sys_message}]}} ->
          Logger.error(
            "Failed to connect to #{inspect(host)} to download " <>
              "pluralRanges.xml. Reason: #{inspect(sys_message)}"
          )

          {:error, sys_message}
      end
    end

    def url do
      @url ++ version() ++ '/' ++ @core
    end

    defp version do
      case Cldr.version() do
        {major, 0, _} -> Integer.to_charlist(major)
        {major, minor, _} -> Integer.to_charlist(major) ++ '.' ++ Integer.to_charlist(minor)
      end
    end
  end
end
