defmodule Cldr.LanguageTag.Sigil do
  defmacro sigil_l(locale, _opts) do
    {:<<>>, [_], [locale]} = locale

    case validate_locale(String.split(locale, "|")) do
      {:ok, locale} -> quote do unquote(Macro.escape(locale)) end
      {:error, {exception, reason}} -> raise exception, reason
    end
  end

  defp validate_locale([locale, backend]) do
    backend = Module.concat([backend])
    Cldr.validate_locale(locale, backend)
  end

  defp validate_locale([locale]) do
    Cldr.validate_locale(locale)
  end
end