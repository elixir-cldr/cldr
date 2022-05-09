defmodule Cldr.Test do
  use ExUnit.Case, async: true

  test "that the cldr source data directory is correct" do
    assert String.ends_with?(Cldr.Config.source_data_dir(), "/priv/cldr") == true
  end

  test "that the client data directory is correct" do
    assert String.ends_with?(Cldr.Config.client_data_dir(TestBackend.Cldr), "/priv/cldr") ==
             true
  end

  test "that the cldr data directory is correct" do
    assert String.ends_with?(Cldr.Config.cldr_data_dir(), "/_build/test/lib/ex_cldr/priv/cldr") ==
             true
  end

  test "that we have the correct modules (keys) for the json consolidation" do
    assert Cldr.Config.required_modules() ==
             [
               "number_formats",
               "list_formats",
               "currencies",
               "number_systems",
               "number_symbols",
               "minimum_grouping_digits",
               "rbnf",
               "units",
               "date_fields",
               "dates",
               "territories",
               "languages",
               "delimiters",
               "ellipsis",
               "lenient_parse",
               "locale_display_names",
               "subdivisions"
             ]
  end

  test "default locale" do
    assert TestBackend.Cldr.default_locale() ==
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
  end

  test "locale name does not exist" do
    alias TestBackend.Cldr
    refute Cldr.available_locale_name?("jabberwocky")
  end

  test "that we have the right number of rbnf locales" do
    alias TestBackend.Cldr

    assert Cldr.known_rbnf_locale_names() ==
      [:af, :ak, :am, :ar, :az, :be, :bg, :bs, :ca, :ccp, :chr, :cs, :cy, :da, :de,
       :"de-CH", :ee, :el, :en, :"en-IN", :eo, :es, :"es-419", :et, :fa, :"fa-AF",
       :ff, :fi, :fil, :fo, :fr, :"fr-BE", :"fr-CH", :ga, :he, :hi, :hr, :hu, :hy,
       :id, :is, :it, :ja, :ka, :kl, :km, :ko, :ky, :lb, :lo, :lrc, :lt, :lv, :mk,
       :ms, :mt, :my, :ne, :nl, :nn, :no, :pl, :pt, :"pt-PT", :qu, :ro, :ru, :se, :sk,
       :sl, :sq, :sr, :"sr-Latn", :su, :sv, :sw, :ta, :th, :tr, :uk, :und, :vi, :yue,
       :"yue-Hans", :zh, :"zh-Hant"]
  end

  test "that locale substitutions are applied" do
    assert Cldr.Locale.substitute_aliases(Cldr.LanguageTag.Parser.parse!("en-US")) ==
             %Cldr.LanguageTag{
               backend: nil,
               canonical_locale_name: nil,
               cldr_locale_name: nil,
               language_subtags: [],
               extensions: %{},
               gettext_locale_name: nil,
               language: "en",
               locale: %{},
               private_use: [],
               rbnf_locale_name: nil,
               requested_locale_name: "en-US",
               script: nil,
               territory: "US",
               transform: %{},
               language_variants: []
             }

    assert Cldr.Locale.substitute_aliases(Cldr.LanguageTag.Parser.parse!("sh_Arab_AQ")) ==
             %Cldr.LanguageTag{
               backend: nil,
               canonical_locale_name: nil,
               cldr_locale_name: nil,
               language_subtags: [],
               extensions: %{},
               gettext_locale_name: nil,
               language: "sr",
               locale: %{},
               private_use: [],
               rbnf_locale_name: nil,
               requested_locale_name: "sh_Arab_AQ",
               script: "Arab",
               territory: "AQ",
               transform: %{},
               language_variants: []
             }

    assert Cldr.Locale.substitute_aliases(Cldr.LanguageTag.Parser.parse!("sh_AQ")) ==
             %Cldr.LanguageTag{
               backend: nil,
               canonical_locale_name: nil,
               cldr_locale_name: nil,
               language_subtags: [],
               extensions: %{},
               gettext_locale_name: nil,
               language: "sr",
               locale: %{},
               private_use: [],
               rbnf_locale_name: nil,
               requested_locale_name: "sh_AQ",
               script: :Latn,
               territory: "AQ",
               transform: %{},
               language_variants: []
             }
  end


  test "That RBNF locale names can be inherited" do
    assert {:ok, locale} = Cldr.validate_locale("nb", TestBackend.Cldr)
    assert locale ==
      %Cldr.LanguageTag{
        backend: TestBackend.Cldr,
        canonical_locale_name: "nb",
        cldr_locale_name: :nb,
        extensions: %{},
        gettext_locale_name: nil,
        language: "nb",
        language_subtags: [],
        language_variants: [],
        locale: %{},
        private_use: [],
        rbnf_locale_name: :no,
        requested_locale_name: "nb",
        script: :Latn,
        territory: :NO,
        transform: %{}
      }
  end

  test "that we can have repeated currencies in a territory" do
    assert Cldr.Config.territory(:PS)[:currency] ==
             [
               JOD: %{from: ~D[1996-02-12]},
               ILS: %{from: ~D[1985-09-04]},
               ILP: %{from: ~D[1967-06-01], to: ~D[1980-02-22]},
               JOD: %{from: ~D[1950-07-01], to: ~D[1967-06-01]}
             ]
  end

  test "that we get the correct default json library" do
    assert Cldr.Config.json_library() == Jason
  end

  test "that configs merge correctly" do
    assert WithOtpAppBackend.Cldr.__cldr__(:config).locales ==
             [:en, :"en-001", :fr, :und]

    assert WithGettextBackend.Cldr.__cldr__(:config).locales ==
             [:en, :"en-001", :"en-GB", :es, :it, :und]

    assert TestBackend.Cldr.__cldr__(:config).locales == :all
  end

  test "that data_dir is correctly resolved" do
    # data_dir configured in the otp_app
    assert "./with_opt_app_backend/cldr/some_dir" ==
             Cldr.Config.client_data_dir(WithOtpAppBackend.Cldr)

    # data_dir configured on the module
    assert "./another_backend/cldr/data_dir" == Cldr.Config.client_data_dir(AnotherBackend.Cldr)

    # default data_dir
    assert Cldr.Config.client_data_dir(DefaultBackend.Cldr) =~
             "_build/test/lib/ex_cldr/priv/cldr"
  end

  test "that an unknown otp_app config raises" do
    assert_raise Cldr.UnknownOTPAppError, "The configured OTP app :rubbish is not known", fn ->
      Cldr.Config.client_data_dir(%{otp_app: :rubbish})
    end
  end

  test "return of currency map" do
    {:ok, currencies} = Cldr.Config.currencies_for(:en, WithOtpAppBackend.Cldr)
    assert Map.get(currencies, :AUD)
  end

  test "correct date parsing of currencies" do
    {:ok, currencies} = Cldr.Config.currencies_for(:en, WithOtpAppBackend.Cldr)
    assert Map.get(currencies, :YUM).from == 1994
    assert Map.get(currencies, :YUM).to == 2002
    assert Map.get(currencies, :UYI).name == "Uruguayan Peso (Indexed Units)"
    assert Map.get(currencies, :USN).name == "US Dollar (Next day)"
  end

  test "UTF8 names in currency annotations" do
    {:ok, currencies} = Cldr.Config.currencies_for(:de, TestBackend.Cldr)
    assert Map.get(currencies, :USN).name == "US Dollar (Nächster Tag)"
  end

  test "validating locales that are not precompiled" do
    assert {:ok, _locale} = Cldr.validate_locale("en-au", TestBackend.Cldr)
    assert {:ok, _locale} = Cldr.validate_locale("en_au", TestBackend.Cldr)
    assert {:ok, _locale} = Cldr.validate_locale("en-au-u-ca-buddhist", TestBackend.Cldr)
  end

  if function_exported?(Code, :fetch_docs, 1) do
    test "that no module docs are generated for a backend" do
      assert {:docs_v1, _, :elixir, _, :hidden, %{}, _} = Code.fetch_docs(DefaultBackend.Cldr)
    end

    test "that module docs are generated for a backend" do
      assert {:docs_v1, _, :elixir, "text/markdown", %{"en" => _}, %{}, _} =
               Code.fetch_docs(TestBackend.Cldr)
    end
  end

  test "Cldr.Chars.to_string for a language_tag" do
    {:ok, locale} = Cldr.validate_locale("en-US-u-nu-thai-cu-AUD", MyApp.Cldr)
    assert Cldr.to_string(locale) == "en-Latn-US-u-cu-aud-nu-thai"
  end

  test "MyApp.Cldr.known_gettext_locale_names/0" do
    assert MyApp.Cldr.known_gettext_locale_names == ["en", "en-GB", "es", "it"]
  end
end
