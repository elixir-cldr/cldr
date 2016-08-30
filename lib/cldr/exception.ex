defmodule Cldr.UnknownLocale do
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end