defmodule Cldr.Compiler do
  @moduledoc false

  @doc false
  defmacro __before_compile__(env) do
    config =
      env.module
      |> Module.get_attribute(:cldr_opts)
      |> Keyword.put(:backend, env.module)
      |> Map.new

    config =
      config
      |> Map.put_new(:default_locale, Cldr.Config.default_locale(config))

    Cldr.Config.check_jason_lib_is_available
    Cldr.install_locales(config)

    quote location: :keep do
      def __cldr__(:backend), do: unquote(Map.get(config, :backend))
      def __cldr__(:locales), do: unquote(Map.get(config, :locales))
      def __cldr__(:default_locale), do: unquote(Map.get(config, :default_locale))

      unquote(Cldr.define_validate_locale(config))

      defmodule Number.Ordinal do
        @moduledoc """
        Implements ordinal plural rules for numbers.
        """

        use Cldr.Number.PluralRule, :ordinal
        alias Cldr.LanguageTag

        unquote(Cldr.Number.PluralRule.define_plural_rules())
      end

      defmodule Number.Cardinal do
        @moduledoc """
        Implements cardinal plural rules for numbers.
        """

        use Cldr.Number.PluralRule, :cardinal
        alias Cldr.LanguageTag

        unquote(Cldr.Number.PluralRule.define_plural_rules())
      end
    end
  end

end