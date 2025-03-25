defprotocol Cldr.DisplayName do
  @moduledoc """
  Returns the localised display name
  for a CLDR struct (locale, unit, currency)

  """

  def display_name(term, options)
end
