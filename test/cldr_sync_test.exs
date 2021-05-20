defmodule Cldr.SyncTest do
  use ExUnit.Case, async: false

  test "that we get an exception when relying on Cldr.default_backend() and its not configured" do
    backend = Application.get_env(:ex_cldr, :default_backend)
    Application.put_env(:ex_cldr, :default_backend, nil)

    assert_raise Cldr.NoDefaultBackendError, "No default :ex_cldr backend is configured", fn ->
      Cldr.validate_locale("en")
    end

    Application.put_env(:ex_cldr, :default_backend, backend)
  end

  test "that we don't get an exception if a default backend is configured" do
    default = Application.get_env(:ex_cldr, :default_backend)
    Application.put_env(:ex_cldr, :default_backend, MyApp.Cldr)
    {:ok, _locale} = Cldr.validate_locale("en")
    Application.put_env(:ex_cldr, :default_backend, default)
  end

  test "validate LanguageTag locale when no default backend and locale is a language tag" do
    default = Application.get_env(:ex_cldr, :default_backend)
    Application.put_env(:ex_cldr, :default_backend, nil)

    locale = Cldr.default_locale(MyApp.Cldr)
    assert Cldr.validate_locale(locale) == {:ok, locale}

    Application.put_env(:ex_cldr, :default_backend, default)
  end

  test "plural type when no default backend and locale is a language tag" do
    default = Application.get_env(:ex_cldr, :default_backend)
    Application.put_env(:ex_cldr, :default_backend, nil)

    locale = Cldr.default_locale(MyApp.Cldr)
    assert Cldr.Number.PluralRule.plural_type(2, locale: locale) == :other

    Application.put_env(:ex_cldr, :default_backend, default)
  end


end