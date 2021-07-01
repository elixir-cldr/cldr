defprotocol Cldr.LanguageTag.Chars do
  @moduledoc false

  @spec to_string(t) :: String.t() | {String.t(), String.t()}
  def to_string(value)
end
