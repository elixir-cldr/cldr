if Code.ensure_loaded?(Gettext) do
  defmodule Cldr.Gettext do
    @moduledoc """
    Implements a Gettext-compatible module but using Cldr locales
    """
    use Gettext, otp_app: :ex_cldr, priv: "priv/gettext_test",
                                    plural_forms: Cldr.Gettext.Plural
  end
end