defmodule Cldr.Locale.Cache do
  @moduledoc false

  use GenServer
  require Logger

  @table_name :cldr_locales
  @gen_server_name :cldr_locale_cache

  # @timeout 5_000

  # Client

  def start(args \\ []) do
    GenServer.start(__MODULE__, args, name: @gen_server_name)
  end

  def get_locale(locale, path) do
    if compiling?() and not gen_server_started?() do
      case Cldr.Locale.Cache.start() do
        {:ok, _pid} -> :ok
        {:error, {:already_started, _pid}} -> :ok
      end
    end

    # GenServer.call(@gen_server_name, {:get_locale, locale, path}, @timeout)
    do_get_locale(locale, path)
  end

  # Server (callbacks)

  def init(_args) do
    # Create the ets table and return its reference
    # as the state.  State therefore is only the
    # reference to the ets table we use for caching
    create_ets_table!()
    {:ok, @table_name}
  end

  def handle_call({:get_locale, locale_name, path}, _from, state) do
    locale = do_get_locale(locale_name, path)
    {:reply, locale, state}
  end

  def terminate(_, _) do
    IO.inspect(:terminating)
  end

  def compiling? do
    case Process.get(:elixir_compiler_pid) do
      nil -> false
      pid when is_pid(pid) -> true
    end
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

        locale_data = Cldr.Config.do_get_locale(locale, path, false)

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
