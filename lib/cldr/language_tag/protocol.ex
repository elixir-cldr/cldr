defprotocol Cldr.LanguageTag.Chars do
  @spec to_string(t) :: String.t()
  def to_string(value)
end
