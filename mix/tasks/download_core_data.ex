if File.exists?(Cldr.Config.download_data_dir()) do
  defmodule Mix.Tasks.Cldr.Download.CoreData do
    @moduledoc """
    Downloads the measure.xml, pluralRanges.xml and timezones.xml files from CLDR
    """

    use Mix.Task
    require Logger

    @shortdoc "Downloads measure.xml, pluralRanges.xml and timezones.xml files from CLDR"

    @url 'https://unicode.org/Public/cldr/'
    @core 'core.zip'

    @plural_range 'common/supplemental/pluralRanges.xml'
    @timezones 'common/bcp47/timezone.xml'
    @measurement_systems 'common/bcp47/measure.xml'

    @plural_ranges_output_file Path.join(Cldr.Config.download_data_dir(), "plural_ranges.xml")
    @timezones_output_file Path.join(Cldr.Config.download_data_dir(), "timezones.xml")
    @measurement_systems_output_file Path.join(Cldr.Config.download_data_dir(), "measurement_systems.xml")

    def run(_) do
      with {:ok, content} <- download(url()),
           :ok <- File.write(to_string(@core), content),
           {:ok, [{@measurement_systems, measurement_systems}, {@timezones, timezones}, {@plural_range, plural_ranges}]} <-
             :zip.unzip(@core, [:memory, {:file_list, [@measurement_systems, @plural_range, @timezones]}]) do
        File.write!(@plural_ranges_output_file, plural_ranges)
        Logger.info("Saved #{@plural_range} to #{@plural_ranges_output_file}")

        File.write!(@timezones_output_file, timezones)
        Logger.info("Saved #{@timezones} to #{@timezones_output_file}")

        File.write!(@measurement_systems_output_file, measurement_systems)
        Logger.info("Saved #{@measurement_systems} to #{@measurement_systems_output_file}")

        File.rm!(to_string(@core))
      else
        {:error, reason} -> IO.inspect(reason)
      end
    end

    @doc false
    def download(url) do
      case :httpc.request(url) do
        {:ok, {{_version, 200, 'OK'}, _headers, body}} ->
          Logger.info("Downloaded CLDR core data")
          {:ok, body}

        {_, {{_version, code, message}, _headers, _body}} ->
          Logger.error(
            "Failed to download CLDR core data from #{url()}. " <>
              "HTTP Error: (#{code}) #{inspect(message)}"
          )

          {:error, code}

        {:error, {:failed_connect, [{_, {host, _port}}, {_, _, sys_message}]}} ->
          Logger.error(
            "Failed to connect to #{inspect(host)} to download " <>
              "CLDR core data. Reason: #{inspect(sys_message)}"
          )

          {:error, sys_message}
      end
    end

    def url do
      @url ++ version() ++ '/' ++ @core
    end

    @dialyzer {:nowarn_function, version: 0}
    defp version do
      case Cldr.version() do
        {major, 0, _} -> Integer.to_charlist(major)
        {major, minor, _} -> Integer.to_charlist(major) ++ '.' ++ Integer.to_charlist(minor)
      end
    end
  end
end
