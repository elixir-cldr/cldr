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

  test "An exception is raised when a Gettext backend module encounters an unknown locale" do
    assert_raise Gettext.Plural.UnknownLocaleError, ~r/gsw/, fn ->
      defmodule TestGettext.GettextUnknown do
        @moduledoc """
        Implements a Gettext-compatible module that does not have the base
        language locale configured for "gsw" and will therefore raise.

        See https://hexdocs.pm/gettext/Gettext.Plural.html#module-language-and-territory
        for an explanation of which the exception is raised (its because we have configured
        "gsw_CH" but not "gsw" and Gettext forwards plurals to the base language).

        """
        use Gettext,
          otp_app: Cldr.Config.app_name(),
          priv: "priv/gettext_unknown"
      end
    end
  end
end
