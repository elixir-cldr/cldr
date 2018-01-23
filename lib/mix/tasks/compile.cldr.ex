defmodule Mix.Tasks.Compile.Cldr do
  @moduledoc """
  Recompiles Cldr modules when the Cldr locale
  configuration changes.

  Cldr defines a lot of compile-time functions based
  upon the configuration in mix.exs.  However since
  Cldr is a dependency it is not automatically recompile
  when the host application configuration changes.

  An additional issue is that dependencies are compiled
  before the host application (as they should be) but
  that means that a host application `Gettext` module
  won't be available and therefore its locales won't be
  configured in Cldr.

  This module implements a `Mix compiler` that is designed
  to execute after the host application is compiled. It then
  detects if the Cldr configuration has changed and if so it:

  * Searches all dependencies to find those modules that
    depend on `Cldr.Config` since that is the module that
    serves Cldr configuration content.

  * Recompiles each of the dependent modules for each of
    app dependencies in the right dependency order

  * Reloads the modules that were recompiled

  Since this compilation happens after the host application
  is compiled, any `Gettext` module will have been compiled
  and its configuraiton is now available to Cldr.

  ## Configuration

  To enable the automatic detection locale configuration
  change and subsequent recompilation and reload, add the
  `[:cldr]` compiler to the `:compilers` section of the
  `mix.exs` project definition:

  For example:
  ```
  def project do
    [
      app: :app_name,
      ...
      compilers: Mix.compilers ++ [:cldr]
    ]
  end
  ```

  """
  use Mix.Task
  require Logger

  @manifest "compile.cldr"

  def run(_args) do
    if configured_locales() != previous_locales() do
      case compile_files() do
        :ok ->
          create_manifest(configured_locales())
        _ ->
          :noop
      end
    else
      :noop
    end
  end

  def manifests, do: [manifest()]
  def manifest do
    Path.join(Mix.Project.manifest_path(), @manifest)
  end

  def create_manifest(locales \\ []) do
    File.write!(manifest(), :erlang.term_to_binary(locales))
  end

  defp return(list) do
    return_codes = Enum.map(list, fn {_, {:ok, _, _}} -> :ok; _ -> :error end)
    if Enum.all?(return_codes, &(&1 == :ok)), do: :ok, else: :error
  end

  defp compile_files do
    saved_compiler_options = Code.compiler_options
    Code.compiler_options(ignore_module_conflict: true)
    deps = Mix.Dep.loaded(env: Mix.env())

    apps_to_compile =
      deps
      |> modules_to_compile()
      |> Enum.group_by(fn {app, _module} -> app end,fn {_app, module} -> module end)
      |> print_console_note

    compile_results =
      deps_in_order deps, apps_to_compile, %{}, fn {app, modules} ->
        Kernel.ParallelCompiler.compile_to_path(sources(modules), build_dir(app))
        |> reload_modules
      end

    Code.compiler_options(saved_compiler_options)
    return(compile_results)
  end

  defp print_console_note(apps_to_compile) do
    module_count = Enum.reduce(apps_to_compile, 0,
      fn {_app, modules}, acc -> acc + Enum.count(modules)
    end)

    if module_count > 0 do
      IO.puts "Recompiling #{module_count} modules from " <>
            "#{inspect Map.keys(apps_to_compile)} " <>
            "due to a locale configuration change"
    end

    apps_to_compile
  end

  defp deps_in_order([], _apps, acc, _fun) do
    acc
  end

  defp deps_in_order(deps, apps, already_done, fun) do
    Enum.reduce deps, already_done, fn dep, acc ->
      acc = deps_in_order(dep.deps, apps, acc, fun)
      app = dep.app

      if app in Map.keys(apps) && app not in Map.keys(acc) do
        Map.put(acc, app, fun.({app, Map.get(apps, app)}))
      else
        acc
      end
    end
  end

  defp modules_to_compile(nil) do
    []
  end

  @callee_reference Cldr.Config
  @dont_recompile [Cldr.Config, Cldr.Locale.Cache, __MODULE__]

  defp modules_to_compile(deps) do
    for dep <-  deps do
      callers(dep) ++ modules_to_compile(dep.deps)
    end
    |> List.flatten
    |> Enum.map(fn {app,
      %{caller_module: caller_module}} -> {app, caller_module}
      {app, caller} -> {app, caller}
    end)
    |> Enum.reject(fn
      {_app, module} when module in @dont_recompile -> true
       _ -> false
    end)
    |> Enum.uniq
  end

  defp callers(dep) do
    try do
      Mix.Dep.in_dependency(dep, fn _module ->
        Mix.Tasks.Xref.calls
        |> Enum.filter(fn %{callee: {@callee_reference, _, _}} -> true; _ -> false end)
        |> Enum.map(fn callee -> {dep.app, callee} end)
      end)
    rescue File.Error ->
      []
    end
  end

  defp reload_modules({:ok, modules, _} = compiler_result) do
    reload_modules(modules)
    compiler_result
  end

  defp reload_modules({:error, _modules, _} = compiler_result) do
    compiler_result
  end

  defp reload_modules([]) do
    nil
  end

  defp reload_modules([module | modules]) do
    reload_module(module)
    reload_modules(modules)
  end

  defp reload_module(module) when is_atom(module) do
    :code.purge(module)
    :code.load_file(module)
  end

  defp build_dir(dep) do
    Mix.Dep.loaded_by_name([dep], [])
    |> hd
    |> Map.get(:opts)
    |> Keyword.get(:build)
    |> String.replace_suffix("","/ebin")
  end

  defp sources([]) do
    []
  end

  defp sources([module | modules]) do
    if source = source(module) do
      [source | sources(modules)]
    else
      sources(modules)
    end
  end

  defp source(module) do
    case Code.ensure_loaded(module) do
      {:module, _} -> List.to_string(module.module_info(:compile)[:source])
      _ -> nil
    end
  end

  defp configured_locales do
    Cldr.Config.known_locale_names
  end

  defp previous_locales do
    case File.read(manifest()) do
      {:error, :enoent} ->
        create_manifest([])
        previous_locales()
      {:ok, ""} ->
        []
      {:ok, binary} ->
        :erlang.binary_to_term(binary)
    end
  end
end