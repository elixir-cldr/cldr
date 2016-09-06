if Code.ensure_loaded?(Gettext) do
  defmodule Cldr.Gettext do
    use Gettext, otp_app: :ex_cldr, priv: "priv/gettext_test",
                                    plural_forms: Cldr.Gettext.Plural
  end
end