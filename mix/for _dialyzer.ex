defmodule Cldr.ForDialyzer do
  def with_locale do
    import Cldr.LanguageTag.Sigil

    Cldr.with_locale "fr", fn -> nil end
    Cldr.with_locale :fr, fn -> nil end
    Cldr.with_locale ~l"fr", fn -> nil end

    Cldr.with_locale "fr", MyApp.Cldr, fn -> nil end
    Cldr.with_locale :fr, MyApp.Cldr, fn -> nil end

    MyApp.Cldr.with_locale "fr", fn -> nil end
    MyApp.Cldr.with_locale :fr, fn -> nil end
    MyApp.Cldr.with_locale ~l"fr", fn -> nil end
  end

end