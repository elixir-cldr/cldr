# locale = Cldr.Locale.new!("en", MyApp.Cldr)

Benchee.run(
  %{
    # "Cldr.locale_and_backend_from([])" => fn -> Cldr.locale_and_backend_from([]) end,
    # "Cldr.locale_and_backend_from(nil, nil)" => fn -> Cldr.locale_and_backend_from(nil, nil) end,
    # "Cldr.locale_and_backend_from(locale, nil)" => fn -> Cldr.locale_and_backend_from(locale, nil) end,
    "Cldr.get_locale" => fn -> Cldr.get_locale end,
    "Cldr.default_locale" => fn -> Cldr.default_locale end,
    "Cldr.Config.default_locale" => fn -> Cldr.Config.default_locale end
    },
  time: 10,
  memory_time: 2
)