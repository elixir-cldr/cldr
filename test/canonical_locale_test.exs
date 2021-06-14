defmodule Cldr.CanonicalLocaleTest do
  use ExUnit.Case, async: true

  # Explicit locales: 26..41
  # From aliases 45.777
  # Decanonicalized 781..838
  # With irrelevants 842..1647

  for [line, from, to] <- Cldr.CanonicalLocaleGenerator.data(), line in 842..1647 do
    test "##{line} Locale #{inspect from} becomes #{inspect to}" do
      assert Cldr.Locale.new!(unquote(from), TestBackend.Cldr).canonical_locale_name == unquote(to)
    end
  end
end
