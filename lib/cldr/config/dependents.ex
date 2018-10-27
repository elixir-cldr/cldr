defmodule Cldr.Config.Dependents do
  @moduledoc false

  @doc """
  Returns a list of apps that depend on ex_cldr
  """
  def cldr_provider_modules do
    Mix.Project.deps_paths
    |> Map.to_list
    |> cldr_provider_modules
    |> List.flatten
    |> Enum.uniq
  end

  defp cldr_provider_modules({app, _path}) do
    [dep] = Mix.Dep.filter_by_name([app], Mix.Dep.cached())

    Mix.Dep.in_dependency dep, fn _module ->
      if mfa = Keyword.get(Mix.Project.get!.project, :cldr_provider) do
        [mfa, cldr_provider_modules()]
      else
        cldr_provider_modules()
      end
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

end
