defmodule Cldr.Gettext.Test do
  use ExUnit.Case, async: true

  test "that Cldr.Config gets the list of locales when there is no global default" do
    assert TestBackend.Cldr.known_gettext_locale_names() == ["en", "en-GB", "es", "it"]
  end

  test "that an incorrect configuration raises" do
    alias TestGettext.Gettext, as: T

    assert T.lngettext("it", "default", nil, "One new email", "%{count} new emails", 1, %{}) ==
             {:ok, "Una nuova email"}

    assert T.lngettext("it", "default", nil, "One new email", "%{count} new emails", 2, %{}) ==
             {:ok, "2 nuove email"}
  end
end
