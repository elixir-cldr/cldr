defmodule Cldr.Locale.Sigil do
  alias Cldr.Locale
  alias Cldr.LanguageTag

  @doc ~S"""
  Implements the sigil `~L` for a Locale

  The lower case `~l` variant does not exist as interpolation and excape
  characters are not useful for Locale sigils.

  ## Example

      iex> ~L[en]

  """
  @spec sigil_L(Locale.locale_name, any()) :: LanguageTag.t | none()
  def sigil_L(locale_name, _) do
    Cldr.Locale.new(locale_name)
  end

end