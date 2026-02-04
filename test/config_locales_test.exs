defmodule Cldr.Config.Test do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  @from_locales ["en", "en-au", "zh-hant-hk", "zh_haNt"]
  @to_locales [:en, :"en-001", :"en-AU", :und, :"zh-Hant", :"zh-Hant-HK"]

  test "locale resolution in a config is case insensitive" do
    capture_io(:stderr, fn ->
      capture_io(fn ->
        defmodule ConfigTest do
          use Cldr, locales: unquote(@from_locales)
        end
      end)
    end)

    assert Cldr.Locale.Loader.known_locale_names(Cldr.Config.Test.ConfigTest) == @to_locales
  end

  test "a backend locales configuration" do
    opts = [locales: unquote(@from_locales), providers: []]
    config = Cldr.Config.config_from_opts(opts)

    assert config.locales == @to_locales
  end

  test "that a backend config with invalid locale raises" do
    match = ~r/Failed to install the locale named.*/

    capture_io(:stderr, fn ->
      assert_raise Cldr.UnknownLocaleError, match, fn ->
        defmodule InvalidLocale do
          use Cldr, locales: ["www"]
        end
      end
    end)
  end

  test "that a backend config with unknown Gettext locale warns" do
    match = ~r/The locale.*/

    capture_io(:stderr, fn ->
      capture_io(fn ->
        defmodule UnknownGettext do
          use Cldr, locales: ["en"], gettext: TestGettext.GettextUnknown
        end
      end) =~ match
    end)
  end

  test "that a backend config includes fallback locales" do
    from_locales = ["en-AU", "ca-ES-VALENCIA", "pt-PT", "nb"]

    to_locales = [
      :"ca-ES-valencia",
      :"en-001",
      :"en-AU",
      :nb,
      :no,
      :"pt-PT",
      :und
    ]

    capture_io(:stderr, fn ->
      capture_io(fn ->
        defmodule AddFallback do
          use Cldr,
            locales: from_locales,
            add_fallback_locales: true
        end
      end)
    end)

    assert Cldr.Locale.Loader.known_locale_names(Cldr.Config.Test.AddFallback) == to_locales
  end

  test "that a default locale in posix format configures correctly" do
    capture_io(:stderr, fn ->
      capture_io(fn ->
        defmodule PosixDefaultLocale do
          use Cldr,
            locales: ["en_GB"],
            default_locale: "en_GB",
            providers: []
        end
      end)
    end)

    assert apply(Cldr.Config.Test.PosixDefaultLocale, :known_locale_names, []) ==
             [:"en-GB"]

    assert apply(Cldr.Config.Test.PosixDefaultLocale, :default_locale, []).cldr_locale_name ==
             :"en-GB"
  end

  test "that redundant Cldr.Currency is warned if Cldr.Number is configured" do
    assert capture_io(fn ->
             defmodule ConfigRedundant do
               use Cldr,
                 default_locale: "en",
                 providers: [Cldr.Number, Cldr.Currency],
                 suppress_warnings: false
             end
           end) =~ "The provider Cldr.Currency is redundant"
  end

  test "that :supress warnings is deprecated" do
    assert capture_io(fn ->
             defmodule SupressWarnings do
               use Cldr,
                 default_locale: "en",
                 providers: [Cldr.Number, Cldr.Currency],
                 supress_warnings: false
             end
           end) =~
             "The option :supress_warnings has been deprecated and replaced with :suppress_warnings"
  end

  test ":default_currency_format is configured as :currency" do
    capture_io(fn ->
      defmodule DefaultCurrencyFormat do
        use Cldr,
          default_locale: "en",
          providers: [Cldr.Currency],
          suppress_warnings: false,
          default_currency_format: :currency
      end
    end)

    assert apply(Cldr.Config.Test.DefaultCurrencyFormat, :__cldr__, [:config]).default_currency_format ==
             :currency
  end

  test ":default_currency_format is configured as :accounting" do
    capture_io(fn ->
      defmodule DefaultAccountingFormat do
        use Cldr,
          default_locale: "en",
          providers: [Cldr.Currency],
          suppress_warnings: false,
          default_currency_format: :accounting
      end
    end)

    assert apply(Cldr.Config.Test.DefaultAccountingFormat, :__cldr__, [:config]).default_currency_format ==
             :accounting
  end
end
