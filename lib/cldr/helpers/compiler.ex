defmodule Cldr.Locale.Cache do
  @moduledoc false

  use GenServer
  require Logger

  @table_name :cldr_locales
  @gen_server_name :cldr_locale_cache
  # Client

  def start(args \\ []) do
    GenServer.start(__MODULE__, args, name: @gen_server_name)
  end

  def get_locale(locale, path) do
    if compiling?() and not gen_server_started?() do
      {:ok, _pid} = Cldr.Locale.Cache.start
    end

    GenServer.call(@gen_server_name, {:get_locale, locale, path})
  end

  # Server (callbacks)

  def init(_args) do
    # Create the ets table and return its reference
    # as the state.  State therefore is only the
    # reference to the ets table we use for caching
    create_ets_table!()
    {:ok, @table_name}
  end

  def handle_call({:get_locale, locale, path}, _from, state) do
    {:reply, do_get_locale(locale, path), state}
  end

  def handle_call(request, from, state) do
    # Call the default implementation from GenServer
    super(request, from, state)
  end

  def handle_cast(request, state) do
    super(request, state)
  end

  def compiling? do
    case Process.get(:elixir_compiler_pid) do
      nil -> false
      pid when is_pid(pid) -> true
    end
  end

  def gen_server_started? do
    case Process.whereis(@gen_server_name)  do
      nil -> false
      pid when is_pid(pid) -> true
    end
  end

  defp do_get_locale(locale, path) do
    case :ets.lookup(@table_name, locale) do
      [{^locale, locale_data}] ->
        # Logger.debug "#{inspect self()}:  Found cached locale #{inspect locale}"
        locale_data

      [] ->
        locale_data = Cldr.Config.do_get_locale(locale, path)

        try do
          :ets.insert(@table_name, {locale, locale_data})
          # Logger.debug "#{inspect self()}:  Inserted #{inspect locale} into :ets"
        rescue ArgumentError ->
          nil
          # This may actually happen because of timing conditions: someone else may
          # have inserted behind our back.  But since we've now already generated
          # the locale again just use it.
          # Logger.debug "#{inspect self()}:  Could not insert locale #{inspect locale} into :ets."
        end
        locale_data
    end
  end

  # We assign the compiler pid as the heir for our table so
  # that the table doesn't die with each compilation thread
  # This is undoubtedly hacky.
  defp create_ets_table! do
    case :ets.info(@table_name) do
      :undefined ->
        :ets.new(@table_name, [:named_table, {:read_concurrency, true}])
        # Logger.debug "#{inspect self()}:  Created :ets table"
      _ ->
        :ok
    end
  end

end