defmodule Mix.Tasks.Cldr.Install do
  @moduledoc """
  Installs the cldr core data and configured locales into the application.  By
  default it installs into the ./priv/cldr directory.
  """

  use Mix.Task

  @shortdoc "Consolidate cldr json data into a single per-locale set of files"

  def run(_) do
    Cldr.Install.install_cldr_core
    Cldr.Install.install_known_locales
  end

end

