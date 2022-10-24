defmodule Cldr do
  @moduledoc """
  Cldr provides the core functions to retrieve and manage
  the CLDR data that supports formatting and localisation.

  This module provides the core functions to access formatted
  CLDR data, set and retrieve a current locale and validate
  certain core data types such as locales, currencies and
  territories.

  `Cldr` functionality is packaged into a several
  packages that each depend on this one.  These additional
  modules are:

  * `Cldr.Number.to_string/2` for formatting numbers and
    `Cldr.Currency.to_string/2` for formatting currencies.
    These functions are contained in the hex package
    [ex_cldr_numbers](https://hex.pm/packages/ex_cldr_numbers).

  * `Cldr.List.to_string/2` for formatting lists.
    These function is contained in the hex package
    [ex_cldr_lists](https://hex.pm/packages/ex_cldr_lists).

  * `Cldr.Unit.to_string/2` for formatting SI units.
    These function is contained in the hex package
    [ex_cldr_units](https://hex.pm/packages/ex_cldr_units).

  * `Cldr.DateTime.to_string/2` for formatting of dates,
    times and datetimes. This function is contained in the
    hex package [ex_cldr_dates_times](https://hex.pm/packages/ex_cldr_dates_times).

  """

  @external_resource "priv/cldr/language_tags.ebin"
  @app_name Cldr.Config.app_name()

  @type backend :: module()

  defguard is_locale_name(locale_name) when is_atom(locale_name) or is_binary(locale_name)

  alias Cldr.Config
  alias Cldr.Locale
  alias Cldr.Locale.Loader
  alias Cldr.LanguageTag

  require Config
  require Cldr.Backend.Compiler

  import Kernel, except: [to_string: 1]

  @doc false
  defmacro __using__(opts \\ []) do
    quote bind_quoted: [opts: opts] do
      @cldr_opts opts
      @before_compile Cldr.Backend.Compiler
    end
  end

  @doc """
  Returns the version of the CLDR repository as a tuple

  ## Example

      iex> Cldr.version
      {42, 0, 0}

  """
  @version Config.version()
           |> String.split(".")
           |> Enum.map(&String.to_integer/1)
           |> List.to_tuple()

  @spec version :: {non_neg_integer, non_neg_integer, non_neg_integer}
  def version do
    @version
  end

  @warn_if_greater_than 100

  @doc false
  def install_locales(config) do
    alias Cldr.Config

    Cldr.Install.install_known_locale_names(config)

    known_locale_count = Enum.count(Loader.known_locale_names(config))
    locale_string = if known_locale_count > 1, do: "locales named ", else: "locale named "

    if Enum.any?(Config.unknown_locale_names(config)) do
      raise Cldr.UnknownLocaleError,
            "Some locale names are configured that are not known to CLDR. " <>
              "Compilation cannot continue until the configuration includes only " <>
              "locales names known in CLDR.\n\n" <>
              "Configured locales names: #{inspect(Config.requested_locale_names(config))}\n" <>
              "Gettext locales names:    #{inspect(Config.known_gettext_locale_names(config))}\n" <>
              "Unknown locales names:    " <>
              "#{IO.ANSI.red()}#{inspect(Config.unknown_locale_names(config))}" <>
              "#{IO.ANSI.default_color()}\n"
    end

    IO.puts(
      "Generating #{inspect(config.backend)} for #{known_locale_count} " <>
        locale_string <>
        "#{inspect(Loader.known_locale_names(config), limit: 5)} with " <>
        "a default locale named #{inspect(Config.default_locale_name(config))}"
    )

    if known_locale_count > @warn_if_greater_than do
      IO.puts("Please be patient, generating functions for many locales " <> "can take some time")
    end
  end

  @doc """
  Return the `Cldr` locale for the
  current process.

  Note that the locale is set per-process. If the locale
  is not set for the given process then:

  * Return the global default locale
    which is defined under the `:ex_cldr` key in
    `config.exs`

  * Or the system-wide default locale which is
    #{inspect(Cldr.Config.default_locale())}

  Note that if there is no locale set for the current
  process then an error is not returned - a default locale
  will be returned per the rules above.

  ## Example

      iex> Cldr.put_locale(TestBackend.Cldr.Locale.new!("pl"))
      iex> Cldr.get_locale()
      %Cldr.LanguageTag{
         backend: TestBackend.Cldr,
         canonical_locale_name: "pl",
         cldr_locale_name: :pl,
         extensions: %{},
         language: "pl",
         locale: %{},
         private_use: [],
         rbnf_locale_name: :pl,
         territory: :PL,
         requested_locale_name: "pl",
         script: :Latn,
         transform: %{},
         language_variants: []
       }

  """
  @process_dictionary_key :cldr_locale

  def get_locale(_backend \\ nil)

  def get_locale(nil) do
    Process.get(@process_dictionary_key) || default_locale()
  end

  def get_locale(backend) do
    Process.get(@process_dictionary_key) ||
      backend.default_locale() ||
      default_locale()
  end

  @doc """
  Set the current process's locale for a specified backend or
  for all backends.

  ## Arguments

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module. The default is to set the locale
    for all backends.

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/1`
    or a `Cldr.LanguageTag` struct returned by `Cldr.Locale.new!/2`. It may
    also be a map that contains the keys `"cldr_locale"` and `"cldr_backend"`
    which is the shape of a `Phoenix` and `Plug` session making it easy to
    set the locale from a session.

  ## Returns

  * `{:ok, locale}`

  ## Behaviour

  1. If no backend is provided and the locale is a `Cldr.LanguageTag.t`
  then the the locale is set as the default for the current process

  ## Notes

  See [rfc5646](https://tools.ietf.org/html/rfc5646) for the specification
  of a language tag

  ## Examples

      iex> Cldr.put_locale(TestBackend.Cldr, "en")
      {:ok,
       %Cldr.LanguageTag{
         backend: TestBackend.Cldr,
         canonical_locale_name: "en",
         cldr_locale_name: :en,
         language_subtags: [],
         extensions: %{},
         gettext_locale_name: "en",
         language: "en",
         locale: %{},
         private_use: [],
         rbnf_locale_name: :en,
         requested_locale_name: "en",
         script: :Latn,
         territory: :US,
         transform: %{},
         language_variants: []
       }}

      iex> Cldr.put_locale(TestBackend.Cldr, "invalid-locale!")
      {:error, {Cldr.LanguageTag.ParseError,
        "Expected a BCP47 language tag. Could not parse the remaining \\"!\\" starting at position 15"}}

  """
  @spec put_locale(backend(), Locale.locale_reference()) ::
    {:ok, LanguageTag.t()} | {:error, {module(), String.t()}}

  def put_locale(backend \\ nil, locale)

  def put_locale(nil, locale) when is_locale_name(locale) do
    backend = default_backend!()

    with {:ok, locale} <- backend.validate_locale(locale) do
      put_locale(locale)
    end
  end

  def put_locale(backend, locale_name) when is_atom(backend) and is_locale_name(locale_name) do
    with {:ok, backend} <- validate_backend(backend),
         {:ok, locale} <- backend.validate_locale(locale_name) do
      put_locale(locale)
    end
  end

  def put_locale(_backend, %LanguageTag{} = locale) do
    Process.put(@process_dictionary_key, locale)
    {:ok, locale}
  end

  # For when the parameter is a session (used by Plug and Phoenix)
  def put_locale(_backend, %{"cldr_locale" => locale, "cldr_backend" => backend}) do
    backend = Module.concat([backend])
    put_locale(backend, locale)
  end

  def put_locale(_backend, %{"cldr_locale" => locale}) do
    put_locale(locale)
  end

  if Code.ensure_loaded?(Gettext) do
    @doc """
    Set the current process's Gettext locale from a
    `t:Cldr.LanguageTag`.

    ## Arguments

    * `locale` is a `Cldr.LanguageTag` struct returned by `Cldr.Locale.new!/2`.

    ## Returns

    * `{:ok, gettext_locale_name}` or

    * `{:error, {exception, reason}}`

    ## Behaviour

    1. If the `locale.gettext_locale_name` is `nil` then an error
       is returned.

    2. The `gettext` locale for the `gettext_backend` configured for the
       CLDR backend defined by the `t:Cldr.LanguageTag` is set.

    ## Examples

        iex> import Cldr.LanguageTag.Sigil
        iex> Cldr.put_gettext_locale(~l"en")
        {:ok, "en"}

        iex> import Cldr.LanguageTag.Sigil
        iex> Cldr.put_gettext_locale(~l"de")
        {:error,
          {Cldr.UnknownLocaleError,
            "Locale #Cldr.LanguageTag<de [validated]> does not map to a known gettext locale name"}}

    """
    @spec put_gettext_locale(LanguageTag.t()) ::
            {:ok, binary() | nil} | {:error, {module(), String.t()}}

    def put_gettext_locale(%LanguageTag{gettext_locale_name: nil} = locale) do
      {:error, {Cldr.UnknownLocaleError, "Locale #{inspect locale} does not map to a known gettext locale name"}}
    end

    def put_gettext_locale(%LanguageTag{gettext_locale_name: gettext_locale_name} = locale) do
      gettext_backend = locale.backend.__cldr__(:gettext)
      _ = Gettext.put_locale(gettext_backend, gettext_locale_name)
      {:ok, gettext_locale_name}
    end

  end

  @doc """
  Set's the system default locale.

  The locale set here is the base level
  system default equivalent to setting the
  `:default_locale` key in `config.exs`.

  ## Arguments

  * `locale` is a `Cldr.LanguageTag` struct returned by `Cldr.Locale.new!/2`
    with a non-nil `:cldr_locale_name`.

  ## Returns

  * `{:ok, locale}`

  """
  def put_default_locale(%Cldr.LanguageTag{} = locale) do
    :ok = Application.put_env(@app_name, :_default_locale, locale)
    {:ok, locale}
  end

  @doc """
  Sets the system default locale.

  The locale set here is the base level
  system default equivalent to setting the
  `:default_locale` key in `config.exs`.

  ## Arguments

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/1`.

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module.

  ## Returns

  * `{:ok, locale}` or

  * `{:error, {exception, reason}}`

  """
  def put_default_locale(locale_name, backend \\ default_backend!()) do
    with {:ok, locale} <- validate_locale(locale_name, backend) do
      put_default_locale(locale)
    end
  end

  @doc """
  Execute a function with a locale ensuring that the
  current locale is restored after the function.

  ## Arguments

  * `locale` is any `t:Cldr.LanguageTag.t/0`, tyically returned
    by `Cldr.validate_locale/2`.

  * `fun` is any 0-arity function or function capture.

  ## Returns

  * The value returned by the function `fun/0` or

  * raises an exception if the current locale cannot be
    identified.

  """
  @doc since: "2.32.0"

  @spec with_locale(Cldr.LanguageTag.t(), fun) :: any
  def with_locale(%Cldr.LanguageTag{} = locale, fun) when is_function(fun) do
    current_locale = get_locale(locale.backend)

    try do
      put_locale(locale.backend, locale)
      fun.()
    after
      put_locale(locale.backend, current_locale)
    end
  end

  @doc """
  Execute a function with a locale ensuring that the
  current locale is restored after the function.

  ## Arguments

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/1`.

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module. The default is `Cldr.default_backend!/0`.

  * `fun` is any 0-arity function or function capture.

  ## Returns

  * The value returned by the function `fun/0` or

  * `{:error, {exception, reason}}` if the locale is invalid or

  * raises an exception if the current locale cannot be
    identified.

  """
  @doc since: "2.27.0"

  @spec with_locale(Cldr.Locale.locale_name(), backend(), fun) :: any
  def with_locale(locale, backend \\ default_backend!(), fun) when is_locale_name(locale) do
    with {:ok, locale} = validate_locale(locale, backend) do
      with_locale(locale, fun)
    end
  end

  @doc """
  Returns the global default `locale` for a
  given backend.

  ## Arguments

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module.

  ## Returns

  * The default locale for the backend.

  ## Example

      iex> Cldr.default_locale(TestBackend.Cldr)
      %Cldr.LanguageTag{
        backend: TestBackend.Cldr,
        canonical_locale_name: "en-001",
        cldr_locale_name: :"en-001",
        language_subtags: [],
        extensions: %{},
        gettext_locale_name: "en",
        language: "en",
        locale: %{},
        private_use: [],
        rbnf_locale_name: :en,
        requested_locale_name: "en-001",
        script: :Latn,
        territory: :"001",
        transform: %{},
        language_variants: []
      }

  """
  @spec default_locale(backend()) :: LanguageTag.t()
  def default_locale(backend) do
    backend.default_locale()
  end

  @doc """
  Returns the configured global default `locale`.

  The default locale can be set with
  `Cldr.put_default_locale/1`.

  Alternatively the default locale may be configured in
  `config.exs` under the `ex_cldr` key as follows:

      config :ex_cldr,
        default_locale: <locale_name>

  ## Returns

  * The default locale or

  * Raises an exception if no default
    backend is configured

  ## Notes

  `Cldr.default_locale/0` returns the system-wide
  default locale.

  ## Example

      iex> Cldr.default_locale
      %Cldr.LanguageTag{
        backend: TestBackend.Cldr,
        canonical_locale_name: "en-001",
        cldr_locale_name: :"en-001",
        language_subtags: [],
        extensions: %{},
        gettext_locale_name: "en",
        language: "en",
        locale: %{},
        private_use: [],
        rbnf_locale_name: :en,
        requested_locale_name: "en-001",
        script: :Latn,
        territory: :"001",
        transform: %{},
        language_variants: []
      }

  """
  def default_locale do
    if locale = Application.get_env(@app_name, :_default_locale) do
      locale
    else
      {:ok, locale} = put_default_locale(Cldr.Config.default_locale())
      locale
    end
  end

  @default_script :Latn

  @doc """
  Returns the default script.

  ## Returns

  * The default script which is `#{@default_script}`.

  """

  @doc since: "2.31.0"
  @spec default_script :: Locale.script()

  def default_script do
    @default_script
  end

  @doc """
  Returns the default territory when a locale
  does not specify one and none can be inferred.

  ## Arguments

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module. The default is `Cldr.default_backend/0`

  ## Returns

  * The default territory or

  * Raises if no argument is supplied and there is no
    default backend configured

  ## Example

      iex> Cldr.default_territory(TestBackend.Cldr)
      :"001"

  """
  @spec default_territory(backend()) :: atom()
  def default_territory(backend \\ default_backend!()) do
    backend.default_territory
  end

  @doc """
  Returns the configured default backend module.

  The default backend can be set with
  `Cldr.put_default_backend/1`.

  Alternatively the default backend may be configured in
  `config.exs` under the `ex_cldr` key as follows:

      config :ex_cldr,
        default_backend: <backend_module>

  ## Important Note

  If this function is called and no default backend
  is configured an exception will be raised.

  """
  @spec default_backend :: backend() | no_return
  @compile {:inline, default_backend!: 0}

  def default_backend! do
    Cldr.Config.default_backend()
  end

  @deprecated "Use default_backend!/0"
  def default_backend do
    default_backend!()
  end

  @doc """
  Set the default system-wide backend module.

  ## Arguments

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module.

  ## Returns

  * `{:ok, backend}` or

  * `{:error, {exception, reason}}`

  """
  def put_default_backend(backend) do
    with {:ok, backend} <- validate_backend(backend) do
      :ok = Application.put_env(Cldr.Config.app_name(), :default_backend, backend)
      {:ok, backend}
    end
  end

  @doc """
  Returns the territory for the world

  This is the outermost containment of
  territories in CLDR.

  CLDR does not yet consider non-terrestrial
  territories.

  """
  @compile {:inline, the_world: 0}

  @the_world :"001"
  def the_world do
    @the_world
  end

  @doc """
  Return a localsed string for types
  that implement the `Cldr.Chars` protocol.

  The `Cldr.Chars` protocol is implemented in this
  library for `t:Cldr.LanguageTag.t()`.

  Other CLDR-related libraries implement
  the protocol for the types they support
  such as `Float`, `Integer`, `Decimal`,
  `Money`, `Unit` and `List`.

  """
  @spec to_string(term()) :: String.t()

  def to_string(term) do
    Cldr.Chars.to_string(term)
  end

  @doc """
  Return a localised string suitable for
  presentation purposes for structs that
  implement the  `Cldr.LanguageTag.DisplayName`
  protocol.

  The `Cldr.LanguageTag.DisplayName` protocol is
  implemented in this library for
  `t:Cldr.LanguageTag.t`.

  Other CLDR-related libraries implement
  the protocol for the types they support
  such as `t:Cldr.Unit` and `t:Cldr.Currency`.

  """
  @spec display_name(term(), Keyword.t()) :: String.t()
  @display_name_options [prefer: :default, compound_locale: true]

  def display_name(term, options \\ []) do
    options = Keyword.merge(@display_name_options, options)
    Cldr.DisplayName.display_name(term, options)
  end

  @doc """
  Validates that a module is a CLDR backend module.

  ## Arguments

  * `backend` is any module name that may be a
    `Cldr` backend module.

  ## Returns

  * `{:ok, backend}` is the module if a CLDR backend module or

  * `{:error, {exception, reason}}` if the module is unknown or if
    the module is not a backend module.

  ## Examples

      iex> Cldr.validate_backend MyApp.Cldr
      {:ok, MyApp.Cldr}

      iex> Cldr.validate_backend :something_else
      {:error,
       {Cldr.UnknownBackendError,
        "The backend :something_else is not known or not a backend module."}}

  """
  @spec validate_backend(backend :: atom()) :: {:ok, atom()} | {:error, {atom(), String.t()}}
  def validate_backend(backend) when is_atom(backend) do
    if Cldr.Code.ensure_compiled?(backend) && function_exported?(backend, :__cldr__, 1) do
      {:ok, backend}
    else
      {:error, unknown_backend_error(backend)}
    end
  end

  def validate_backend(backend) do
    {:error, unknown_backend_error(backend)}
  end

  defp unknown_backend_error(backend) do
    {Cldr.UnknownBackendError,
     "The backend #{inspect(backend)} is not known or not a backend module."}
  end

  @doc false
  def validate_backend!(backend) do
    case validate_backend(backend) do
      {:ok, backend} -> backend
      {:error, {exception, reason}} -> raise exception, reason
    end
  end

  @doc """
  Normalise and validate a locale name.

  ## Arguments

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/1`
    or a `Cldr.LanguageTag` struct returned by `Cldr.Locale.new!/2`

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module.  The default is `Cldr.default_backend!/0`.
    Note that `Cldr.default_backend!/0` will raise an exception if
    no `:default_backend` is configured under the `:ex_cldr` key in
    `config.exs`.

  ## Returns

  * `{:ok, language_tag}`

  * `{:error, reason}`

  ## Examples

      iex> Cldr.validate_locale(:en, TestBackend.Cldr)
      {:ok,
      %Cldr.LanguageTag{
        backend: TestBackend.Cldr,
        canonical_locale_name: "en",
        cldr_locale_name: :en,
        extensions: %{},
        gettext_locale_name: "en",
        language: "en",
        locale: %{},
        private_use: [],
        rbnf_locale_name: :en,
        requested_locale_name: "en",
        script: :Latn,
        territory: :US,
        transform: %{},
        language_variants: []
      }}

      iex> Cldr.validate_locale(:af, TestBackend.Cldr)
      {:ok,
      %Cldr.LanguageTag{
        backend: TestBackend.Cldr,
        canonical_locale_name: "af",
        cldr_locale_name: :af,
        extensions: %{},
        gettext_locale_name: nil,
        language: "af",
        locale: %{},
        private_use: [],
        rbnf_locale_name: :af,
        requested_locale_name: "af",
        script: :Latn,
        territory: :ZA,
        transform: %{},
        language_variants: []
      }}

      iex> Cldr.validate_locale("zzz", TestBackend.Cldr)
      {:error, {Cldr.InvalidLanguageError, "The language \\"zzz\\" is invalid"}}

  """
  @spec validate_locale(Locale.locale_name() | LanguageTag.t() | String.t(), backend()) ::
          {:ok, LanguageTag.t()} | {:error, {module(), String.t()}}

  def validate_locale(locale, backend \\ nil)

  def validate_locale(%LanguageTag{} = locale, nil) do
    {:ok, locale}
  end

  def validate_locale(locale, nil) do
    validate_locale(locale, Cldr.default_backend!())
  end

  def validate_locale(locale, backend) do
    backend.validate_locale(locale)
  end

  @doc """
  Returns a list of all the locale names defined in
  the CLDR repository.

  Note that not necessarily all of these locales are
  available since functions are only generated for configured
  locales which is most cases will be a subset of locales
  defined in CLDR.

  See also: `requested_locales/1` and `known_locales/1`

  """
  @all_locale_names Config.all_locale_names()
  @spec all_locale_names :: [Locale.locale_name(), ...]
  def all_locale_names do
    @all_locale_names
  end

  @doc """
  Returns a list of all requested locale names.

  ## Arguments

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module.  The default is `Cldr.default_backend!/0`.
    Note that `Cldr.default_backend!/0` will raise an exception if
    no `:default_backend` is configured under the `:ex_cldr` key in
    `config.exs`.

  The list is the combination of configured locales,
  `Gettext` locales and the default locale.

  See also `known_locales/1` and `all_locales/0`

  """
  @spec requested_locale_names(backend()) :: [Locale.locale_name(), ...] | []
  def requested_locale_names(backend \\ default_backend!()) do
    backend.requested_locale_names
  end

  @doc """
  Returns a list of the known locale names.

  ## Arguments

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module.  The default is `Cldr.default_backend!/0`.
    Note that `Cldr.default_backend!/0` will raise an exception if
    no `:default_backend` is configured under the `:ex_cldr` key in
    `config.exs`.

  Known locales are those locales which
  are the subset of all CLDR locales that
  have been configured for use either
  directly in the `config.exs` file or
  in `Gettext`.

  """
  @spec known_locale_names(backend()) :: [Locale.locale_name(), ...] | []
  def known_locale_names(backend \\ default_backend!()) do
    backend.known_locale_names
  end

  @doc """
  Returns a list of the locales names that are configured,
  but not known in CLDR.

  ## Arguments

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module.  The default is `Cldr.default_backend!/0`.
    Note that `Cldr.default_backend!/0` will raise an exception if
    no `:default_backend` is configured under the `:ex_cldr` key in
    `config.exs`.

  Since there is a compile-time exception raise if there are
  any unknown locales this function should always
  return an empty list.

  """
  @spec unknown_locale_names(backend()) :: [Locale.locale_name(), ...] | []
  def unknown_locale_names(backend \\ default_backend!()) do
    backend.unknown_locale_names
  end

  @doc """
  Returns a list of locale names which have rules based number
  formats (RBNF).

  ## Arguments

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module

  """
  @spec known_rbnf_locale_names(backend()) :: [Locale.locale_name(), ...] | []
  def known_rbnf_locale_names(backend \\ default_backend!()) do
    backend.known_rbnf_locale_names
  end

  @doc """
  Returns a list of Gettext locale names but in CLDR format with
  underscore replaced by hyphen in order to facilitate comparisons
  with Cldr locale names.

  ## Arguments

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module.  The default is `Cldr.default_backend!/0`.
    Note that `Cldr.default_backend!/0` will raise an exception if
    no `:default_backend` is configured under the `:ex_cldr` key in
    `config.exs`.

  """
  @spec known_gettext_locale_names(backend()) :: [Locale.locale_name(), ...] | []
  def known_gettext_locale_names(backend \\ default_backend!()) do
    backend.known_gettext_locale_names
  end

  @doc """
  Returns either the `locale_name` or `false` based upon
  whether the locale name is configured in `Cldr`.

  This is helpful when building a list of `or` expressions
  to return the first known locale name from a list.

  ## Arguments

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/1`

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module.  The default is `Cldr.default_backend!/0`.
    Note that `Cldr.default_backend!/0` will raise an exception if
    no `:default_backend` is configured under the `:ex_cldr` key in
    `config.exs`.

  ## Examples

      iex> Cldr.known_locale_name(:"en-AU", TestBackend.Cldr)
      :"en-AU"

      iex> Cldr.known_locale_name(:"en-SA", TestBackend.Cldr)
      nil

  """
  @spec known_locale_name(Locale.locale_name() | String.t(), backend()) :: atom() | nil

  def known_locale_name(locale_name, backend \\ default_backend!())

  def known_locale_name(locale_name, backend) when is_atom(locale_name) do
    if name = backend.known_locale_name(locale_name) do
      name
    else
      nil
    end
  end

  # TODO remove when we get to Cldr 3.0
  def known_locale_name(locale_name, backend) when is_binary(locale_name) do
    locale_name = String.to_existing_atom(locale_name)
    known_locale_name(locale_name, backend)
  rescue ArgumentError ->
    nil
  end

  @doc """
  Returns a boolean indicating if the specified locale
  name is configured and available in Cldr.

  ## Arguments

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/1`

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module.  The default is `Cldr.default_backend!/0`.
    Note that `Cldr.default_backend!/0` will raise an exception if
    no `:default_backend` is configured under the `:ex_cldr` key in
    `config.exs`.

  ## Examples

      iex> Cldr.known_locale_name?(:en, TestBackend.Cldr)
      true

      iex> Cldr.known_locale_name?(:"!!", TestBackend.Cldr)
      false

  """
  @spec known_locale_name?(Locale.locale_name(), backend()) :: boolean
  def known_locale_name?(locale_name, backend \\ default_backend!()) when is_atom(locale_name) do
    locale_name in backend.known_locale_names
  end

  @doc """
  Returns a boolean indicating if the specified locale
  name is configured and available in Cldr and supports
  rules based number formats (RBNF).

  ## Arguments

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/1`

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module.  The default is `Cldr.default_backend!/0`.
    Note that `Cldr.default_backend!/0` will raise an exception if
    no `:default_backend` is configured under the `:ex_cldr` key in
    `config.exs`.

  ## Examples

      iex> Cldr.known_rbnf_locale_name?(:en, TestBackend.Cldr)
      true

      iex> Cldr.known_rbnf_locale_name?(:"!!", TestBackend.Cldr)
      false

  """
  @spec known_rbnf_locale_name?(Locale.locale_name(), backend()) :: boolean
  def known_rbnf_locale_name?(locale_name, backend \\ default_backend!()) do
    locale_name in backend.known_rbnf_locale_names
  end

  @doc """
  Returns a boolean indicating if the specified locale
  name is configured and available in Gettext.

  ## Arguments

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/1`

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module.  The default is `Cldr.default_backend!/0`.
    Note that `Cldr.default_backend!/0` will raise an exception if
    no `:default_backend` is configured under the `:ex_cldr` key in
    `config.exs`.

  ## Examples

      iex> Cldr.known_gettext_locale_name?("en", TestBackend.Cldr)
      true

      iex> Cldr.known_gettext_locale_name?("!!", TestBackend.Cldr)
      false

  """
  @spec known_gettext_locale_name?(String.t(), backend) :: boolean
  def known_gettext_locale_name?(locale_name, backend \\ default_backend!())
      when is_binary(locale_name) do
    locale_name in backend.known_gettext_locale_names
  end

  @doc """
  Returns either the RBNF `locale_name` or `false` based upon
  whether the locale name is configured in `Cldr`
  and has RBNF rules defined.

  ## Arguments

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/1`

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module.  The default is `Cldr.default_backend!/0`.
    Note that `Cldr.default_backend!/0` will raise an exception if
    no `:default_backend` is configured under the `:ex_cldr` key in
    `config.exs`.

  ## Examples

      iex> Cldr.known_rbnf_locale_name(:en, TestBackend.Cldr)
      :en

      iex> Cldr.known_rbnf_locale_name(:"en-SA", TestBackend.Cldr)
      false

  """
  @spec known_rbnf_locale_name(Locale.locale_name(), backend()) :: String.t() | false
  def known_rbnf_locale_name(locale_name, backend \\ default_backend!()) do
    if backend.known_rbnf_locale_name?(locale_name) do
      locale_name
    else
      false
    end
  end

  @doc """
  Returns either the Gettext `locale_name` in Cldr format or
  `false` based upon whether the locale name is configured in
  `Gettext`.

  ## Arguments

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/1`

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module.  The default is `Cldr.default_backend!/0`.
    Note that `Cldr.default_backend!/0` will raise an exception if
    no `:default_backend` is configured under the `:ex_cldr` key in
    `config.exs`.

  ## Examples

      iex> Cldr.known_gettext_locale_name("en", TestBackend.Cldr)
      "en"

      iex> Cldr.known_gettext_locale_name("en-SA", TestBackend.Cldr)
      false

  """
  @spec known_gettext_locale_name(String.t(), backend()) :: String.t() | false
  def known_gettext_locale_name(locale_name, backend \\ default_backend!())
      when is_binary(locale_name) do
    backend.known_gettext_locale_name(locale_name)
  end

  @doc """
  Returns a boolean indicating if the specified locale
  is available in CLDR.

  The return value depends on whether the locale is
  defined in the CLDR repository.  It does not necessarily
  mean the locale is configured for `Cldr`.  See also
  `Cldr.known_locale_name?/2`.

  ## Arguments

  * `locale` is any valid locale name returned by `Cldr.known_locale_names/1`

  ## Examples

      iex> Cldr.available_locale_name?(:"en-AU")
      true

      iex> Cldr.available_locale_name?(:"en-SA")
      false

  """
  @all_locale_names Config.all_locale_names()

  @spec available_locale_name?(Locale.locale_name() | LanguageTag.t()) :: boolean
  def available_locale_name?(locale_name) when is_atom(locale_name) do
    locale_name in @all_locale_names
  end

  def available_locale_name?(%LanguageTag{cldr_locale_name: cldr_locale_name}) do
    available_locale_name?(cldr_locale_name)
  end

  def available_locale_name?(_other) do
    false
  end

  @doc """
  Add locale-specific quotation marks around a string.

  ## Arguments

  * `string` is any valid Elixir string

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module.  The default is `Cldr.default_backend!/0`.
    Note that `Cldr.default_backend!/0` will raise an exception if
    no `:default_backend` is configured under the `:ex_cldr` key in
    `config.exs`.

  * `options` is a keyword list of options

  ## Options

  * `:locale` is any valid locale name returned by `Cldr.known_locale_names/1`.
    The default is `Cldr.get_locale/0`

  ## Examples

      iex> Cldr.quote "Quoted String", MyApp.Cldr
      "“Quoted String”"

      iex> Cldr.quote "Quoted String", MyApp.Cldr, locale: "ja"
      "「Quoted String」"

  """
  @spec quote(String.t(), backend(), Keyword.t()) :: String.t()
  def quote(string, backend \\ default_backend!(), options \\ [])

  def quote(string, options, []) when is_binary(string) and is_list(options) do
    {backend, options} = Keyword.pop(options, :backend)
    backend = backend || default_backend!()
    quote(string, backend, options)
  end

  def quote(string, backend, options) when is_binary(string) and is_list(options) do
    backend.quote(string, options)
  end

  @doc """
  Add locale-specific ellipsis to a string.

  ## Arguments

  * `string` is any `String.t` or a 2-element list
    of `String.t` between which the ellipsis is inserted.

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module.  The default is `Cldr.default_backend/0`.
    Note that `Cldr.default_backend/0` will raise an exception if
    no `:default_backend` is configured under the `:ex_cldr` key in
    `config.exs`.

  * `options` is a keyword list of options.

  ## Options

  * `:locale` is any valid locale name returned by `Cldr.known_locale_names/1`.
    The default is `Cldr.get_locale/0`

  * `:location` determines where to place the ellipsis. The options are
    `:after` (the default for a single string argument), `:between` (the default
    and only valid location for an argument that is a list of two strings) and `:before`

  * `:format` formats based upon whether the ellipsis
    is inserted between words or sentences. The valid options are
    `:word` or `:sentence`. The default is `:sentence`.

  ## Examples

      iex> Cldr.ellipsis "And furthermore"
      "And furthermore…"

      iex> Cldr.ellipsis ["And furthermore", "there is much to be done"], locale: "ja"
      "And furthermore…there is much to be done"

      iex> Cldr.ellipsis "And furthermore", format: :word
      "And furthermore …"

      iex> Cldr.ellipsis ["And furthermore", "there is much to be done"], locale: "ja", format: :word
      "And furthermore … there is much to be done"

  """
  @spec ellipsis(String.t() | list(String.t()), backend(), Keyword.t()) :: String.t()
  def ellipsis(string, backend \\ default_backend!(), options \\ [])

  def ellipsis(string, options, []) when is_list(options) do
    {backend, options} = Keyword.pop(options, :backend)
    backend = backend || default_backend!()
    ellipsis(string, backend, options)
  end

  def ellipsis(string, backend, options) when is_list(options) do
    backend.ellipsis(string, options)
  end

  @doc """
  Normalise and validate a gettext locale name.

  ## Arguments

  * `locale_name` is any valid locale name returned by `Cldr.known_locale_names/1`
    or a `Cldr.LanguageTag` struct returned by `Cldr.Locale.new!/2`

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module.  The default is `Cldr.default_backend/0`.
    Note that `Cldr.default_backend/0` will raise an exception if
    no `:default_backend` is configured under the `:ex_cldr` key in
    `config.exs`.

  ## Returns

  * `{:ok, language_tag}`

  * `{:error, reason}`

  ## Examples

  """
  @spec validate_gettext_locale(Locale.locale_name() | LanguageTag.t(), backend()) ::
          {:ok, LanguageTag.t()} | {:error, {module(), String.t()}}

  def validate_gettext_locale(locale_name, backend \\ default_backend!())

  def validate_gettext_locale(locale_name, backend)
      when is_binary(locale_name) do
    case Cldr.Locale.new(locale_name, backend) do
      {:ok, locale} -> validate_gettext_locale(locale, backend)
      {:error, reason} -> {:error, reason}
    end
  end

  def validate_gettext_locale(%LanguageTag{gettext_locale_name: nil} = locale, _backend) do
    {:error, Locale.gettext_locale_error(locale)}
  end

  def validate_gettext_locale(%LanguageTag{} = language_tag, _backend) do
    {:ok, language_tag}
  end

  def validate_gettext_locale(locale, _backend) do
    {:error, Locale.gettext_locale_error(locale)}
  end

  @doc """
  Returns a list of strings representing the calendars known to `Cldr`.

  ## Example

      iex> Cldr.known_calendars
      [:buddhist, :chinese, :coptic, :dangi, :ethiopic, :ethiopic_amete_alem,
       :gregorian, :hebrew, :indian, :islamic, :islamic_civil, :islamic_rgsa,
       :islamic_tbla, :islamic_umalqura, :japanese, :persian, :roc]

  """
  @known_calendars Cldr.Config.known_calendars()
  @spec known_calendars :: [atom(), ...]
  def known_calendars do
    @known_calendars
  end

  @doc """
  Normalise and validate a calendar name.

  ## Arguments

  * `calendar` is any calendar name returned by `Cldr.known_calendars/0`

  ## Returns

  * `{:ok, normalized_calendar_name}` or

  * `{:error, {Cldr.UnknownCalendarError, message}}`

  ## Examples

      iex> Cldr.validate_calendar(:gregorian)
      {:ok, :gregorian}

      iex> Cldr.validate_calendar(:invalid)
      {:error, {Cldr.UnknownCalendarError, "The calendar name :invalid is invalid"}}

  """
  @spec validate_calendar(atom() | String.t()) ::
          {:ok, atom()} | {:error, {module(), String.t()}}

  def validate_calendar(calendar) when is_atom(calendar) and calendar in @known_calendars do
    {:ok, calendar}
  end

  # "gregory" is the name used for the locale "u" extension
  def validate_calendar("gregory"), do: {:ok, :gregorian}

  def validate_calendar(calendar) when is_atom(calendar) do
    {:error, unknown_calendar_error(calendar)}
  end

  def validate_calendar(calendar) when is_binary(calendar) do
    calendar
    |> String.downcase()
    |> String.to_existing_atom()
    |> validate_calendar
  rescue
    ArgumentError ->
      {:error, unknown_calendar_error(calendar)}
  end

  @doc """
  Returns an error tuple for an invalid calendar.

  ## Arguments

    * `calendar` is any calendar name **not** returned by `Cldr.known_calendars/0`

  ## Returns

  * `{:error, {Cldr.UnknownCalendarError, message}}`

  ## Examples

      iex> Cldr.unknown_calendar_error("invalid")
      {Cldr.UnknownCalendarError, "The calendar name \\"invalid\\" is invalid"}

  """
  def unknown_calendar_error(calendar) do
    {Cldr.UnknownCalendarError, "The calendar name #{inspect(calendar)} is invalid"}
  end

  @doc """
  Returns a list of the territories known to `Cldr`.

  The territories codes are defined in [UN M.49](https://en.wikipedia.org/wiki/UN_M.49)
  which defines both individual territories and enclosing territories. These enclosing
  territories are defined for statistical purposes and do not relate to political
  alignment.

  For example, the territory `:"001"` is defined as "the world".

  ## Example

      iex> Cldr.known_territories
      [:"001", :"002", :"003", :"005", :"009", :"011", :"013", :"014", :"015", :"017",
       :"018", :"019", :"021", :"029", :"030", :"034", :"035", :"039", :"053", :"054",
       :"057", :"061", :"142", :"143", :"145", :"150", :"151", :"154", :"155", :"202",
       :"419", :AC, :AD, :AE, :AF, :AG, :AI, :AL, :AM, :AO, :AQ, :AR, :AS, :AT, :AU,
       :AW, :AX, :AZ, :BA, :BB, :BD, :BE, :BF, :BG, :BH, :BI, :BJ, :BL, :BM, :BN, :BO,
       :BQ, :BR, :BS, :BT, :BV, :BW, :BY, :BZ, :CA, :CC, :CD, :CF, :CG, :CH, :CI, :CK,
       :CL, :CM, :CN, :CO, :CP, :CR, :CU, :CV, :CW, :CX, :CY, :CZ, :DE, :DG, :DJ, :DK,
       :DM, :DO, :DZ, :EA, :EC, :EE, :EG, :EH, :ER, :ES, :ET, :EU, :EZ, :FI, :FJ, :FK,
       :FM, :FO, :FR, :GA, :GB, :GD, :GE, :GF, :GG, :GH, :GI, :GL, :GM, :GN, :GP, :GQ,
       :GR, :GS, :GT, :GU, :GW, :GY, :HK, :HM, :HN, :HR, :HT, :HU, :IC, :ID, :IE, :IL,
       :IM, :IN, :IO, :IQ, :IR, :IS, :IT, :JE, :JM, :JO, :JP, :KE, :KG, :KH, :KI, :KM,
       :KN, :KP, :KR, :KW, :KY, :KZ, :LA, :LB, :LC, :LI, :LK, :LR, :LS, :LT, :LU, :LV,
       :LY, :MA, :MC, :MD, :ME, :MF, :MG, :MH, :MK, :ML, :MM, :MN, :MO, :MP, :MQ, :MR,
       :MS, :MT, :MU, :MV, :MW, :MX, :MY, :MZ, :NA, :NC, :NE, :NF, :NG, :NI, :NL, :NO,
       :NP, :NR, :NU, :NZ, :OM, :PA, :PE, :PF, :PG, :PH, :PK, :PL, :PM, :PN, :PR, :PS,
       :PT, :PW, :PY, :QA, :QO, :RE, :RO, :RS, :RU, :RW, :SA, :SB, :SC, :SD, :SE, :SG,
       :SH, :SI, :SJ, :SK, :SL, :SM, :SN, :SO, :SR, :SS, :ST, :SV, :SX, :SY, :SZ, :TA,
       :TC, :TD, :TF, :TG, :TH, :TJ, :TK, :TL, :TM, :TN, :TO, :TR, :TT, :TV, :TW, :TZ,
       :UA, :UG, :UM, :UN, :US, :UY, :UZ, :VA, :VC, :VE, :VG, :VI, :VN, :VU, :WF, :WS,
       :XK, :YE, :YT, :ZA, :ZM, :ZW]

  """
  @known_territories Cldr.Config.known_territories()
  @spec known_territories :: [atom(), ...]
  def known_territories do
    @known_territories
  end

  @territory_containment Cldr.Config.territory_containment()
  @spec territory_containment() :: map()
  def territory_containment do
    @territory_containment
  end

  @doc """
  Returns the map of territories and subdivisions and their
  child subdivsions.

  The subdivision codes designate a subdivision of a country
  or region. They are called various names, such as a
  state in the United States, or a province in Canada.

  The codes in CLDR are based on ISO 3166-2 subdivision codes.
  The ISO codes have a region code followed by a hyphen, then a
  suffix consisting of 1..3 ASCII letters or digits.

  The CLDR codes are designed to work in a unicode_locale_id
  (BCP47), and are thus all lowercase, with no hyphen. For
  example, the following are valid, and mean “English as
  used in California, USA”.

      en-u-sd-usca
      en-US-u-sd-usca

  CLDR has additional subdivision codes. These may start with
  a 3-digit region code or use a suffix of 4 ASCII letters or
  digits, so they will not collide with the ISO codes. Subdivision
  codes for unknown values are the region code plus "zzzz", such as
  "uszzzz" for an unknown subdivision of the US. Other codes may be
  added for stability.

  """
  @territory_subdivisions Cldr.Config.territory_subdivisions()
                          |> Enum.map(fn
                            {<<territory::binary-size(2)>>, children} ->
                              {String.to_existing_atom(territory), children}

                            other ->
                              other
                          end)
                          |> Map.new()

  @spec known_territory_subdivisions :: %{atom() => list()}
  def known_territory_subdivisions do
    @territory_subdivisions
  end

  @doc """
  Returns a map of territory subdivisions sith a list of
  their parent subdivisions and region.

  For a description of territory subdivisions see
  `Cldr.known_territory_subdivisions/0`

  """
  @territory_subdivision_containment Cldr.Config.territory_subdivision_containment()
                                     |> Enum.map(fn {subdivision, parents} ->
                                       parents =
                                         Enum.map(parents, fn
                                           <<territory::binary-size(2)>> ->
                                             String.to_existing_atom(territory)

                                           other ->
                                             other
                                         end)

                                       {subdivision, parents}
                                     end)
                                     |> Map.new()

  @spec known_territory_subdivision_containment :: map()
  def known_territory_subdivision_containment do
    @territory_subdivision_containment
  end

  @doc """
  Normalise and validate a script code.

  ## Arguments

  * `script` is any script code as a binary
    or atom

  ## Returns:

  * `{:ok, normalized_script_code}` or

  * `{:error, {Cldr.UnknownscriptError, message}}`

  ## Examples

      iex> Cldr.validate_script("thai")
      {:ok, :Thai}

      iex> Cldr.validate_script("qaai")
      {:ok, :Zinh}

      iex> Cldr.validate_script(Cldr.Locale.new!("en", TestBackend.Cldr))
      {:ok, :Latn}

      iex> Cldr.validate_script("aaaa")
      {:error, {Cldr.InvalidScriptError, "The script \\"aaaa\\" is invalid"}}

      iex> Cldr.validate_script(%{})
      {:error, {Cldr.InvalidScriptError, "The script %{} is invalid"}}

  """
  @doc since: "2.23.0"

  @spec validate_script(Cldr.Locale.script() | String.t()) ::
          {:ok, atom()} | {:error, {module(), String.t()}}

  def validate_script(script) when is_atom(script) do
    script
    |> to_string()
    |> validate_script()
    |> case do
      {:ok, script} -> {:ok, script}
      {:error, _} -> {:error, unknown_script_error(script)}
    end
  end

  # See if its an alias
  def validate_script(script) when is_binary(script) do
    normalized_script = Cldr.Validity.Script.normalize(script)

    expanded_script =
      case Cldr.Locale.aliases(normalized_script, :script) do
        substitution when is_binary(substitution) ->
          substitution

        nil ->
          normalized_script
      end

    case Cldr.Validity.Script.validate(expanded_script) do
      {:ok, script, _} -> {:ok, script}
      _other -> {:error, unknown_script_error(script)}
    end
  end

  def validate_script(%LanguageTag{script: nil} = locale) do
    {:error, unknown_script_error(locale)}
  end

  def validate_script(%LanguageTag{script: script}) do
    validate_script(script)
  end

  def validate_script(script) do
    {:error, unknown_script_error(script)}
  end

  @doc """
  Normalise and validate a territory code.

  ## Arguments

  * `territory` is any territory code returned by `Cldr.known_territories/0`

  ## Returns:

  * `{:ok, normalized_territory_code}` or

  * `{:error, {Cldr.UnknownTerritoryError, message}}`

  ## Examples

      iex> Cldr.validate_territory("en")
      {:error, {Cldr.UnknownTerritoryError, "The territory \\"en\\" is unknown"}}

      iex> Cldr.validate_territory("gb")
      {:ok, :GB}

      iex> Cldr.validate_territory("001")
      {:ok, :"001"}

      iex> Cldr.validate_territory(Cldr.Locale.new!("en", TestBackend.Cldr))
      {:ok, :US}

      iex> Cldr.validate_territory(%{})
      {:error, {Cldr.UnknownTerritoryError, "The territory %{} is unknown"}}

  """
  @spec validate_territory(atom() | String.t()) ::
          {:ok, Locale.territory_code()} | {:error, {module(), String.t()}}

  def validate_territory(territory) when is_atom(territory) and territory in @known_territories do
    {:ok, territory}
  end

  def validate_territory(territory) when is_atom(territory) do
    territory
    |> to_string()
    |> validate_territory()
    |> case do
      {:ok, territory} -> {:ok, territory}
      {:error, _} -> {:error, unknown_territory_error(territory)}
    end
  end

  # See if its an alias
  def validate_territory(territory) when is_binary(territory) do
    normalized_territory = Cldr.Validity.Territory.normalize(territory)

    expanded_territory =
      case Cldr.Locale.aliases(normalized_territory, :region) do
        substitution when is_list(substitution) ->
          hd(substitution)

        substitution when is_binary(substitution) ->
          substitution

        nil ->
          normalized_territory
      end
      |> String.to_existing_atom()

    if expanded_territory in known_territories() do
      {:ok, expanded_territory}
    else
      {:error, unknown_territory_error(territory)}
    end
  rescue
    ArgumentError ->
      {:error, unknown_territory_error(territory)}
  end

  def validate_territory(%LanguageTag{territory: nil} = locale) do
    {:error, unknown_territory_error(locale)}
  end

  def validate_territory(%LanguageTag{territory: territory}) do
    validate_territory(territory)
  end

  def validate_territory(territory) do
    {:error, unknown_territory_error(territory)}
  end

  @doc """
  Normalise and validate a territory subdivision code.

  ## Arguments

  * `subdivision` is any territory code returned by `Cldr.known_territory_subdivisions/0`

  ## Returns:

  * `{:ok, normalized_subdivision_code}` or

  * `{:error, {Cldr.UnknownTerritoryError, message}}`

  ## Examples

  """
  def validate_territory_subdivision(subdivision) when is_binary(subdivision) do
    subdivision
    |> String.downcase()
    |> validate_subdivision
  end

  def validate_territory_subdivision(subdivision) do
    {:error, unknown_territory_error(subdivision)}
  end

  defp validate_subdivision(<<territory::binary-size(2), "zzzz">>) do
    validate_territory(territory)
  end

  defp validate_subdivision(subdivision) do
    case Cldr.Validity.Subdivision.validate(subdivision) do
      {:ok, subdivision, status} when status in [:regular, :deprecated] -> {:ok, subdivision}
      _ -> {:error, unknown_territory_error(subdivision)}
    end
  end

  @doc """
  Return the territory fallback chain based upon
  a locales territory (including `u` extension) and
  territory containment definitions.

  While CLDR also includes subdivisions in the
  territory chain, this implementation does not
  consider them.

  ## Arguments

  * `territory` is either a binary or atom territory code
    or a `t:Cldr.LanguageTag`

  ## Returns

  * `{:ok, list}` where `list` is a list of territories
    in decreasing order of containment (ie larger enclosing
    areas) or

  * `{:error, {exception, reason}}` indicating an error

  ## Examples

      iex> Cldr.territory_chain "US"
      {:ok, [:US, :"021", :"019", :"001"]}

      iex> Cldr.territory_chain :AU
      {:ok, [:AU, :"053", :"009", :"001"]}

      iex> {:ok, locale} = Cldr.validate_locale("en-US-u-rg-CAzzzz", MyApp.Cldr)
      iex> Cldr.territory_chain locale
      {:ok, [:CA, :"021", :"019", :"001"]}

      iex> Cldr.territory_chain :"001"
      {:ok, [:"001"]}

  """

  def territory_chain(%LanguageTag{} = locale) do
    locale
    |> Cldr.Locale.territory_from_locale()
    |> territory_chain()
  end

  def territory_chain(:"001" = the_world) do
    {:ok, [the_world]}
  end

  def territory_chain(territory) when is_atom(territory) do
    with {:ok, territory} <- Cldr.validate_territory(territory) do
      chain =
        territory_containment()
        |> Map.fetch!(territory)

      {:ok, [territory | chain]}
    end
  end

  def territory_chain(territory) when is_binary(territory) do
    with {:ok, territory} <- validate_territory(territory) do
      territory_chain(territory)
    end
  end

  @doc """
  Return the territory fallback chain based upon
  a locales territory (including `u` extension) and
  territory containment definitions.

  While CLDR also includes subdivisions in the
  territory chain, this implementation does not
  consider them.

  ## Arguments

  * `locale` is a binary locale name

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module.

  ## Returns

  * `{:ok, list}` where `list` is a list of territories
    in decreasing order of containment (ie larger enclosing
    areas) or

  * `{:error, {exception, reason}}` indicating an error

  ## Examples

      iex> Cldr.territory_chain "en-US-u-rg-CAzzzz", MyApp.Cldr
      {:ok, [:CA, :"021", :"019", :"001"]}

  """
  def territory_chain(locale_name, backend) when is_atom(backend) do
    with {:ok, locale} <- validate_locale(locale_name, backend) do
      territory_chain(locale)
    end
  end

  @doc """
  Returns an error tuple for an unknown territory.

  ## Arguments

  * `territory` is any territory code **not** returned by `Cldr.known_territories/0`

  ## Returns

  * `{:error, {Cldr.UnknownTerritoryError, message}}`

  ## Examples

      iex> Cldr.unknown_territory_error("invalid")
      {Cldr.UnknownTerritoryError, "The territory \\"invalid\\" is unknown"}

  """
  @spec unknown_territory_error(any()) :: {Cldr.UnknownTerritoryError, String.t()}
  def unknown_territory_error(territory) do
    {Cldr.UnknownTerritoryError, "The territory #{inspect(territory)} is unknown"}
  end

  @doc """
  Returns a list of strings representing the currencies known to `Cldr`.

  ## Example

      iex> Cldr.known_currencies
      [:ADP, :AED, :AFA, :AFN, :ALK, :ALL, :AMD, :ANG, :AOA, :AOK, :AON, :AOR, :ARA,
       :ARL, :ARM, :ARP, :ARS, :ATS, :AUD, :AWG, :AZM, :AZN, :BAD, :BAM, :BAN, :BBD,
       :BDT, :BEC, :BEF, :BEL, :BGL, :BGM, :BGN, :BGO, :BHD, :BIF, :BMD, :BND, :BOB,
       :BOL, :BOP, :BOV, :BRB, :BRC, :BRE, :BRL, :BRN, :BRR, :BRZ, :BSD, :BTN, :BUK,
       :BWP, :BYB, :BYN, :BYR, :BZD, :CAD, :CDF, :CHE, :CHF, :CHW, :CLE, :CLF, :CLP,
       :CNH, :CNX, :CNY, :COP, :COU, :CRC, :CSD, :CSK, :CUC, :CUP, :CVE, :CYP, :CZK,
       :DDM, :DEM, :DJF, :DKK, :DOP, :DZD, :ECS, :ECV, :EEK, :EGP, :ERN, :ESA, :ESB,
       :ESP, :ETB, :EUR, :FIM, :FJD, :FKP, :FRF, :GBP, :GEK, :GEL, :GHC, :GHS, :GIP,
       :GMD, :GNF, :GNS, :GQE, :GRD, :GTQ, :GWE, :GWP, :GYD, :HKD, :HNL, :HRD, :HRK,
       :HTG, :HUF, :IDR, :IEP, :ILP, :ILR, :ILS, :INR, :IQD, :IRR, :ISJ, :ISK, :ITL,
       :JMD, :JOD, :JPY, :KES, :KGS, :KHR, :KMF, :KPW, :KRH, :KRO, :KRW, :KWD, :KYD,
       :KZT, :LAK, :LBP, :LKR, :LRD, :LSL, :LTL, :LTT, :LUC, :LUF, :LUL, :LVL, :LVR,
       :LYD, :MAD, :MAF, :MCF, :MDC, :MDL, :MGA, :MGF, :MKD, :MKN, :MLF, :MMK, :MNT,
       :MOP, :MRO, :MRU, :MTL, :MTP, :MUR, :MVP, :MVR, :MWK, :MXN, :MXP, :MXV, :MYR,
       :MZE, :MZM, :MZN, :NAD, :NGN, :NIC, :NIO, :NLG, :NOK, :NPR, :NZD, :OMR, :PAB,
       :PEI, :PEN, :PES, :PGK, :PHP, :PKR, :PLN, :PLZ, :PTE, :PYG, :QAR, :RHD, :ROL,
       :RON, :RSD, :RUB, :RUR, :RWF, :SAR, :SBD, :SCR, :SDD, :SDG, :SDP, :SEK, :SGD,
       :SHP, :SIT, :SKK, :SLE, :SLL, :SOS, :SRD, :SRG, :SSP, :STD, :STN, :SUR, :SVC,
       :SYP, :SZL, :THB, :TJR, :TJS, :TMM, :TMT, :TND, :TOP, :TPE, :TRL, :TRY, :TTD,
       :TWD, :TZS, :UAH, :UAK, :UGS, :UGX, :USD, :USN, :USS, :UYI, :UYP, :UYU, :UYW,
       :UZS, :VEB, :VED, :VEF, :VES, :VND, :VNN, :VUV, :WST, :XAF, :XAG, :XAU, :XBA,
       :XBB, :XBC, :XBD, :XCD, :XDR, :XEU, :XFO, :XFU, :XOF, :XPD, :XPF, :XPT, :XRE,
       :XSU, :XTS, :XUA, :XXX, :YDD, :YER, :YUD, :YUM, :YUN, :YUR, :ZAL, :ZAR, :ZMK,
       :ZMW, :ZRN, :ZRZ, :ZWD, :ZWL, :ZWR]

  """
  @known_currencies Cldr.Config.known_currencies()
  @spec known_currencies :: [atom(), ...] | []
  def known_currencies do
    @known_currencies
  end

  @doc """
  Normalize and validate a currency code.

  ## Arguments

  * `currency` is any ISO 4217 currency code as returned by `Cldr.known_currencies/0`
    or any valid private use ISO4217 code which is a three-letter alphabetic code that
    starts with "X".

  ## Returns

  * `{:ok, normalized_currency_code}` or

  * `{:error, {Cldr.UnknownCurrencyError, message}}`

  ## Examples

      iex> Cldr.validate_currency(:USD)
      {:ok, :USD}

      iex> Cldr.validate_currency("USD")
      {:ok, :USD}

      iex> Cldr.validate_currency(:XTC)
      {:ok, :XTC}

      iex> Cldr.validate_currency("xtc")
      {:ok, :XTC}

      iex> Cldr.validate_currency("invalid")
      {:error, {Cldr.UnknownCurrencyError, "The currency \\"invalid\\" is invalid"}}

      iex> Cldr.validate_currency(:invalid)
      {:error, {Cldr.UnknownCurrencyError, "The currency :invalid is invalid"}}

  """

  def validate_currency(currency) when is_atom(currency) and currency in @known_currencies do
    {:ok, currency}
  end

  def validate_currency(currency) when is_atom(currency) do
    currency
    |> Atom.to_string()
    |> validate_currency
    |> case do
      {:error, _} -> {:error, unknown_currency_error(currency)}
      ok -> ok
    end
  end

  def validate_currency(
        <<char_1::integer-size(8), char_2::integer-size(8), char_3::integer-size(8)>> = currency
      )
      when Config.is_alphabetic(char_1) and Config.is_alphabetic(char_2) and
             Config.is_alphabetic(char_3) and char_1 in [?x, ?X] do
    {:ok, String.to_atom(String.upcase(currency))}
  end

  def validate_currency(
        <<char_1::integer-size(8), char_2::integer-size(8), char_3::integer-size(8)>> = currency
      )
      when Config.is_alphabetic(char_1) and Config.is_alphabetic(char_2) and
             Config.is_alphabetic(char_3) do
    currency_code =
      currency
      |> String.upcase()
      |> String.to_existing_atom()

    if currency_code in @known_currencies do
      {:ok, currency_code}
    else
      {:error, unknown_currency_error(currency)}
    end
  rescue
    ArgumentError ->
      {:error, unknown_currency_error(currency)}
  end

  def validate_currency(invalid_currency) do
    {:error, unknown_currency_error(invalid_currency)}
  end

  @doc """
  Returns an error tuple for an invalid currency.

  ## Arguments

  * `currency` is any currency code **not** returned by `Cldr.known_currencies/0`

  ## Returns

  * `{:error, {Cldr.UnknownCurrencyError, message}}`

  ## Examples

      iex> Cldr.unknown_currency_error("invalid")
      {Cldr.UnknownCurrencyError, "The currency \\"invalid\\" is invalid"}

  """
  def unknown_currency_error(currency) do
    {Cldr.UnknownCurrencyError, "The currency #{inspect(currency)} is invalid"}
  end

  @doc """
  Returns a list of atoms representing the number systems known to `Cldr`.

  ## Example

      iex> Cldr.known_number_systems
      [:adlm, :ahom, :arab, :arabext, :armn, :armnlow, :bali, :beng, :bhks, :brah,
       :cakm, :cham, :cyrl, :deva, :diak, :ethi, :fullwide, :geor, :gong, :gonm, :grek,
       :greklow, :gujr, :guru, :hanidays, :hanidec, :hans, :hansfin, :hant, :hantfin,
       :hebr, :hmng, :hmnp, :java, :jpan, :jpanfin, :jpanyear, :kali, :kawi, :khmr, :knda, :lana, :lanatham,
       :laoo, :latn, :lepc, :limb, :mathbold, :mathdbl, :mathmono, :mathsanb,
       :mathsans, :mlym, :modi, :mong, :mroo, :mtei, :mymr, :mymrshan, :mymrtlng, :nagm,
       :newa, :nkoo, :olck, :orya, :osma, :rohg, :roman, :romanlow, :saur, :segment, :shrd,
       :sind, :sinh, :sora, :sund, :takr, :talu, :taml, :tamldec, :telu, :thai, :tibt,
       :tirh, :tnsa, :vaii, :wara, :wcho]

  """
  @known_number_systems Cldr.Config.known_number_systems()
  @spec known_number_systems :: [atom(), ...] | []
  def known_number_systems do
    @known_number_systems
  end

  @doc """
  Normalize and validate a number system name.

  ## Arguments

  * `number_system` is any number system name returned by
    `Cldr.known_number_systems/0`

  ## Returns

  * `{:ok, normalized_number_system_name}` or

  * `{:error, {exception, message}}`

  ## Examples

      iex> Cldr.validate_number_system :latn
      {:ok, :latn}

      iex> Cldr.validate_number_system :arab
      {:ok, :arab}

      iex> Cldr.validate_number_system "invalid"
      {
        :error,
        {Cldr.UnknownNumberSystemError, "The number system :invalid is unknown"}
      }

  """

  @spec validate_number_system(atom() | String.t()) ::
          {:ok, atom()} | {:error, {module(), String.t()}}

  def validate_number_system(number_system) when is_atom(number_system) do
    if number_system in known_number_systems() do
      {:ok, number_system}
    else
      {:error, unknown_number_system_error(number_system)}
    end
  end

  def validate_number_system(number_system) when is_binary(number_system) do
    number_system
    |> String.downcase()
    |> String.to_existing_atom()
    |> validate_number_system
  rescue
    ArgumentError ->
      {:error, unknown_number_system_error(number_system)}
  end

  @doc """
  Normalize and validate a plural type.

  ## Arguments

  * `plural_type` is any plural type returned by
    `Cldr.Number.PluralRule.known_plural_types/0`

  ## Returns

  * `{:ok, normalized_plural_type}` or

  * `{:error, {exception, message}}`

  ## Examples

      iex> Cldr.validate_plural_type :few
      {:ok, :few}

      iex> Cldr.validate_plural_type "one"
      {:ok, :one}

      iex> Cldr.validate_plural_type "invalid"
      {
        :error,
        {Cldr.UnknownPluralTypeError, "The plural type :invalid is unknown"}
      }

  """

  @spec validate_plural_type(atom() | String.t()) ::
          {:ok, Cldr.Number.PluralRule.plural_type()} | {:error, {module(), String.t()}}

  def validate_plural_type(plural_type) when is_atom(plural_type) do
    if plural_type in Cldr.Number.PluralRule.known_plural_types() do
      {:ok, plural_type}
    else
      {:error, unknown_plural_type_error(plural_type)}
    end
  end

  def validate_plural_type(plural_type) when is_binary(plural_type) do
    plural_type
    |> String.downcase()
    |> String.to_existing_atom()
    |> validate_plural_type
  rescue
    ArgumentError ->
      {:error, unknown_plural_type_error(plural_type)}
  end

  @doc """
  Returns an error tuple for an unknown number system.

  ## Arguments

  * `number_system` is any number system name **not** returned by `Cldr.known_number_systems/0`

  ## Returns

  * `{:error, {Cldr.UnknownNumberSystemError, message}}`

  ## Examples

      iex> Cldr.unknown_number_system_error "invalid"
      {Cldr.UnknownNumberSystemError, "The number system \\"invalid\\" is invalid"}

      iex> Cldr.unknown_number_system_error :invalid
      {Cldr.UnknownNumberSystemError, "The number system :invalid is unknown"}

  """
  @spec unknown_number_system_error(any()) :: {Cldr.UnknownNumberSystemError, String.t()}
  def unknown_number_system_error(number_system) when is_atom(number_system) do
    {Cldr.UnknownNumberSystemError, "The number system #{inspect(number_system)} is unknown"}
  end

  def unknown_number_system_error(number_system) do
    {Cldr.UnknownNumberSystemError, "The number system #{inspect(number_system)} is invalid"}
  end

  @doc """
  Returns an error tuple for an invalid script.

  ## Arguments

  * `script` is any script as a string or an atom

  ## Returns

  * `{:error, {Cldr.InvalidScriptError, message}}`

  ## Examples

      iex> Cldr.unknown_script_error "invalid"
      {Cldr.InvalidScriptError, "The script \\"invalid\\" is invalid"}

      iex> Cldr.unknown_script_error :invalid
      {Cldr.InvalidScriptError, "The script :invalid is invalid"}

  """
  @doc since: "2.23.0"

  @spec unknown_script_error(any()) :: {Cldr.InvalidScriptError, String.t()}
  def unknown_script_error(script) when is_atom(script) do
    {Cldr.InvalidScriptError, "The script #{inspect(script)} is invalid"}
  end

  def unknown_script_error(script) do
    {Cldr.InvalidScriptError, "The script #{inspect(script)} is invalid"}
  end

  @doc """
  Returns a list of atoms representing the number systems types known to `Cldr`.

  ## Arguments

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module.  The default is `Cldr.default_backend/0`.
    Note that `Cldr.default_backend/0` will raise an exception if
    no `:default_backend` is configured under the `:ex_cldr` key in
    `config.exs`.

  ## Example

      iex> Cldr.known_number_system_types(TestBackend.Cldr)
      [:default, :finance, :native, :traditional]

  """
  def known_number_system_types(backend \\ default_backend!()) do
    backend.known_number_system_types
  end

  @doc """
  Normalise and validate a number system type.

  ## Arguments

  * `number_system_type` is any number system type returned by
    `Cldr.known_number_system_types/1`

  * `backend` is any module that includes `use Cldr` and therefore
    is a `Cldr` backend module.  The default is `Cldr.default_backend/0`.
    Note that `Cldr.default_backend/0` will raise an exception if
    no `:default_backend` is configured under the `:ex_cldr` key in
    `config.exs`.

  ## Returns

  * `{:ok, normalized_number_system_type}` or

  * `{:error, {exception, message}}`

  ## Examples

      iex> Cldr.validate_number_system_type(:default, TestBackend.Cldr)
      {:ok, :default}

      iex> Cldr.validate_number_system_type(:traditional, TestBackend.Cldr)
      {:ok, :traditional}

      iex> Cldr.validate_number_system_type(:latn, TestBackend.Cldr)
      {
        :error,
        {Cldr.UnknownNumberSystemTypeError, "The number system type :latn is unknown"}
      }

  """
  @spec validate_number_system_type(String.t() | atom(), backend()) ::
          {:ok, atom()} | {:error, {module(), String.t()}}

  def validate_number_system_type(number_system_type, backend \\ default_backend!()) do
    backend.validate_number_system_type(number_system_type)
  end

  @doc """
  Returns an error tuple for an unknown number system type.

  ## Options

  * `number_system_type` is any number system type name **not** returned
    by `Cldr.known_number_system_types/1`

  ## Returns

  * `{:error, {Cldr.UnknownNumberSystemTypeError, message}}`

  ## Examples

      iex> Cldr.unknown_number_system_type_error("invalid")
      {Cldr.UnknownNumberSystemTypeError, "The number system type \\"invalid\\" is invalid"}

      iex> Cldr.unknown_number_system_type_error(:invalid)
      {Cldr.UnknownNumberSystemTypeError, "The number system type :invalid is unknown"}

  """
  @spec unknown_number_system_type_error(any()) :: {Cldr.UnknownNumberSystemTypeError, String.t()}

  def unknown_number_system_type_error(number_system_type) when is_atom(number_system_type) do
    {
      Cldr.UnknownNumberSystemTypeError,
      "The number system type #{inspect(number_system_type)} is unknown"
    }
  end

  def unknown_number_system_type_error(number_system_type) do
    {
      Cldr.UnknownNumberSystemTypeError,
      "The number system type #{inspect(number_system_type)} is invalid"
    }
  end

  @doc """
  Returns an error tuple for an unknown plural type.

  ## Options

  * `plural_type` is any unknown number system type

  ## Returns

  * `{:error, {Cldr.UnknownPluralTypeError, message}}`

  ## Examples

      iex> Cldr.unknown_plural_type_error("invalid")
      {Cldr.UnknownPluralTypeError, "The plural type \\"invalid\\" is invalid"}

      iex> Cldr.unknown_plural_type_error(:invalid)
      {Cldr.UnknownPluralTypeError, "The plural type :invalid is unknown"}

  """
  @spec unknown_plural_type_error(any()) :: {Cldr.UnknownPluralTypeError, String.t()}

  def unknown_plural_type_error(plural_type) when is_atom(plural_type) do
    {
      Cldr.UnknownPluralTypeError,
      "The plural type #{inspect(plural_type)} is unknown"
    }
  end

  def unknown_plural_type_error(plural_type) do
    {
      Cldr.UnknownPluralTypeError,
      "The plural type #{inspect(plural_type)} is invalid"
    }
  end

  @doc """
  Normalise and validate a measurement system type.

  ## Arguments

  * `measurement_system` is a known
    measurement system.

  ## Returns

  * `{:ok, normalized_measurement_system}` or

  * `{:error, {exception, message}}`

  ## Examples

      iex> Cldr.validate_measurement_system :metric
      {:ok, :metric}

      iex> Cldr.validate_measurement_system "ussystem"
      {:ok, :ussystem}

      iex> Cldr.validate_measurement_system "uksystem"
      {:ok, :uksystem}

      iex> Cldr.validate_measurement_system "something"
      {:error, {Cldr.UnknownMeasurementSystemError,
       "The measurement system \\"something\\" is invalid"}}

  """
  def validate_measurement_system(system) when is_binary(system) do
    system
    |> String.downcase()
    |> do_validate_measurement_system
  end

  def validate_measurement_system(system) when is_atom(system) do
    do_validate_measurement_system(system)
  end

  @measurement_systems Cldr.Config.measurement_systems()
                       |> Enum.flat_map(fn
                         {k, %{alias: nil}} -> [{k, k}]
                         {k, %{alias: a}} -> [{k, k}, {a, k}]
                       end)
                       |> Map.new()

  for {system, canonical_system} <- @measurement_systems do
    defp do_validate_measurement_system(unquote(system)),
      do: {:ok, unquote(canonical_system)}

    defp do_validate_measurement_system(unquote(Kernel.to_string(system))),
      do: {:ok, unquote(canonical_system)}
  end

  defp do_validate_measurement_system(measurement_system) do
    {:error, unknown_measurement_system_error(measurement_system)}
  end

  def unknown_measurement_system_error(measurement_system) do
    {
      Cldr.UnknownMeasurementSystemError,
      "The measurement system #{inspect(measurement_system)} is invalid"
    }
  end

  @doc """
  Returns a unicode string representing a flag for a territory.

  ## Options

  * `territory` is any valid territory code returned
    by `Cldr.known_territories/0` or a `Cldr.LanguageTag.t`

  ## Returns

  * A string representing a flag or

  * An empty string if the territory is valid but no
    unicode grapheme is defined. This is true for territories
    that are aggregate areas such as "the world" which is
    `:001`

  * `{:error, {Cldr.UnknownTerritoryError, message}}`

  ## Notes

  * If a `Cldr.LanguageTag.t` is provided, the territory is determined
    by `Cldr.Locale.territory_from_locale/1`

  ## Examples

      iex> Cldr.flag :AU
      "🇦🇺"

      iex> Cldr.flag :US
      "🇺🇸"

      iex> Cldr.flag "UN"
      "🇺🇳"

      iex> Cldr.flag(:UK)
      "🇬🇧"

      iex> Cldr.flag(:GB)
      "🇬🇧"

      iex> Cldr.flag(:UX)
      {:error, {Cldr.UnknownTerritoryError, "The territory :UX is unknown"}}

  """

  def flag(%LanguageTag{} = locale) do
    locale
    |> Cldr.Locale.territory_from_locale()
    |> Atom.to_charlist()
    |> generate_flag
  end

  def flag(territory) do
    with {:ok, territory} <- validate_territory(territory) do
      territory
      |> Atom.to_charlist()
      |> generate_flag
    end
  end

  # See https://en.wikipedia.org/wiki/Regional_indicator_symbol
  @unicode_flag_codepoint_offset 0x1F1A5

  defp generate_flag([_, _] = iso_code) do
    iso_code
    |> Enum.map(&(&1 + @unicode_flag_codepoint_offset))
    |> Kernel.to_string()
  end

  defp generate_flag(_) do
    ""
  end

  @doc false
  def locale_and_backend_from(options) when is_map(options) do
    locale = Map.get(options, :locale)
    backend = Map.get(options, :backend)
    locale_and_backend_from(locale, backend)
  end

  def locale_and_backend_from(options) when is_list(options) do
    locale = Keyword.get(options, :locale)
    backend = Keyword.get(options, :backend)
    locale_and_backend_from(locale, backend)
  end

  @doc false
  def locale_and_backend_from(nil, nil) do
    locale = Cldr.get_locale()
    {locale, locale.backend}
  end

  def locale_and_backend_from(%Cldr.LanguageTag{} = locale, _backend) do
    {locale, locale.backend}
  end

  def locale_and_backend_from(locale, nil) when is_locale_name(locale) do
    {locale, Cldr.default_backend!()}
  end

  def locale_and_backend_from(nil, backend) do
    {backend.get_locale(), backend}
  end

  def locale_and_backend_from(locale, backend) when is_locale_name(locale) do
    {locale, backend}
  end

  @doc false
  def locale_name(%LanguageTag{cldr_locale_name: locale_name}), do: inspect(locale_name)
  def locale_name(locale) when is_binary(locale), do: inspect(locale)

  @doc false
  def maybe_log(message) do
    require Logger

    if System.get_env("CLDR_DEBUG") do
      Logger.debug(message)
    end
  end
end
