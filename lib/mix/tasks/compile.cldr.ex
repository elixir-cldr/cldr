defmodule Mix.Tasks.Compile.Cldr do
  use Mix.Task
  @manifest "compile.cldr"

  def run(_args) do
    if configured_locales() != previous_locales() do
      IO.puts "Recompiling parts of Cldr due to a locale configuration change"
      case return(compile_files()) do
        :ok ->
          create_manifest(configured_locales())
          :ok
        _ ->
          :noop
      end
    else
      :noop
    end
  end

  def return(list) do
    codes = Enum.map(list, fn {:ok, _, _} -> :ok; _ -> :error end)
    if Enum.all?(codes, &(&1 == :ok)), do: :ok, else: :error
  end

  def compile_files do
    current_compiler_options = Code.compiler_options
    Code.compiler_options(ignore_module_conflict: true)

    result =
      compile_files(Mix.Dep.loaded(env: Mix.env()))
      |> Enum.group_by(fn {_module, path} -> path end, fn {module, _path} -> module end)
      |> Enum.map(fn {dest, modules} ->
        Kernel.ParallelCompiler.compile_to_path(source(modules), dest)
      end)

    Code.compiler_options(current_compiler_options)
    result
  end

  def source([]) do
    []
  end

  def source([module | modules]) do
    source = case Code.ensure_loaded(module) do
      {:module, _} -> List.to_string(module.module_info(:compile)[:source])
      _ -> nil
    end

    if source do
      [source | source(modules)]
    else
      source(modules)
    end
  end

  def compile_files(nil) do
    []
  end

  def compile_files(deps) do
    for dep <-  deps do
      compile_file(dep) ++ compile_files(dep.deps)
    end
    |> List.flatten
    |> Enum.map(fn {%{caller_module: caller_module}, dest} -> {caller_module, dest} end)
    |> Enum.reject(fn {__MODULE__, _dest} -> true; _ -> false end)
    |> Enum.uniq
  end

  def compile_file(dep) do
    project = dep.app
    path = dep.opts[:dest]
    build_dir = dep.opts[:build]

    Mix.Project.in_project(project, path, fn _module ->
      Mix.Tasks.Xref.calls
      |> Enum.filter(fn %{callee: {Cldr.Config, _, _}} -> true; _ -> false end)
      |> Enum.map(fn callee -> {callee, build_dir} end)
    end)
  end

  def config_path do
    Cldr.Config.module_info(:compile)[:source]
  end

  def manifests, do: [manifest()]
  def manifest do
    Path.join(Mix.Project.manifest_path(), @manifest)
  end

  def configured_locales do
    Cldr.Config.known_locale_names
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

  def create_manifest(locales) do
    File.write!(manifest(), :erlang.term_to_binary(locales))

    config_mtime = File.stat!(config_path()).mtime
    :file.change_time(manifest(), config_mtime)
  end
end