if Code.ensure_loaded?(Plug) do
  defmodule Cldr.Plug.SetLocale do
    @moduledoc """
    Sets the Cldr and/or Gettext locales derived from the accept-langauge,
    query param, path param and body param.

    ## Example

        plug Cldr.Plug.SetLocale,
         apps:    [:cldr, :gettext],
         from:    [:accept_language, :url, :query, :body],
         param:   "locale",
         default: Cldr.default_locale,
         gettext: GetTextModule,
         session_key: "cldr_locale"

    """

    import Plug.Conn
    require Logger

    @default_from [:session, :accept_language]
    @from_options [:accept_language, :url, :body, :query, :session]
    @app_options  [:cldr, :gettext]
    @session_key  "cldr_locale"
    @language_header "accept-language"
    @default_param_name "locale"

    def init(options) do
      options
      |> validate_apps(options[:apps])
      |> validate_from(options[:from])
      |> validate_param(options[:param])
      |> validate_default(options[:default])
      |> validate_gettext(options[:gettext])
      |> validate_session_key(options[:session_key])
    end

    def call(conn, options) do
      if locale = locale_from_params(conn, options[:from], options) || options[:default] do
        Enum.each options[:apps], fn app ->
          set_locale(app, locale, options)
        end
      end

      put_private(conn, :cldr_locale, locale)
    end

    def locale_from_params(conn, from, options) do
      Enum.reduce_while(from, nil, fn param, _acc ->
        conn
        |> fetch_param(param, options[:param], options)
        |> return_if_valid_locale
      end)
    end

    def fetch_param(conn, :accept_language, _param, _options) do
      conn
      |> get_req_header(@language_header)
      |> Cldr.AcceptLanguage.best_match
    end

    def fetch_param(conn, :query, param, _options) do
      conn.query_params[param]
      |> Cldr.validate_locale
    end

    def fetch_param(conn, :url, param, _options) do
      conn.url_params[param]
      |> Cldr.validate_locale
    end

    def fetch_param(conn, :body, param, _options) do
      conn.body_params[param]
      |> Cldr.validate_locale
    end

    def fetch_param(conn, :session, _param, options) do
      get_session(conn, options[:session_key])
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
      Logger.warn "Locale #{inspect locale.requested_locale_name} does not have a known " <>
                  "Gettext locale"
      nil
    end

    defp set_locale(:gettext, %Cldr.LanguageTag{gettext_locale_name: locale_name}, options) do
      {:ok, Gettext.put_locale(options[:gettext], locale_name)}
    end

    def get_cldr_locale(conn) do
      conn.private[:cldr_locale]
    end

    defp validate_apps(options, nil), do: Keyword.put(options, :apps, [])
    defp validate_apps(options, app) when is_atom(app), do: Keyword.put(options, :apps, [app])
    defp validate_apps(options, apps) when is_list(apps) do
      Enum.each apps, fn a ->
        if a not in @app_options do
          raise(ArgumentError,
                "Invalid :apps option #{inspect a} detected.  " <>
                " Valid :apps options are #{inspect @app_options}")
        end
      end
      options
    end
    defp validate_apps(_options, apps) do
      raise(ArgumentError,
          "Invalid app list: #{inspect apps}.  Valid apps #{inspect @app_options}")
    end

    defp validate_from(options, nil), do: Keyword.put(options, :from, @default_from)
    defp validate_from(options, from) when is_atom(from), do: validate_from(options, [from])
    defp validate_from(options, from) when is_list(from) do
      Enum.each from, fn f ->
        if f not in @from_options do
          raise(ArgumentError,
                "Invalid :from option #{inspect f} detected.  " <>
                " Valid :from options are #{inspect @from_options}")
        end
      end
      options
    end
    defp validate_from(_options, from) do
      raise(ArgumentError,
          "Invalid :from list #{inspect from} detected.  " <>
          "Valid from options are #{inspect @from_options}")
    end

    defp validate_param(options, nil), do: Keyword.put(options, :param, @default_param_name)
    defp validate_param(options, param) when is_binary(param), do: options
    defp validate_param(_options, param) do
      raise(ArgumentError,
          "Invalid :param #{inspect param} detected. " <>
          ":param must be a string")
    end

    defp validate_default(options, nil), do: Keyword.put(options, :default, Cldr.default_locale)
    defp validate_default(options, default) do
      case Cldr.validate_locale(default) do
        {:ok, locale} -> Keyword.put(options, :default, locale)
        {:error, {exception, reason}} -> raise exception, reason
      end
    end

    defp validate_gettext(options, nil), do: options
    defp validate_gettext(_options, gettext) do
      if !Code.ensure_loaded(gettext) do
        raise ArgumentError, "Gettext module #{inspect gettext} is not known"
      end
    end

    defp validate_session_key(options, nil), do: Keyword.put(options, :session_key, @session_key)
    defp validate_session_key(options, session_key) when is_binary(session_key), do: options
    defp validate_session_key(_options, session_key) do
      raise(ArgumentError,
          "Invalid :session_key #{inspect session_key} detected. " <>
          ":session_key must be a string")
    end
  end
end