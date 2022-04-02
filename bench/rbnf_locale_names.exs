config = %Cldr.Config{locales: :all}

Benchee.run(
  %{
    "rbnf_locale_names_original" =>
      fn ->
        Cldr.Locale.Loader.known_rbnf_locale_names(config)
      end,
    "rbnf_locale_names_async" =>
      fn ->
        Cldr.Locale.Loader.known_rbnf_locale_names2(config)
      end,
    },
  time: 10,
  memory_time: 2
)
