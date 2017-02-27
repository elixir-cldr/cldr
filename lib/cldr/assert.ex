defmodule Cldr.Assert do
  @moduledoc false

  @doc false
  def package_file_configured!(path) do
    [_, path] = String.split(path, "/priv/")
    path = "priv/" <> path

    if path in Mix.Project.config[:package][:files] do
      :ok
    else
      raise "Path #{path} is not in the package definition"
    end
  end
end