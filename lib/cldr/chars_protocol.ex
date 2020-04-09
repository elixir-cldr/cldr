import Kernel, except: [to_string: 1]

defprotocol Cldr.Chars do
  @moduledoc ~S"""
  The `Cldr.Chars` protocol mirrors the
  `String.Chars` protocol but localises
   the output. It is intended to be
   drop-in replacement for `String.Chars`.

  """

  @doc """
  Converts `term` to a localised string.
  """
  @spec to_string(t) :: String.t()
  def to_string(term)
end

defimpl Cldr.Chars, for: Cldr.LanguageTag do
  def to_string(language_tag) do
    Cldr.LanguageTag.to_string(language_tag)
  end
end