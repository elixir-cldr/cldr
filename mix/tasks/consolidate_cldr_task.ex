if File.exists?(Cldr.Config.download_data_dir()) && Code.ensure_loaded?(Cldr.Consolidate) do
  defmodule Mix.Tasks.Cldr.Consolidate do
    @moduledoc """
    Mix task to consolidate the cldr data into a set of files, one file per
    CLDR locale.
    """

    use Mix.Task

    @shortdoc "Consolidate cldr json data into a single per-locale set of files"

    @doc false
    def run(_) do
      System.put_env("DEV", "true")
      Cldr.Consolidate.consolidate_locales()
    end
  end
end
