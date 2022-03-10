if Code.ensure_loaded?(Plug) do
  defmodule Cldr.Plug.SetLocale do
    @moduledoc """
    Sets the Cldr and/or Gettext locales derived from the accept-language
    header, a query parameter, a url parameter, a body parameter or the
    session.

    ## Options

      * `:apps` - list of apps for which to set locale.
        See the apps configuration section.

      * `:from` - where in the request to look for the locale.
        The default is `[:session, :accept_language]`. The valid
        options are:
        * `:accept_language` will parse the `accept-language` header
           and finds the best matched configured locale
        * `:path` will look for a locale by examining `conn.path_params`
        * `:query` will look for a locale by examining `conn.query_params`
        * `:body` will look for a locale by examining `conn.body_params`
        * `:cookie` will look for a locale in the request cookie(s)
        * `:session` will look for a locale in the session
        * `:host` will attempt to resolve a locale from the host name top-level
          domain using `Cldr.Locale.locale_from_host/3`

      * `:default` - the default locale to set if no locale is
        found by other configured methods.  It can be a string like "en"
        or a `Cldr.LanguageTag` struct. The default is
        `Cldr.default_locale/1`

      * `:gettext` - the name of the `Gettext` backend module upon which
        the locale will be validated. This option is not required if a
        gettext module is specified in the `:apps` configuration.

      * `:cldr` - the name of the `Cldr` backend module upon which
        the locale will be validated.  This option is not required if a
        gettext module is specified in the `:apps` configuration.

      * `:session_key` - defines the key used to look for the locale
        in the session.  The default is `locale`.

    If a locale is found then `conn.private[:cldr_locale]` is also set.
    It can be retrieved with `Cldr.Plug.SetLocale.get_cldr_locale/1`.

    ## App configuration

    The `:apps` configuration key defines which applications will have
    their locale *set* by this plug.

    `Cldr.Plug.SetLocale` can set the locale for `cldr`, `gettext` or both.
    The basic configuration of the `:app` key is an atom, or list of atoms,
    containing one or both of these app names.  For example:

        apps: :cldr
        apps: :gettext
        apps: [:cldr, :gettext]

    In each of these cases, the locale is set globally
    **for the current process**.

    Sometimes setting the locale for only a specific backend is required.
    In this case, configure the `:apps` key as a keyword list pairing an
    application with the required backend module.  The value `:global` signifies
    setting the local for the global context. For example:

        apps: [cldr: MyApp.Cldr]
        apps: [gettext: MyAppGettext]
        apps: [gettext: :global]
        apps: [cldr: MyApp.Cldr, gettext: MyAppGettext]

    ## Using Cldr.Plug.SetLocale without Phoenix

    If you are using `Cldr.Plug.SetLocale` without Phoenix and you
    plan to use `:path_param` to identify the locale of a request
    then `Cldr.Plug.SetLocale` must be configured *after* `plug :match`
    and *before* `plug :dispatch`.  For example:

        defmodule MyRouter do
          use Plug.Router

          plug :match

          plug Cldr.Plug.SetLocale,
            apps: [:cldr, :gettext],
            from: [:path, :query],
            gettext: MyApp.Gettext,
            cldr: MyApp.Cldr

          plug :dispatch

          get "/hello/:locale" do
            send_resp(conn, 200, "world")
          end
        end

    ## Using Cldr.Plug.SetLocale with Phoenix

    If you are using `Cldr.Plug.SetLocale` with Phoenix and you plan
    to use the `:path_param` to identify the locale of a request then
    `Cldr.Plug.SetLocale` must be configured in the router module, *not*
    in the endpoint module. This is because `conn.path_params` has
    not yet been populated in the endpoint. For example:

        defmodule MyAppWeb.Router do
          use MyAppWeb, :router

          pipeline :browser do
            plug :accepts, ["html"]
            plug :fetch_session
            plug Cldr.Plug.SetLocale,
        	    apps: [:cldr, :gettext],
        	    from: [:path, :query],
        	    gettext: MyApp.Gettext,
        	    cldr: MyApp.Cldr
            plug :fetch_flash
            plug :protect_from_forgery
            plug :put_secure_browser_headers
          end

          scope "/:locale", HelloWeb do
            pipe_through :browser

            get "/", PageController, :index
          end
        end

    ## Examples

        # Will set the global locale for the current process
        # for both `:cldr` and `:gettext`
        plug Cldr.Plug.SetLocale,
          apps:    [:cldr, :gettext],
          from:    [:query, :path, :body, :cookie, :accept_language],
          param:   "locale",
          gettext: GetTextModule,
          cldr:    MyApp.Cldr

        # Will set the backend-only locale for the current process
        # for both `:cldr` and `:gettext`
        plug Cldr.Plug.SetLocale,
          apps:    [cldr: MyApp.Cldr, gettext: GetTextModule],
          from:    [:query, :path, :body, :cookie, :accept_language],
          param:   "locale"

        # Will set the backend-only locale for the current process
        # for `:cldr` and globally for `:gettext`
        plug Cldr.Plug.SetLocale,
          apps:    [cldr: MyApp.Cldr, gettext: :global],
          from:    [:query, :path, :body, :cookie, :accept_language],
          param:   "locale"

    """

    import Plug.Conn
    require Logger
    alias Cldr.AcceptLanguage

    @default_apps [cldr: :global]
    @default_from [:session, :accept_language, :query, :path]
    @default_param_name "locale"

    @private_key :cldr_locale
    @session_key "cldr_locale"

    @from_options [:accept_language, :path, :body, :query, :session, :cookie, :host]
    @app_options [:cldr, :gettext]

    @language_header "accept-language"

    @doc false
    def init(options) do
      options
      |> validate_apps(options[:apps])
      |> validate_from(options[:from])
      |> validate_param(options[:param])
      |> validate_cldr(options[:cldr])
      |> validate_gettext(options[:gettext])
      |> validate_default(options[:default])
      |> validate_session_key(options[:session_key])
    end

    @doc false
    def call(conn, options) do
      if locale = locale_from_params(conn, options[:from], options) || options[:default] do
        Enum.each(options[:apps], fn app ->
          put_locale(app, locale, options)
        end)

        put_private(conn, @private_key, locale)
      else
        conn
      end
    end

    @doc """
    Returns the name of the session key used
    to store the CLDR locale name.

    ## Example

      iex> Cldr.Plug.SetLocale.session_key()
      "cldr_locale"

    """
    def session_key do
      @session_key
    end

    @doc false
    def private_key do
      @private_key
    end

    @doc """
    Return the locale set by `Cldr.Plug.SetLocale`

    """
    def get_cldr_locale(conn) do
      conn.private[:cldr_locale]
    end

    defp locale_from_params(conn, from, options) do
      Enum.reduce_while(from, nil, fn param, _acc ->
        conn
        |> fetch_param(param, options[:param], options)
        |> return_if_valid_locale
      end)
    end

    defp fetch_param(conn, :accept_language, _param, options) do
      case get_req_header(conn, @language_header) do
        [accept_language] -> AcceptLanguage.best_match(accept_language, options[:cldr])
        [accept_language | _] -> AcceptLanguage.best_match(accept_language, options[:cldr])
        [] -> nil
      end
    end

    defp fetch_param(
           %Plug.Conn{query_params: %Plug.Conn.Unfetched{aspect: :query_params}} = conn,
           :query,
           param,
           options
         ) do
      conn = fetch_query_params(conn)
      fetch_param(conn, :query, param, options)
    end

    defp fetch_param(conn, :query, param, options) do
      conn
      |> Map.get(:query_params)
      |> Map.get(param)
      |> Cldr.validate_locale(options[:cldr])
    end

    defp fetch_param(conn, :path, param, options) do
      conn
      |> Map.get(:path_params)
      |> Map.get(param)
      |> Cldr.validate_locale(options[:cldr])
    end

    defp fetch_param(conn, :body, param, options) do
      conn
      |> Map.get(:body_params)
      |> Map.get(param)
      |> Cldr.validate_locale(options[:cldr])
    end

    defp fetch_param(conn, :session, _param, options) do
      conn
      |> get_session(options[:session_key])
      |> Cldr.validate_locale(options[:cldr])
    end

    defp fetch_param(conn, :cookie, param, options) do
      conn
      |> Map.get(:cookies)
      |> Map.get(param)
      |> Cldr.validate_locale(options[:cldr])
    end

    defp fetch_param(conn, :host, _param, options) do
      conn
      |> Map.get(:host)
      |> Cldr.Locale.locale_from_host(options[:cldr])
    end

    defp return_if_valid_locale(nil) do
      {:cont, nil}
    end

    defp return_if_valid_locale({:error, _}) do
      {:cont, nil}
    end

    defp return_if_valid_locale({:ok, locale}) do
      {:halt, locale}
    end

    defp put_locale({:cldr, :global}, locale, _options) do
      Cldr.put_locale(locale)
    end

    # Deprecated option :all.  Use :global
    defp put_locale({:cldr, :all}, locale, _options) do
      Cldr.put_locale(locale)
    end

    defp put_locale({:cldr, backend}, locale, _options) do
      backend.put_locale(locale)
    end

    defp put_locale({:gettext, _}, %Cldr.LanguageTag{gettext_locale_name: nil} = locale, _options) do
      Logger.warn(
        "Locale #{inspect(locale.requested_locale_name)} does not have a known " <>
          "Gettext locale.  No Gettext locale has been set."
      )

      nil
    end

    defp put_locale(
           {:gettext, :global},
           %Cldr.LanguageTag{gettext_locale_name: locale_name},
           _options
         ) do
      {:ok, apply(Gettext, :put_locale, [locale_name])}
    end

    # Deprecated option :all.  Use :global
    defp put_locale(
           {:gettext, :all},
           %Cldr.LanguageTag{gettext_locale_name: locale_name},
           _options
         ) do
      {:ok, apply(Gettext, :put_locale, [locale_name])}
    end

    defp put_locale(
           {:gettext, backend},
           %Cldr.LanguageTag{gettext_locale_name: locale_name},
           _options
         ) do
      {:ok, apply(Gettext, :put_locale, [backend, locale_name])}
    end

    defp validate_apps(options, nil), do: Keyword.put(options, :apps, @default_apps)

    defp validate_apps(options, app) when is_atom(app) do
      options
      |> Keyword.put(:apps, [app])
      |> validate_apps([app])
    end

    defp validate_apps(options, apps) when is_list(apps) do
      app_config =
        Enum.map(apps, fn
          {app, scope} ->
            validate_app_and_scope!(app, scope)
            {app, scope}

          app ->
            validate_app_and_scope!(app, nil)
            {app, :global}
        end)

      Keyword.put(options, :apps, app_config)
    end

    defp validate_apps(_options, apps) do
      raise(
        ArgumentError,
        "Invalid apps list: #{inspect(apps)}."
      )
    end

    defp validate_app_and_scope!(app, nil) when app in @app_options do
      :ok
    end

    defp validate_app_and_scope!(app, :global) when app in @app_options do
      :ok
    end

    # Deprecated option :all.  Use :global
    defp validate_app_and_scope!(app, :all) when app in @app_options do
      :ok
    end

    defp validate_app_and_scope!(:cldr, module) when is_atom(module) do
      Cldr.validate_backend!(module)
      :ok
    end

    defp validate_app_and_scope!(:gettext, module) when is_atom(module) do
      Cldr.Code.ensure_compiled?(module) ||
        raise(ArgumentError, "Gettext backend #{inspect(module)} is unknown")

      :ok
    end

    defp validate_app_and_scope!(app, scope) do
      raise(
        ArgumentError,
        "Invalid app #{inspect(app)} or scope #{inspect(scope)} detected."
      )
    end

    defp validate_from(options, nil), do: Keyword.put(options, :from, @default_from)

    defp validate_from(options, from) when is_atom(from) do
      options
      |> Keyword.put(:from, [from])
      |> validate_from([from])
    end

    defp validate_from(options, from) when is_list(from) do
      Enum.each(from, fn f ->
        if f not in @from_options do
          raise(
            ArgumentError,
            "Invalid :from option #{inspect(f)} detected.  " <>
              " Valid :from options are #{inspect(@from_options)}"
          )
        end
      end)

      options
    end

    defp validate_from(_options, from) do
      raise(
        ArgumentError,
        "Invalid :from list #{inspect(from)} detected.  " <>
          "Valid from options are #{inspect(@from_options)}"
      )
    end

    defp validate_param(options, nil), do: Keyword.put(options, :param, @default_param_name)
    defp validate_param(options, param) when is_binary(param), do: options

    defp validate_param(options, param) when is_atom(param) do
      validate_from(options, param)
    end

    defp validate_param(_options, param) do
      raise(
        ArgumentError,
        "Invalid :param #{inspect(param)} detected. " <> ":param must be a string"
      )
    end

    defp validate_default(options, nil) do
      default = options[:cldr].default_locale()
      Keyword.put(options, :default, default)
    end

    defp validate_default(options, default) do
      case Cldr.validate_locale(default, options[:cldr]) do
        {:ok, locale} -> Keyword.put(options, :default, locale)
        {:error, {exception, reason}} -> raise exception, reason
      end
    end

    # No configured gettext.  See if there is one configured
    # on the Cldr backend
    defp validate_gettext(options, nil) do
      gettext = options[:cldr].__cldr__(:config).gettext

      if gettext && get_in(options, [:apps, :gettext]) do
        Keyword.put(options, :gettext, gettext)
      else
        options
      end
    end

    defp validate_gettext(options, gettext) do
      case Code.ensure_compiled(gettext) do
        {:error, _} ->
          raise ArgumentError, "Gettext module #{inspect(gettext)} is not known"

        {:module, _} ->
          options
      end
    end

    defp validate_session_key(options, nil),
      do: Keyword.put(options, :session_key, @session_key)

    defp validate_session_key(options, session_key) when is_binary(session_key) do
      IO.warn(
        "The :session_key option is deprecated and will be removed in " <>
          "a future release",
        []
      )

      options
    end

    defp validate_session_key(_options, session_key) do
      raise(
        ArgumentError,
        "Invalid :session_key #{inspect(session_key)} detected. " <>
          ":session_key must be a string"
      )
    end

    defp validate_cldr(options, nil) do
      backend = Keyword.get_lazy(options[:apps], :cldr, &Cldr.default_locale/0)
      validate_cldr(options, backend)
    end

    defp validate_cldr(options, backend) when is_atom(backend) do
      with {:ok, backend} <- Cldr.validate_backend(backend) do
        Keyword.put(options, :cldr, backend)
      else
        {:error, {exception, reason}} -> raise exception, reason
      end
    end
  end
end
