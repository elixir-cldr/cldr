if Code.ensure_loaded?(Plug) do
  defmodule Cldr.Plug.SetLocale do
    @moduledoc """
    Sets the Cldr and/or Gettext locales derived from the accept-language
    header, a query parameter, a url parameter, a body parameter or the
    session.

    ## Options

      * `:apps` - list of apps for which to set locale. Valid apps are
        `:cldr` and `:gettext`.  The default is `:cldr`.

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

      * `:default` - the default locale to set if no locale is
        found by other configured methods.  It can be a string like "en"
        or a `Cldr.LanguageTag.t` struct. The default is
        `Cldr.default_locale()`

      * `:gettext` - the name of the `Gettext` module upon which
        the locale should be set

      * `:session_key` - defines the key used to look for the locale
      in the session.  The default is "locale".

    If a locale is found then `conn.private[:cldr_locale]` is also set.
    It can be retrieved with `Cldr.Plug.SetLocale.get_cldr_locale/1`.

    ## Example

        plug Cldr.Plug.SetLocale,
          apps:    [:cldr, :gettext],
          from:    [:query, :path, :body, :cookie, :accept_language],
          param:   "locale",
          default: Cldr.default_locale,
          gettext: GetTextModule,
          session_key: "cldr_locale"

    """

    import Plug.Conn
    require Logger
    alias Cldr.AcceptLanguage

    @default_apps [:cldr]
    @default_from [:session, :accept_language]
    @default_param_name "locale"
    @default_session_key "cldr_locale"

    @from_options [:accept_language, :path, :body, :query, :session, :cookie]
    @app_options [:cldr, :gettext]

    @language_header "accept-language"

    @doc false
    def init do
      init([])
    end

    @doc false
    def init(options) do
      options =
        options
        |> validate_apps(options[:apps])
        |> validate_from(options[:from])
        |> validate_param(options[:param])
        |> validate_default(options[:default])
        |> validate_gettext(options[:gettext])
        |> validate_session_key(options[:session_key])

      if :gettext in options[:apps] and is_nil(options[:gettext]) do
        raise ArgumentError,
              "The option :gettext that specified a Gettext module must be set " <>
                "if the :gettext is configured as an :app"
      end

      options
    end

    @doc false
    def call(conn, options) do
      if locale = locale_from_params(conn, options[:from], options) || options[:default] do
        Enum.each(options[:apps], fn app ->
          set_locale(app, locale, options)
        end)
      end

      put_private(conn, :cldr_locale, locale)
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

    defp fetch_param(conn, :accept_language, _param, _options) do
      case get_req_header(conn, @language_header) do
        [accept_language] -> AcceptLanguage.best_match(accept_language)
        [accept_language | _] -> AcceptLanguage.best_match(accept_language)
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

    defp fetch_param(conn, :query, param, _options) do
      conn
      |> Map.get(:query_params)
      |> Map.get(param)
      |> Cldr.validate_locale()
    end

    defp fetch_param(conn, :path, param, _options) do
      conn
      |> Map.get(:path_params)
      |> Map.get(param)
      |> Cldr.validate_locale()
    end

    defp fetch_param(conn, :body, param, _options) do
      conn
      |> Map.get(:body_params)
      |> Map.get(param)
      |> Cldr.validate_locale()
    end

    defp fetch_param(conn, :session, _param, options) do
      conn
      |> get_session(options[:session_key])
    end

    defp fetch_param(conn, :cookie, param, _options) do
      conn
      |> Map.get(:cookies)
      |> Map.get(param)
      |> Cldr.validate_locale()
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

    defp set_locale(:cldr, locale, _options) do
      Cldr.set_current_locale(locale)
    end

    defp set_locale(:gettext, %Cldr.LanguageTag{gettext_locale_name: nil} = locale, _options) do
      Logger.warn(
        "Locale #{inspect(locale.requested_locale_name)} does not have a known " <>
          "Gettext locale.  No Gettext locale has been set."
      )

      nil
    end

    defp set_locale(:gettext, %Cldr.LanguageTag{gettext_locale_name: locale_name}, options) do
      {:ok, apply(Gettext, :put_locale, [options[:gettext], locale_name])}
    end

    defp validate_apps(options, nil), do: Keyword.put(options, :apps, @default_apps)

    defp validate_apps(options, app) when is_atom(app) do
      options
      |> Keyword.put(:apps, [app])
      |> validate_apps([app])
    end

    defp validate_apps(options, apps) when is_list(apps) do
      Enum.each(apps, fn a ->
        if a not in @app_options do
          raise(
            ArgumentError,
            "Invalid :apps option #{inspect(a)} detected.  " <>
              " Valid :apps options are #{inspect(@app_options)}"
          )
        end
      end)

      options
    end

    defp validate_apps(_options, apps) do
      raise(
        ArgumentError,
        "Invalid apps list: #{inspect(apps)}.  Valid apps are #{inspect(@app_options)}"
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
      param = Atom.to_string(param)

      options
      |> Keyword.put(:param, param)
      |> validate_from(param)
    end

    defp validate_param(_options, param) do
      raise(
        ArgumentError,
        "Invalid :param #{inspect(param)} detected. " <> ":param must be a string"
      )
    end

    defp validate_default(options, nil), do: Keyword.put(options, :default, Cldr.default_locale())

    defp validate_default(options, default) do
      case Cldr.validate_locale(default) do
        {:ok, locale} -> Keyword.put(options, :default, locale)
        {:error, {exception, reason}} -> raise exception, reason
      end
    end

    defp validate_gettext(options, nil), do: options

    defp validate_gettext(options, gettext) do
      case Code.ensure_loaded(gettext) do
        {:error, _} ->
          raise ArgumentError, "Gettext module #{inspect(gettext)} is not known"

        {:module, _} ->
          options
      end
    end

    defp validate_session_key(options, nil),
      do: Keyword.put(options, :session_key, @default_session_key)

    defp validate_session_key(options, session_key) when is_binary(session_key), do: options

    defp validate_session_key(_options, session_key) do
      raise(
        ArgumentError,
        "Invalid :session_key #{inspect(session_key)} detected. " <>
          ":session_key must be a string"
      )
    end
  end
end
