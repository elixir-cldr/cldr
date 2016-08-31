defmodule Cldr.Locale do
  @moduledoc """
  Parse and process locale strings as defined by [Unicode](http://unicode.org/reports/tr35/#Unicode_Language_and_Locale_Identifiers)
  """
  @type t :: binary

  def normalize_locale(locale) do
    String.replace(locale, "_", "-")
  end
end