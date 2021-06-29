defprotocol Cldr.DisplayName do
  @moduledoc """
  Returns the localised display name
  for a CLDR struct (locale, unit, currency)

  """

  @spec display_name(t, Cldr.LanguageTag.t(), Keyword.t()) :: String.t()
  def display_name(language_tag, in_locale, options)
end

