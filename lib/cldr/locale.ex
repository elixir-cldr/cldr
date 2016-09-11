defmodule Cldr.Locale do
  @moduledoc """
  Parse and process locale strings as defined by [Unicode](http://unicode.org/reports/tr35/#Unicode_Language_and_Locale_Identifiers)
  """
  @type t :: binary
  Enum.each Cldr.known_locales(), fn locale_name ->
    locale = Cldr.Config.get_locale(locale_name)

    def get_locale(unquote(locale_name)) do
      unquote(Macro.escape(locale))
    end
  end

  def get_locale(locale) do
    raise Cldr.UnknownLocaleError,
      "The requested locale #{inspect locale} is not known."
  end

  def normalize_locale(locale) do
    String.replace(locale, "_", "-")
  end
end