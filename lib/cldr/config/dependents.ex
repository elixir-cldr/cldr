defmodule Cldr.Config.Dependents do
  @moduledoc false

  @doc """
  Returns a list of apps that depend on ex_cldr

  """
  def cldr_provider_modules do
    Mix.Project.deps_paths
    |> Map.to_list
    |> cldr_provider_modules
    |> maybe_add_this_app
    |> List.flatten
    |> Enum.uniq
  end

  if Version.compare(System.version, "1.7.0") == :lt do
    def get_dep(app) do
      [dep] = Mix.Dep.loaded_by_name([app], Mix.Dep.cached())
      dep
    end
  else
    def get_dep(app) do
      [dep] = Mix.Dep.filter_by_name([app], Mix.Dep.cached())
      dep
    end
  end

  defp cldr_provider_modules({app, path}) do
    if File.exists?(path) do
      Mix.Dep.in_dependency get_dep(app), fn _module ->
        if mfa = provider_from_project() do
          [mfa, cldr_provider_modules()]
        else
          cldr_provider_modules()
        end
      end
    else
      []
    end
  end

  defp cldr_provider_modules([]) do
    []
  end

  defp cldr_provider_modules([h]) do
    cldr_provider_modules(h)
  end

  defp cldr_provider_modules([h | t]) do
    [cldr_provider_modules(h), cldr_provider_modules(t)]
  end

  def maybe_add_this_app(deps_list) do
    if mfa = provider_from_project() do
      [mfa, deps_list]
    else
      deps_list
    end
  end

  defp provider_from_project do
    project = Mix.Project.get
    if !is_nil(project) do
      Keyword.get(project.project, :cldr_provider)
    else
      nil
    end
  end

end
