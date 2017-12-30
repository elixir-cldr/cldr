defmodule Cldr.InvalidLanguageTag do
  @moduledoc """
  Exception raised when there is an a parse error in a language tag
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end
