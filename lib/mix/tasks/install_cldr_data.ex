defmodule Mix.Tasks.Cldr.Install.Locales do
  @moduledoc """
  Installs the cldr core data and configured locales into the application.  By
  default it installs into the ./priv/cldr directory.
  """

  use Mix.Task

  @shortdoc "Install all configured `Cldr` locales."

  def run(_) do
    Cldr.Install.install_known_locales
  end

end

