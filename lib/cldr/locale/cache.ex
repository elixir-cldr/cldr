defmodule Cldr.Locale.Cache do
  @moduledoc false

  # Caches locales in an :ets table
  # during compilation to improve performance

  use GenServer
  require Logger

  alias Cldr.Locale.Loader

  @table_name :cldr_locales
  @gen_server_name :cldr_locale_cache

  # @timeout 5_000

  # Client

  def start(args \\ []) do
    GenServer.start(__MODULE__, args, name: @gen_server_name)
  end

  def get_locale(locale, path) do
    ensure_genserver_started!()
    do_get_locale(locale, path)
  end

  def get_language_tag(locale) do
    ensure_genserver_started!()
    do_get_language_tag(locale)
  end

  def compiling? do
    # TODO: When we depend on Elixir v1.11+, remove function_exported and elixir_compiler_pid
    process_alive?(:can_await_module_compilation?) ||
			process_alive?(:elixir_compiler_pid) ||
			process_alive?(:cldr_locale_cache)
  end

  defp process_alive?(:can_await_module_compilation?) do
    Code.ensure_loaded?(Code) &&
      function_exported?(Code, :can_await_module_compilation?, 0) &&
	    apply(Code, :can_await_module_compilation?, [])
  end

  defp process_alive?(name) do
    case Process.get(name) do
      nil -> false
      pid when is_pid(pid) -> true
    end
  end

  def put_all_language_tags(language_tags) do
    for {locale, language_tag} <- language_tags do
      :ets.insert(@table_name, {{:tag, locale}, language_tag})
    end
  end

  defp ensure_genserver_started! do
    if compiling?() and not gen_server_started?() do
      Cldr.maybe_log("Starting the compiler locale cache")

      case start() do
        {:ok, _pid} -> :ok
        {:error, {:already_started, _pid}} -> :ok
      end
    end
  end

  # Server (callbacks)

  def init(_args) do
    # Create the ets table and return its reference
    # as the state.  State therefore is only the
    # reference to the ets table we use for caching
    create_ets_table!()
    all_language_tags = Cldr.Config.all_language_tags()
    put_all_language_tags(all_language_tags)
    Process.flag(:trap_exit, true)
    {:ok, @table_name}
  end

  def handle_call({:get_locale, locale_name, path}, _from, state) do
    locale = do_get_locale(locale_name, path)
    {:reply, locale, state}
  end

  # handle the trapped exit call
  def handle_info({:EXIT, _from, reason}, state) do
    Cldr.maybe_log("Compile locale cache received EXIT message: #{inspect(reason)}")
    {:stop, reason, state}
  end

  def terminate(reason, _) do
    Cldr.maybe_log("Compile locale cache is terminating: #{inspect(reason)}")
  end

  def gen_server_started? do
    case Process.whereis(@gen_server_name) do
      nil -> false
      pid when is_pid(pid) -> true
    end
  end

  defp do_get_locale(locale, path) do
    case :ets.lookup(@table_name, locale) do
      [{^locale, locale_data}] ->
        Cldr.maybe_log("Compiler locale cache: Hit for locale #{inspect(locale)}.")
        locale_data

      [] ->
        Cldr.maybe_log(
          "Compiler locale cache: Miss for #{inspect(locale)}. " <>
            "Reading and decoding the locale file."
        )

        locale_data = Loader.do_get_locale(locale, path, false)

        try do
          :ets.insert(@table_name, {locale, locale_data})
        rescue
          ArgumentError ->
            nil
            # This may actually happen because of timing conditions: someone else may
            # have inserted behind our back.  But since we've now already generated
            # the locale again just use it.
            Cldr.maybe_log(
              "Compiler locale cache: Error: Could not insert " <>
                "locale #{inspect(locale)} into cache. Assuming locale is already cached."
            )
        end

        locale_data

      other ->
        raise RuntimeError, inspect(other)
    end
  rescue ArgumentError ->
    # We can very occasionally get an exception when the gen_server
    # is started but before the table is created and another thread
    # tries to get a locale. In this case we just get the locale manually
    Loader.do_get_locale(locale, path, false)
  end

  defp do_get_language_tag(locale) do
    case :ets.lookup(@table_name, {:tag, locale}) do
      [{{:tag, ^locale}, language_tag}] ->
        Cldr.maybe_log("Compiler language tag cache: Hit for locale #{inspect(locale)}.")
        language_tag

      [] ->
        # A new locale for which there is no precomputed language tag yet
        # In fact that's probably what we're about to do later on - create the
        # precomputed tag.
        Cldr.maybe_log("Compiler language tag cache miss for locale #{inspect(locale)}.")
        nil
    end
  end

  # We assign the compiler pid as the heir for our table so
  # that the table doesn't die with each compilation thread
  # This is undoubtedly hacky.
  defp create_ets_table! do
    case :ets.info(@table_name) do
      :undefined ->
        :ets.new(@table_name, [:named_table, :public, {:read_concurrency, true}])

        Cldr.maybe_log("Compiler locale cache: Created cache #{inspect(@table_name)} in :ets")

      _ ->
        :ok
    end
  end
end
