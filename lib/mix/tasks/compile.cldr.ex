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

  @manifest ".compile.cldr"

  @callee_references [Cldr.Config]
  @dont_recompile @callee_references ++ [Cldr.Locale.Cache, __MODULE__]

  def run(_args) do
    if configured_locales() != previous_locales() do
      IO.puts(
        "Locale configuration has changed to [" <>
          "#{format_changes(previous_locales(), configured_locales())}]"
      )

      case compile_cldr_files() do
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

  def compile_cldr_files do
    deps = loaded(env: Mix.env())

    apps_to_compile =
      deps
      |> modules_to_compile()
      |> Enum.group_by(fn {app, _module} -> app end, fn {_app, module} -> module end)
      |> print_console_note

    compile_results =
      deps_in_order(deps, apps_to_compile, fn {_dep, app, modules} ->
        build_dir = build_dir(app)
        sources = sources(modules)

        purge_modules(modules, build_dir)
        compile_files(sources, build_dir)
      end)

    return(compile_results)
  end

  def return(list) do
    return_codes =
      Enum.map(list, fn
        # Elixir 1.6+ compiler return
        {_, {:ok, _, _}} ->
          :ok

        # Elixir 1.5 compiler return
        {_, mods} when is_list(mods) ->
          :ok

        _ ->
          :error
      end)

    if Enum.all?(return_codes, &(&1 == :ok)), do: :ok, else: :error
  end

  def print_console_note(apps_to_compile) do
    module_count =
      Enum.reduce(apps_to_compile, 0, fn {_app, modules}, acc -> acc + Enum.count(modules) end)

    if module_count > 0 do
      IO.puts(
        "Recompiling #{module_count} modules from " <> "#{inspect(Map.keys(apps_to_compile))} "
      )
    end

    apps_to_compile
  end

  def deps_in_order(deps, apps, already_done \\ %{}, fun)

  def deps_in_order([], _apps, acc, _fun) do
    acc
  end

  def deps_in_order(deps, apps, already_done, fun) do
    Enum.reduce(deps, already_done, fn dep, acc ->
      acc = deps_in_order(dep.deps, apps, acc, fun)
      app = dep.app

      if app in Map.keys(apps) && app not in Map.keys(acc) do
        Map.put(acc, app, fun.({dep, app, Map.get(apps, app)}))
      else
        acc
      end
    end)
  end

  def modules_to_compile(nil) do
    []
  end

  def modules_to_compile(deps) do
    for dep <- deps do
      callers(dep) ++ modules_to_compile(dep.deps)
    end
    |> List.flatten()
    |> Enum.map(fn
      {app, %{caller_module: caller_module}} -> {app, caller_module}
      {app, caller} -> {app, caller}
    end)
    |> Enum.reject(fn
      {_app, module} when module in @dont_recompile -> true
      _ -> false
    end)
    |> Enum.uniq()
  end

  defp callers(dep) do
    try do
      Mix.Dep.in_dependency(dep, fn _module ->
        Mix.Project.build_structure()

        calls()
        |> Enum.filter(&compile_module?/1)
        |> Enum.map(fn callee -> {dep.app, callee} end)
      end)
    rescue
      File.Error ->
        []
    end
  end

  if Version.compare(System.version(), "1.6.0") in [:gt, :eq] do
    def compile_files(sources, build_dir) do
      Kernel.ParallelCompiler.compile_to_path(sources, build_dir)
    end

    def calls do
      Mix.Tasks.Xref.calls()
    end
  else
    def compile_files(sources, build_dir) do
      Kernel.ParallelCompiler.files_to_path(sources, build_dir)
    end

    def calls do
      pre6_calls()
    end
  end

  def compile_module?(%{callee: {reference, _, _}}) do
    reference in @callee_references
  end

  def purge_modules([], _build_dir) do
    :ok
  end

  def purge_modules([module | modules], build_dir) do
    :code.purge(module)
    :code.delete(module)
    beam_file = build_dir <> "/Elixir." <> inspect(module) <> ".beam"

    case File.rm(beam_file) do
      :ok -> :ok
      {:error, :enoent} -> :ok
      error -> raise "Cldr compiler could not delete #{beam_file}: #{inspect(error)}"
    end

    purge_modules(modules, build_dir)
  end

  def build_dir(dep) do
    loaded_by_name([dep], [])
    |> Map.get(:opts)
    |> Keyword.get(:build)
    |> String.replace_suffix("", "/ebin")
  end

  def loaded(opts) do
    Mix.Dep.Converger.converge(nil, nil, opts, &{&1, &2, &3}) |> elem(0)
  end

  defp loaded_by_name(given, all_deps \\ nil, opts) do
    all_deps = all_deps || loaded(opts)
    apps = Cldr.Map.atomize_keys(given)
    deps = get_deps(all_deps, apps)

    Enum.each(apps, fn app ->
      unless Enum.any?(all_deps, &(&1.app == app)) do
        Mix.raise("Unknown dependency #{app} for environment #{Mix.env()}")
      end
    end)

    hd(deps)
  end

  defp get_deps(all_deps, apps) do
    Enum.filter(all_deps, &(&1.app in apps))
  end

  def sources([]) do
    []
  end

  def sources([module | modules]) do
    if source = source(module) do
      [source | sources(modules)]
    else
      sources(modules)
    end
  end

  def source(module) do
    case Code.ensure_loaded(module) do
      {:module, _} -> List.to_string(module.module_info(:compile)[:source])
      _ -> nil
    end
  end

  def create_manifest(locales \\ []) do
    File.write!(manifest(), :erlang.term_to_binary(locales))
  end

  def configured_locales do
    Cldr.Config.known_locale_names()
  end

  def previous_locales do
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

  # Here is where we simulate the results
  # of Mix.Tasks.Xref.calls/0 which does
  # not exist before Elixir 1.6
  @elixir_manifest ".compile.elixir"
  @references MapSet.new(@callee_references)
  @doc false
  def pre6_calls do
    manifest_path =
      Mix.Project.manifest_path()
      |> Path.join(@elixir_manifest)

    data =
      manifest_path
      |> File.read!()
      |> :erlang.binary_to_term()
      |> Enum.reduce([], fn
        version, acc when is_atom(version) ->
          acc

        {:source, path, _, depends_on, _, _, _, _, _}, acc ->
          if cldr_file?(depends_on, @references) do
            [path | acc]
          else
            acc
          end

        {:module, module, :module, [path], _destination, _}, acc ->
          [{path, module} | acc]

        _other, acc ->
          acc
      end)

    # Now we have a list where the first part is the
    # paths we need and the second part is the module
    # defined in the file we want
    select_paths = Enum.filter(data, fn p -> if is_binary(p), do: true, else: false end)
    potential_modules = Enum.filter(data, fn t -> if is_tuple(t), do: true, else: false end)

    Enum.reduce(potential_modules, [], fn {path, module}, acc ->
      if path in select_paths do
        [
          %{
            callee: {hd(@callee_references), :no_function, 0},
            caller_module: module,
            line: 0,
            file: ""
          }
          | acc
        ]
      else
        acc
      end
    end)
  end

  @doc false
  def cldr_file?(calls, references) do
    MapSet.size(MapSet.intersection(references, MapSet.new(calls))) > 0
  end

  @doc false
  def format_changes(original, current) do
    original
    |> List.myers_difference(current)
    |> colorize_diff
    |> Enum.join(", ")
  end

  defp colorize_diff([]) do
    []
  end

  defp colorize_diff([element | tail]) do
    case element do
      {:eq, items} -> [wrap(items) | colorize_diff(tail)]
      {:del, items} -> [wrap(items, IO.ANSI.red()) | colorize_diff(tail)]
      {:ins, items} -> [wrap(items, IO.ANSI.green()) | colorize_diff(tail)]
    end
  end

  defp wrap(items, colour \\ "") do
    items
    |> Enum.map(fn item -> colour <> inspect(item) <> IO.ANSI.reset() end)
    |> Enum.join(", ")
  end
end
