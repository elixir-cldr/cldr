Benchee.run(
  %{
    "Cldr.Locale.new/2" =>
      fn ->
        Cldr.Locale.new!("chi_guoyu_hakka_xiang", MyApp.Cldr)
      end,
    },
  time: 10,
  memory_time: 2
)
