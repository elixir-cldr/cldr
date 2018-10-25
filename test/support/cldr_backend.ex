defmodule TestBackend.Cldr do
  use Cldr,
    default_locale: "en-001",
    locales: :all,
    gettext: TestGettext.Gettext,
    precompile_transliterations: [{:latn, :arab}, {:arab, :thai}, {:arab, :latn}]

end