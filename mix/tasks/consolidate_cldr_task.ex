if Cldr.Config.production_data_location() && Cldr.Code.ensure_compiled?(Cldr.Consolidate) do
  defmodule Mix.Tasks.Cldr.Consolidate do
    @moduledoc """
    Mix task to consolidate the cldr data into a set of files, one file per
    CLDR locale.
    """

    use Mix.Task

    @shortdoc "Consolidate CLDR JSON data into a single per-locale set of files"

    @doc false
    def run(_) do
      Cldr.Consolidate.consolidate_locales()
    end
  end
end
